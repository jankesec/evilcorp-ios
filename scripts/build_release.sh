#!/bin/sh
set -eu

version=${VERSION:-}
case "$version" in
  v[0-9]*.[0-9]*.[0-9]*) ;;
  *)
    echo "VERSION must be a semantic tag such as v1.1.0" >&2
    exit 1
    ;;
esac

dist_dir=${DIST_DIR:-dist}
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

xcodegen generate
xcodebuild \
  -project EvilCorp.xcodeproj \
  -scheme EvilCorp \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  CONFIGURATION_BUILD_DIR="$work_dir/build" \
  build

mkdir -p "$work_dir/Payload" "$dist_dir"
dist_path=$(cd "$dist_dir" && pwd)
cp -R "$work_dir/build/EvilCorp.app" "$work_dir/Payload/EvilCorp.app"
(
  cd "$work_dir"
  /usr/bin/zip -qry "$dist_path/EvilCorp-${version#v}-unsigned.ipa" Payload
)

git archive \
  --format=tar.gz \
  --prefix="evilcorp-ios-${version#v}/" \
  --output="$dist_path/evilcorp-ios-${version#v}-source.tar.gz" \
  HEAD

(
  cd "$dist_path"
  shasum -a 256 *.ipa *.tar.gz > checksums.txt
)
