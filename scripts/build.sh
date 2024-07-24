#!/bin/bash

PROJECT_DIR==$FUZZ_DIR
INSTALL_DIR=$PROJECT_DIR/install

cd $PROJECT_DIR/xpdf-3.02

rm -rf $INSTALL_DIR
mkdir $INSTALL_DIR

sudo apt update && sudo apt install -y build-essential gcc

# AFL
export FUZZ_AFL_DIR=$INSTALL_DIR/afl
make clean
CC='afl-clang-fast' CXX='afl-clang-fast++' ./configure --prefix="$FUZZ_AFL_DIR/"
make
make install

# AFL & ASAN
export FUZZ_ASAN_DIR=$INSTALL_DIR/afl-asan
make clean
AFL_USE_ASAN=1 CC='afl-clang-fast' CXX='afl-clang-fast++' ./configure --prefix="$FUZZ_ASAN_DIR/"
make
make install

# AFL & Coverage
export FUZZ_COV_DIR=$INSTALL_DIR/afl-cov
make clean
CC='clang -fprofile-instr-generate -fcoverage-mapping' CXX='clang++ -fprofile-instr-generate -fcoverage-mapping' ./configure --prefix="$FUZZ_COV_DIR/"
make
make install