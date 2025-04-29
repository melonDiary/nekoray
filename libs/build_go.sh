#!/bin/bash
set -e

source libs/env_deploy.sh
[ "$GOOS" == "windows" ] && [ "$GOARCH" == "amd64" ] && DEST=$DEPLOYMENT/windows64 || true
[ "$GOOS" == "windows" ] && [ "$GOARCH" == "arm64" ] && DEST=$DEPLOYMENT/windows-arm64 || true
[ "$GOOS" == "linux" ] && [ "$GOARCH" == "amd64" ] && DEST=$DEPLOYMENT/linux64 || true
[ "$GOOS" == "linux" ] && [ "$GOARCH" == "arm64" ] && DEST=$DEPLOYMENT/linux-arm64 || true
[ "$GOOS" == "darwin" ] && [ "$GOARCH" == "amd64" ] && DEST=$DEPLOYMENT/macos64 || true
[ "$GOOS" == "darwin" ] && [ "$GOARCH" == "arm64" ] && DEST=$DEPLOYMENT/macos-arm64 || true

if [ -z $DEST ]; then
  echo "Please set GOOS GOARCH"
  exit 1
fi
rm -rf $DEST
mkdir -p $DEST

export CGO_ENABLED=0

#### Go: updater ####
pushd go/cmd/updater
[ "$GOOS" == "darwin" ] && go build -o $DEST/updater -trimpath -ldflags "-w -s" || true
[ "$GOOS" == "linux" ] && mv $DEST/updater $DEST/launcher || true
popd

#### Go: nekobox_core ####
pushd go/cmd/nekobox_core
go build -v -o $DEST/nekobox_core -trimpath -ldflags "-w -s -X github.com/matsuridayo/libneko/neko_common.Version_neko=$version_standalone" -tags "with_clash_api,with_gvisor,with_quic,with_wireguard,with_utls,with_ech"
popd