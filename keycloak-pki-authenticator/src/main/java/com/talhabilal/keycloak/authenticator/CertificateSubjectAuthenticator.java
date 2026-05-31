package com.talhabilal.keycloak.authenticator;

import org.jboss.logging.Logger;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowError;
import org.keycloak.authentication.Authenticator;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;

import jakarta.ws.rs.core.MultivaluedMap;

/**
 * Demo authenticator: requires X-Demo-Cert-Subject header (portfolio sample only).
 */
public class CertificateSubjectAuthenticator implements Authenticator {

    private static final Logger LOG = Logger.getLogger(CertificateSubjectAuthenticator.class);
    static final String HEADER = "X-Demo-Cert-Subject";

    @Override
    public void authenticate(AuthenticationFlowContext context) {
        MultivaluedMap<String, String> headers = context.getHttpRequest().getHttpHeaders().getRequestHeaders();
        String subject = headers != null ? headers.getFirst(HEADER) : null;

        if (subject == null || subject.isBlank()) {
            LOG.warnf("Missing %s header for user %s", HEADER, context.getUser() != null ? context.getUser().getUsername() : "unknown");
            context.failure(AuthenticationFlowError.INVALID_CREDENTIALS);
            return;
        }

        LOG.infof("Demo certificate subject accepted: %s", subject);
        context.success();
    }

    @Override
    public void action(AuthenticationFlowContext context) {
        authenticate(context);
    }

    @Override
    public boolean requiresUser() {
        return false;
    }

    @Override
    public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
        return true;
    }

    @Override
    public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
        // no-op
    }

    @Override
    public void close() {
        // no-op
    }
}
