#!/bin/sh

#  ci_pre_xcodebuild.sh
#  aic
#
#  Created by David Bireta on 9/8/25.
#  Copyright © 2025 Art Institute of Chicago. All rights reserved.

# Stop on any error
set -e

echo "Starting ci_post_clone.sh script..."

# If this is a Pull Request build, no need to setup the real assets.
if [[ -n $CI_PULL_REQUEST_NUMBER ]];
then
    echo "This build started from a pull request."
    exit 0
fi

# Define repository URL and branch
PRIVATE_REPO_URL="${CONFIG_REPO_URL}"
CLONE_BRANCH="develop"

# Define a temporary path to clone the repo into.
CLONE_TEMP_PATH="${CI_WORKSPACE_PATH}/private-resources"

# Clone the private config repository
echo "Cloning private resource repository..."
git clone --depth 1 --branch "$CLONE_BRANCH" "${CONFIG_REPO_URL}" "$CLONE_TEMP_PATH"

# Copy resources into the main project
echo "Copying resources..."
cp -R "${CLONE_TEMP_PATH}/files/Config.plist" "${CI_PRIMARY_REPOSITORY_PATH}/aic/aic/Config.plist"
cp -R "${CLONE_TEMP_PATH}/files/Info.plist" "${CI_PRIMARY_REPOSITORY_PATH}/aic/aic/Info.plist"
cp -R "${CLONE_TEMP_PATH}/files/GoogleService-Info.plist" "${CI_PRIMARY_REPOSITORY_PATH}/aic/aic/GoogleService-Info.plist"
cp -R "${CLONE_TEMP_PATH}/files/UIFont+FontNames.swift" "${CI_PRIMARY_REPOSITORY_PATH}/aic/aic/Shared/Extensions/UIFont+FontNames.swift"
cp -R "${CLONE_TEMP_PATH}/files/fonts/idealsans" "${CI_PRIMARY_REPOSITORY_PATH}/aic/aic/Assets/fonts/idealsans"

# Clean up the temporary repository
echo "Cleaning up temporary clone..."
rm -rf "$CLONE_TEMP_PATH"

echo "ci_post_clone.sh finished successfully."

exit 0
