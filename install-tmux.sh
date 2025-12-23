#!/bin/bash -x

# Create a directory
mkdir ~/tmux-install
cd ~/tmux-install

# Get the files
curl -OL https://www.openssl.org/source/openssl-1.0.2l.tar.gz
curl -OL https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz
curl -OL https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz

# Extract them
tar xzf openssl-1.0.2l.tar.gz
tar xzf tmux-2.3.tar.gz
tar xzf libevent-2.0.22-stable.tar.gz

# Compile openssl
cd openssl-1.0.2l
./Configure darwin64-x86_64-cc --prefix=/usr/local 
make CFLAGS='-I/usr/local/ssl/include'
make test
sudo make install

# Compile libevent
cd ../libevent-2.0.22-stable
./configure 
make
sudo make install

# Compile tmux
cd ../tmux-2.3
LDFLAGS="-L/usr/local/lib" CPPFLAGS="-I/usr/local/include" LIBS="-lresolv" ./configure --prefix=/usr/local
make
sudo make install

# Clean up
cd ~
rm -rf ~/tmux-install    