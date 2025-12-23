#!/usr/bin/env bash

set -euo pipefail

echo "Installing tmux from source to ./bin..."
echo "This will compile libevent, ncurses, and tmux"
echo ""

# Get the project root directory (where this script lives)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PREFIX="$PROJECT_ROOT"
BUILD_DIR="$PROJECT_ROOT/tmux-build"

# Create directories
mkdir -p "$INSTALL_PREFIX"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Get the files (updated to current versions)
echo "Downloading sources..."
curl -L https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz -o libevent.tar.gz
curl -L https://invisible-mirror.net/archives/ncurses/ncurses-6.4.tar.gz -o ncurses.tar.gz
curl -L https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz -o tmux.tar.gz

# Extract them
echo "Extracting archives..."
tar xzf libevent.tar.gz
tar xzf ncurses.tar.gz
tar xzf tmux.tar.gz

# Compile libevent
echo "Compiling libevent..."
cd libevent-2.1.12-stable
./configure --prefix="$INSTALL_PREFIX" --disable-shared
make
make install
cd ..

# Compile ncurses
echo "Compiling ncurses..."
cd ncurses-6.4
./configure --prefix="$INSTALL_PREFIX" --with-shared --with-cxx-shared --enable-widec
make
make install
cd ..

# Compile tmux
echo "Compiling tmux..."
cd tmux-3.4
./configure --prefix="$INSTALL_PREFIX" \
    CFLAGS="-I$INSTALL_PREFIX/include -I$INSTALL_PREFIX/include/ncursesw" \
    LDFLAGS="-L$INSTALL_PREFIX/lib" \
    PKG_CONFIG_PATH="$INSTALL_PREFIX/lib/pkgconfig"
make
make install
cd ..

# Clean up build directory
echo "Cleaning up build files..."
cd "$PROJECT_ROOT"
rm -rf "$BUILD_DIR"

echo ""
echo "========================================"
echo "Installation complete!"
echo "========================================"
echo ""
"$INSTALL_PREFIX/bin/tmux" -V
echo ""
echo "tmux installed to: $INSTALL_PREFIX/bin/tmux"
echo ""
echo "Add to your PATH with:"
echo ""
echo "  export PATH=\"$INSTALL_PREFIX/bin:\$PATH\""
echo ""
echo "To remove tmux and all dependencies later:"
echo "  rm -rf $INSTALL_PREFIX/bin $INSTALL_PREFIX/lib $INSTALL_PREFIX/include $INSTALL_PREFIX/share"
echo ""    