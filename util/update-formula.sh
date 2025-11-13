#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FORMULA_FILE="${REPO_ROOT}/Formula/panther-cloud-connected-setup.rb"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.0.29"
    exit 1
fi

CHECKSUMS_URL="https://github.com/panther-labs/panther-cli/releases/download/v${VERSION}/panther-cli_${VERSION}_checksums.txt"

echo "Fetching checksums for version ${VERSION}..."

if ! CHECKSUMS=$(curl -fsSL "${CHECKSUMS_URL}"); then
    echo "Error: Failed to fetch checksums from ${CHECKSUMS_URL}"
    echo "Please verify the version exists as a GitHub release"
    exit 1
fi

echo "Parsing checksums..."
DARWIN_X86_64=$(echo "$CHECKSUMS" | grep "panther-cli_Darwin_x86_64.tar.gz" | awk '{print $1}')
DARWIN_ARM64=$(echo "$CHECKSUMS" | grep "panther-cli_Darwin_arm64.tar.gz" | awk '{print $1}')
LINUX_X86_64=$(echo "$CHECKSUMS" | grep "panther-cli_Linux_x86_64.tar.gz" | awk '{print $1}')
LINUX_ARM64=$(echo "$CHECKSUMS" | grep "panther-cli_Linux_arm64.tar.gz" | awk '{print $1}')

if [[ -z "$DARWIN_X86_64" || -z "$DARWIN_ARM64" || -z "$LINUX_X86_64" || -z "$LINUX_ARM64" ]]; then
    echo "Error: Failed to parse one or more checksums"
    exit 1
fi

echo "Checksums found: ($CHECKSUMS_URL)"
echo "  Darwin x86_64: $DARWIN_X86_64"
echo "  Darwin arm64:  $DARWIN_ARM64"
echo "  Linux x86_64:  $LINUX_X86_64"
echo "  Linux arm64:   $LINUX_ARM64"

echo ""
echo "Updating ${FORMULA_FILE}..."

sed -i '' \
    -e "s/darwin_x86_64: \"[^\"]*\"/darwin_x86_64: \"${DARWIN_X86_64}\"/" \
    -e "s/darwin_arm64: \"[^\"]*\"/darwin_arm64: \"${DARWIN_ARM64}\"/" \
    -e "s/linux_x86_64: \"[^\"]*\"/linux_x86_64: \"${LINUX_X86_64}\"/" \
    -e "s/linux_arm64: \"[^\"]*\"/linux_arm64: \"${LINUX_ARM64}\"/" \
    -e "s/version \"[^\"]*\"/version \"${VERSION}\"/" \
    "${FORMULA_FILE}"

echo "✓ Formula updated successfully!"