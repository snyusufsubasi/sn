#!/usr/bin/env bash
set -euo pipefail

PINNED_FLUTTER_MAJOR_MINOR="3.27"
SKIP_VERSION_CHECK="${SKIP_VERSION_CHECK:-false}"

echo "[bootstrap] Checking Flutter version..."
FLUTTER_VERSION_LINE="$(flutter --version | sed -n '1p')"
if [[ -z "${FLUTTER_VERSION_LINE}" ]]; then
  echo "[bootstrap] Flutter not found in PATH."
  exit 1
fi

if [[ "${SKIP_VERSION_CHECK}" != "true" ]] && [[ "${FLUTTER_VERSION_LINE}" != *"Flutter ${PINNED_FLUTTER_MAJOR_MINOR}."* ]]; then
  echo "[bootstrap] Expected Flutter ${PINNED_FLUTTER_MAJOR_MINOR}.x, got: ${FLUTTER_VERSION_LINE}"
  echo "[bootstrap] Use FVM/asdf pinned version before continuing."
  exit 1
fi

echo "[bootstrap] Ensuring .env exists..."
if [[ ! -f ".env" ]]; then
  cp .env.example .env
  echo "[bootstrap] .env created from .env.example"
fi

echo "[bootstrap] Resolving dependencies from lockfile..."
flutter pub get --enforce-lockfile

echo "[bootstrap] Generating l10n..."
flutter gen-l10n

echo "[bootstrap] Running codegen..."
dart run build_runner build --delete-conflicting-outputs

echo "[bootstrap] Running static analysis..."
flutter analyze --no-fatal-infos

echo "[bootstrap] Running tests..."
flutter test

echo "[bootstrap] Done."
