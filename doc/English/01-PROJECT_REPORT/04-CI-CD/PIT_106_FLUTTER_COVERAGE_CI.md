# 📊 PIT-106 — Flutter Coverage Threshold in CI

> **Date:** 31/03/2026
> **Status:** ✅ **COMPLETED**
> **Branch:** `feature/hu-5.1-flutter-coverage`
> **Linear:** [PIT-106](https://linear.app/pitcherdev/issue/PIT-106)

## 📋 Table of Contents

1. [Summary](#summary)
2. [Changes](#changes)
3. [Coverage Results](#coverage-results)
4. [Files Changed](#files-changed)

---

## Summary

| Metric | Value |
|--------|-------|
| **Ticket** | PIT-106 — [HU-5.1] Flutter Coverage with 80% Threshold in CI |
| **Coverage domain/** | 93.9% ✅ |
| **Coverage infrastructure/** | 85.0% ✅ |
| **Coverage overall** | 78.6% (informational) |
| **Threshold** | ≥80% on domain/ and infrastructure/ |
| **CI pipeline** | ci-master.yaml updated |

---

## Changes

### 1. New Script: `scripts/testing/flutter_coverage_check.sh`

Standalone Flutter coverage checker with threshold enforcement:

- Runs `flutter test --coverage` from `src/client/`
- Filters generated files: `*.g.dart`, `*.freezed.dart`, `gen/`, `l10n/`
- Extracts per-directory coverage via `lcov --extract`
- Enforces **≥80%** on business-critical layers: `domain/` and `infrastructure/`
- Reports overall coverage as informational (not enforced)
- Generates HTML report with `genhtml`
- Writes GitHub Actions step summary table
- Exit code 0 = pass, 1 = fail

**Usage:**

```bash
./scripts/testing/flutter_coverage_check.sh --threshold=80 --html
```

### 2. CI Pipeline Update: `ci-master.yaml`

Added two new steps to the Frontend job:

| Step | Purpose |
|------|---------|
| 📋 Install lcov | Ensures `lcov` is available on the runner |
| 📊 Flutter Coverage Threshold (≥80%) | Runs `flutter_coverage_check.sh`, fails CI if threshold not met |

The coverage artifact now uploads the full `coverage/` directory (lcov + HTML).

### 3. Script Updates

| Script | Change |
|--------|--------|
| `PRE_PUSH_VALIDATION_MASTER.sh` | Phase 7 now delegates Flutter coverage to `flutter_coverage_check.sh` |
| `generate_coverage_html.sh` | Added filtering of generated files before HTML generation |

---

## Coverage Results

**Breakdown by directory (filtered, excludes generated files):**

| Directory | Coverage | Threshold | Status |
|-----------|----------|-----------|--------|
| domain/ | 93.9% | 80% | ✅ |
| infrastructure/ | 85.0% | 80% | ✅ |
| core/ | 80.6% | — | ℹ️ |
| features/ | 80.9% | — | ℹ️ |
| services/ | 63.7% | — | ℹ️ |
| shared/ | 70.2% | — | ℹ️ |
| **Overall** | **78.6%** | — | ℹ️ |

**Excluded from coverage:**
- `*.g.dart` (code generation)
- `*.freezed.dart` (Freezed unions)
- `gen/` (generated assets)
- `l10n/` (localization)

---

## Files Changed

| File | Action | Description |
|------|--------|-------------|
| `scripts/testing/flutter_coverage_check.sh` | **Created** | Flutter coverage checker with threshold |
| `.github/workflows/ci-master.yaml` | Modified | Added lcov install + coverage threshold step |
| `scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh` | Modified | Delegated Flutter coverage to new script |
| `scripts/testing/generate_coverage_html.sh` | Modified | Added generated file filtering |
