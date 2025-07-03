#!/bin/bash
set -e

# Inputs
BUMP_TYPE=$1 # major, minor, patch
RELEASE_MESSAGE=$2
ACTOR=$3

# Get latest tag (default to v0.0.0)
git fetch --tags
LATEST_TAG=$(git tag --sort=taggerdate | tail -n 1)
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="v0.0.0"
fi

# Remove 'v' prefix for semver parsing
SEMVER=${LATEST_TAG#v}

# Bump version
IFS='.' read -r MAJOR MINOR PATCH <<< "$SEMVER"
case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0;;
  minor)
    MINOR=$((MINOR+1)); PATCH=0;;
  patch)
    PATCH=$((PATCH+1));;
  *)
    echo "Unknown bump type: $BUMP_TYPE"; exit 1;;
esac
NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

# Generate changelog since last tag
CHANGELOG=$(git log "$LATEST_TAG"..HEAD --pretty=format:"- %s (%an)" || echo "Initial release")

# Create and push tag
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git tag "$NEW_VERSION"
git push origin "$NEW_VERSION"

# Output for GitHub Actions
echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT
echo "changelog<<EOF" >> $GITHUB_OUTPUT
echo "$CHANGELOG" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT 