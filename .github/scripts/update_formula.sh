#!/usr/bin/env bash

set -o errexit

PACKAGE_NAME=$1
PACKAGE_VERSION=$2
# The NPM package name, when it differs from the formula name — e.g. a scoped
# package (`@apify/mcpc`) cannot be a formula name.
NPM_PACKAGE_NAME=${3:-$PACKAGE_NAME}

if [[ "$#" -lt 2 || "$#" -gt 3 ]]; then
    echo "Usage: $0 package-name package-version [npm-package-name]"
    exit 1;
fi

# Run in the Formula directory
cd "$(dirname "$0")"/../../Formula

PACKAGE_DEFINITION_URL="https://registry.npmjs.org/${NPM_PACKAGE_NAME}/${PACKAGE_VERSION}"

# It can happen that the package is not available right after the publish command finishes
# Try waiting 3 minutes until the package version is available
for _i in {1..6}; do
    curl -sf "${PACKAGE_DEFINITION_URL}" &> /dev/null && break;
    echo "Package ${NPM_PACKAGE_NAME} version ${PACKAGE_VERSION} is not available yet."
    echo "Will retry in 30 seconds."
    sleep 30;
done

# Get the tarball URL from the package definition on NPM
TARBALL_URL=$(curl -sf "${PACKAGE_DEFINITION_URL}" | jq -r '.dist.tarball') \
    || { echo "Package ${NPM_PACKAGE_NAME} version ${PACKAGE_VERSION} is not available."; exit 1; };

# Calculate the SHA256 hash of the tarball
SHA256=$(curl -sf "${TARBALL_URL}" | sha256sum | cut -d " " -f 1)

# Replace the URL and the hash in the formula definition
# We have to use a sed command separator that URLs cannot contain: `/` appears in
# every URL and `@` in the tarball URL of a scoped package (`@apify/mcpc`).
sed -i.bak -e "s|  url .*|  url \"${TARBALL_URL}\"|" "${PACKAGE_NAME}.rb"
sed -i.bak -e "s|  sha256 .*|  sha256 \"${SHA256}\"|" "${PACKAGE_NAME}.rb"
rm -rf "${PACKAGE_NAME}.rb.bak"
