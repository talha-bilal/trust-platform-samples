package com.talhabilal.cscmock.web.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record AuthorizeRequest(
    @NotBlank String credentialID,
    @Min(1) int numSignatures,
    String hashAlgorithm,
    String description) {}
