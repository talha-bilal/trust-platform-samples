package com.talhabilal.cscmock.service;

import com.talhabilal.cscmock.web.dto.AuthorizeRequest;
import com.talhabilal.cscmock.web.dto.AuthorizeResponse;
import com.talhabilal.cscmock.web.dto.CredentialsListResponse;
import com.talhabilal.cscmock.web.dto.SignHashRequest;
import com.talhabilal.cscmock.web.dto.SignHashResponse;
import com.talhabilal.cscmock.web.dto.TimestampResponse;
import com.talhabilal.cscmock.web.dto.TokenResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class CscMockService {

  private static final List<String> DEFAULT_CREDENTIALS = List.of("cred-9f2a", "cred-1b88");

  private final String clientId;
  private final String clientSecret;
  private final Map<String, SadEntry> sadStore = new ConcurrentHashMap<>();

  public CscMockService(
      @Value("${csc.mock.client-id}") String clientId,
      @Value("${csc.mock.client-secret}") String clientSecret) {
    this.clientId = clientId;
    this.clientSecret = clientSecret;
  }

  public Map<String, Object> serviceInfo() {
    return Map.of(
        "spec", "1.0",
        "name", "CSC Mock Server (Portfolio Sample)",
        "region", "EU",
        "authType", "oauth2",
        "signAlgorithms", List.of("RSA_PKCS1_SHA256", "ECDSA_SHA256"));
  }

  public TokenResponse token(String grantType, String cid, String secret, String scope) {
    if (!"client_credentials".equals(grantType)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "unsupported grant_type");
    }
    if (!clientId.equals(cid) || !clientSecret.equals(secret)) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "invalid_client");
    }
    return new TokenResponse("mock-token-" + UUID.randomUUID(), "Bearer", 3600, scope != null ? scope : "service");
  }

  public CredentialsListResponse listCredentials() {
    return new CredentialsListResponse(DEFAULT_CREDENTIALS);
  }

  public AuthorizeResponse authorize(AuthorizeRequest req) {
    if (!DEFAULT_CREDENTIALS.contains(req.credentialID())) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "credential not allowed");
    }
    String sad = "sad-" + UUID.randomUUID();
    sadStore.put(
        sad,
        new SadEntry(req.credentialID(), req.numSignatures(), Instant.now().plusSeconds(300)));
    return new AuthorizeResponse(sad, 300);
  }

  public SignHashResponse signHash(SignHashRequest req) {
    SadEntry entry = sadStore.remove(req.SAD());
    if (entry == null || entry.expiresAt().isBefore(Instant.now())) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "SAD expired or invalid");
    }
    if (!entry.credentialId().equals(req.credentialID())) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "credential mismatch");
    }
    if (entry.remainingSignatures() <= 0) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "no signatures remaining");
    }
    if (!List.of("RSA_PKCS1_SHA256", "ECDSA_SHA256").contains(req.signAlgo())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "unsupported signAlgo");
    }

    String fakeSig =
        Base64.getEncoder()
            .encodeToString(
                ("mock-signature:" + req.hash() + ":" + req.signAlgo()).getBytes());

    return new SignHashResponse(fakeSig, req.signAlgo(), req.credentialID());
  }

  public TimestampResponse timestamp(String hash) {
    String token =
        Base64.getEncoder().encodeToString(("tsa-mock:" + hash + ":" + Instant.now()).getBytes());
    return new TimestampResponse(token);
  }

  private record SadEntry(String credentialId, int remainingSignatures, Instant expiresAt) {}
}
