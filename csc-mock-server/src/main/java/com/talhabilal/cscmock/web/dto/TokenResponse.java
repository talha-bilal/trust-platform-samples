package com.talhabilal.cscmock.web.dto;

public record TokenResponse(String access_token, String token_type, int expires_in, String scope) {}
