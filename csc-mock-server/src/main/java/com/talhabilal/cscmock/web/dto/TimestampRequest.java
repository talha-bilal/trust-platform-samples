package com.talhabilal.cscmock.web.dto;

import jakarta.validation.constraints.NotBlank;

public record TimestampRequest(@NotBlank String hash, String hashAlgorithm) {}
