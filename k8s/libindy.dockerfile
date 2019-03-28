FROM rust:slim as builder

LABEL maintainer="dan@kryha.io"

# install requirements

RUN apt-get update -qq && apt-get install -qq \
    curl git build-essential \
    pkg-config \
    cmake file \
    libssl-dev \
    libsqlite3-dev \
    libzmq3-dev \
    libncursesw5-dev

# necessary: https://github.com/hyperledger/indy-sdk/blob/master/docs/build-guides/ubuntu-build.md

RUN cd /tmp && \
    curl -s https://download.libsodium.org/libsodium/releases/old/libsodium-1.0.14.tar.gz | tar -xz && \
    cd /tmp/libsodium-1.0.14 && \
    ./configure --disable-shared --silent && \
    make --silent && make --silent install && \
    rm -rf /tmp/libsodium-1.0.14

# build libindy

RUN git clone https://github.com/hyperledger/indy-sdk.git && \
    cd ./indy-sdk/libindy && cargo build --release

FROM node:11-stretch-slim

# Add libindy dependencies

RUN apt-get update -qq && apt-get install -qq libzmq3-dev

COPY --from=builder ./indy-sdk/libindy/target/release /usr/lib
