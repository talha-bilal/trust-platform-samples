package com.talhabilal.cscmock.web.dto;

import jakarta.validation.constraints.NotBlank;

public record SignHashRequest(
    @NotBlank String credentialID,
    @NotBlank String SAD,
    @NotBlank String hash,
    @NotBlank String signAlgo,
    String transactionId) {}
