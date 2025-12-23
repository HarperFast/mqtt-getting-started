#!/usr/bin/env bash

set -euo pipefail

echo "Installing tmux from source..."
echo "This will compile libevent, ncurses, and tmux"
echo ""

# Create a directory
INSTALL_DIR=~/tmux-install
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

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
./configure --prefix=/usr/local --disable-shared
make
sudo make install
cd ..

# Compile ncurses
echo "Compiling ncurses..."
cd ncurses-6.4
./configure --prefix=/usr/local --with-shared --with-cxx-shared --enable-widec
make
sudo make install
cd ..

# Compile tmux
echo "Compiling tmux..."
cd tmux-3.4
./configure --prefix=/usr/local \
    CFLAGS="-I/usr/local/include -I/usr/local/include/ncursesw" \
    LDFLAGS="-L/usr/local/lib" \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
make
sudo make install
cd ..

# Clean up
echo "Cleaning up..."
cd ~
rm -rf "$INSTALL_DIR"

echo ""
echo "Installation complete!"
tmux -V    