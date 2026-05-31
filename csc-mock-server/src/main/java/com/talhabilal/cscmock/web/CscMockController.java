package com.talhabilal.cscmock.web;

import com.talhabilal.cscmock.service.CscMockService;
import com.talhabilal.cscmock.web.dto.AuthorizeRequest;
import com.talhabilal.cscmock.web.dto.SignHashRequest;
import com.talhabilal.cscmock.web.dto.TimestampRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping
public class CscMockController {

  private final CscMockService service;

  public CscMockController(CscMockService service) {
    this.service = service;
  }

  @GetMapping("/info")
  public Map<String, Object> info() {
    return service.serviceInfo();
  }

  @PostMapping(
      value = "/oauth2/token",
      consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
  public Object token(@RequestParam MultiValueMap<String, String> form) {
    return service.token(
        form.getFirst("grant_type"),
        form.getFirst("client_id"),
        form.getFirst("client_secret"),
        form.getFirst("scope"));
  }

  @PostMapping("/credentials/list")
  public Object credentialsList(@RequestHeader(HttpHeaders.AUTHORIZATION) String auth) {
    requireBearer(auth);
    return service.listCredentials();
  }

  @PostMapping("/credentials/authorize")
  public Object authorize(
      @RequestHeader(HttpHeaders.AUTHORIZATION) String auth, @Valid @RequestBody AuthorizeRequest body) {
    requireBearer(auth);
    return service.authorize(body);
  }

  @PostMapping("/signatures/signHash")
  public Object signHash(
      @RequestHeader(HttpHeaders.AUTHORIZATION) String auth, @Valid @RequestBody SignHashRequest body) {
    requireBearer(auth);
    return service.signHash(body);
  }

  @PostMapping("/timestamps")
  public Object timestamps(
      @RequestHeader(HttpHeaders.AUTHORIZATION) String auth, @Valid @RequestBody TimestampRequest body) {
    requireBearer(auth);
    return service.timestamp(body.hash());
  }

  private static void requireBearer(String auth) {
    if (auth == null || !auth.startsWith("Bearer ")) {
      throw new org.springframework.web.server.ResponseStatusException(
          org.springframework.http.HttpStatus.UNAUTHORIZED, "missing Bearer token");
    }
  }
}
