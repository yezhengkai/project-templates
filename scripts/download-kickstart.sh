#!/usr/bin/env bash
# References:
# https://github.com/mitsuhiko/rye/blob/main/scripts/install.sh
set -euo pipefail

# Default variables
REPO=Keats/kickstart
PLATFORM=$(uname -s)
VERSION=latest

# References:
# https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
# https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}


# Parse command line arguments
# Ref: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
  key="$1"
  case "$key" in
    # This is an arg value type option. Will catch -v value or --version value
    -v|--version)
    shift # past the key and to the value
    VERSION="$1"
    ;;
    # This is an arg=value type option. Will catch -v=value or --version=value
    -v=*|--version=*)
    # No need to shift here since the value is part of the same string
    VERSION="${key#*=}"
    ;;
    -p|--platform)
    shift
    PLATFORM="$1"
    ;;
    -p=*|--platform=*)
    PLATFORM="${key#*=}"
    ;;
    *)
    # Do whatever you want with extra options
    echo "Unknown option '$key'"
    ;;
  esac
  # Shift after checking all the cases to get the next option
  shift
done

# Get latest version
if [[ $VERSION == "latest" ]]; then
  VERSION=$(get_latest_release $REPO)
fi

# Get file name
# References:
# https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
if [[ ${PLATFORM^} == "Darwin" ]]; then
  ZIP_FILENAME=kickstart-${VERSION}-x86_64-apple-darwin.tar.gz
elif [[ ${PLATFORM^} == "Linux" ]]; then
  ZIP_FILENAME=kickstart-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
elif [[ ${PLATFORM^} == "Windows" ]]; then
  ZIP_FILENAME=kickstart-${VERSION}-x86_64-pc-windows-msvc.zip
fi


# Download
DOWNLOAD_URL=https://github.com/${REPO}/releases/download/${VERSION}/${ZIP_FILENAME}
if [[ ${PLATFORM^} == "Windows" ]]; then
  TEMP_FILE="temp.zip"
else
  TEMP_FILE="temp.tar.gz"
fi
HTTP_CODE=$(curl -SL --progress-bar "$DOWNLOAD_URL" --output "$TEMP_FILE" --write-out "%{http_code}")
if [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]]; then
  echo "error: platform ${PLATFORM} is unsupported."
  exit 1
fi

# Extract archives
if [[ ${PLATFORM^} == "Windows" ]]; then
  unzip -o $TEMP_FILE
else
  tar -xf $TEMP_FILE
  chmod +x kickstart
fi

# Clean up
rm -rf $TEMP_FILE
