#!/bin/sh
set -e

# PackageHall CLI Installer
# This script detects the platform and installs the appropriate packagehall-ctl binary

REPO="pkgr/packagehall-ctl"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="packagehall-ctl"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    printf "${GREEN}==>${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}Warning:${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}Error:${NC} %s\n" "$1"
}

# Detect platform and architecture
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$OS" in
        linux)
            PLATFORM="linux"
            ;;
        darwin)
            PLATFORM="darwin"
            ;;
        mingw*|msys*|cygwin*)
            PLATFORM="windows"
            ;;
        *)
            log_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac

    case "$ARCH" in
        x86_64|amd64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    if [ "$PLATFORM" = "windows" ]; then
        BINARY_NAME="${BINARY_NAME}.exe"
        ARCHIVE_EXT="zip"
    else
        ARCHIVE_EXT="tar.gz"
    fi

    ARCHIVE_NAME="packagehall-ctl-${PLATFORM}-${ARCH}.${ARCHIVE_EXT}"
}

# Get latest release version
get_latest_version() {
    log_info "Fetching latest release..."

    # Try to get latest release from GitHub API
    if command -v curl >/dev/null 2>&1; then
        VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    elif command -v wget >/dev/null 2>&1; then
        VERSION=$(wget -qO- "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        log_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    if [ -z "$VERSION" ]; then
        log_error "Failed to fetch latest version"
        exit 1
    fi

    log_info "Latest version: $VERSION"
}

# Download and extract binary
download_binary() {
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE_NAME}"
    TMP_DIR="/tmp/packagehall-install.$$"
    TMP_ARCHIVE="${TMP_DIR}/${ARCHIVE_NAME}"

    log_info "Downloading from: $DOWNLOAD_URL"

    mkdir -p "$TMP_DIR"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$DOWNLOAD_URL" -o "$TMP_ARCHIVE"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$DOWNLOAD_URL" -O "$TMP_ARCHIVE"
    fi

    if [ ! -f "$TMP_ARCHIVE" ]; then
        log_error "Download failed"
        rm -rf "$TMP_DIR"
        exit 1
    fi

    log_info "Extracting archive..."

    # Extract based on platform
    if [ "$PLATFORM" = "windows" ]; then
        if command -v unzip >/dev/null 2>&1; then
            unzip -q "$TMP_ARCHIVE" -d "$TMP_DIR"
        else
            log_error "unzip not found. Please install unzip."
            rm -rf "$TMP_DIR"
            exit 1
        fi
    else
        tar -xzf "$TMP_ARCHIVE" -C "$TMP_DIR"
    fi

    TMP_BINARY="${TMP_DIR}/${BINARY_NAME}"

    if [ ! -f "$TMP_BINARY" ]; then
        log_error "Binary not found in archive"
        rm -rf "$TMP_DIR"
        exit 1
    fi

    chmod +x "$TMP_BINARY"
}

# Install binary
install_binary() {
    TARGET_PATH="${INSTALL_DIR}/${BINARY_NAME}"

    # Check if we need sudo
    if [ -w "$INSTALL_DIR" ]; then
        log_info "Installing to $TARGET_PATH"
        mv "$TMP_BINARY" "$TARGET_PATH"
    else
        log_info "Installing to $TARGET_PATH (requires sudo)"
        sudo mv "$TMP_BINARY" "$TARGET_PATH"
    fi

    # Cleanup
    rm -rf "$TMP_DIR"

    log_info "${GREEN}Successfully installed ${BINARY_NAME}!${NC}"

    # Verify installation
    if command -v "$BINARY_NAME" >/dev/null 2>&1; then
        INSTALLED_VERSION=$("$BINARY_NAME" --version 2>&1 || echo "unknown")
        log_info "Installed version: $INSTALLED_VERSION"
    else
        log_warn "${INSTALL_DIR} may not be in your PATH"
        log_warn "You may need to add it to your shell configuration"
    fi
}

# Main installation flow
main() {
    log_info "PackageHall CLI Installer"
    echo

    detect_platform
    log_info "Platform: ${PLATFORM}-${ARCH}"

    get_latest_version
    download_binary
    install_binary

    echo
    log_info "Installation complete!"
    log_info "Run '${BINARY_NAME} --help' to get started"
}

main
