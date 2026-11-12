.PHONY: build catalog-check check format project release-artifacts test test-build typecheck

PROJECT := EvilCorp.xcodeproj
SCHEME := EvilCorp
DESTINATION ?= $(shell ./scripts/simulator_destination.sh)

project:
	xcodegen generate

catalog-check:
	@tmp_dir="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmp_dir"' EXIT; \
	xcrun swiftc EvilCorp/EvilCorpChallenge.swift EvilCorp/AppMetadata.swift \
		scripts/catalog_check.swift -o "$$tmp_dir/catalog-check"; \
	"$$tmp_dir/catalog-check"

typecheck:
	xcrun swiftc -typecheck \
		-sdk "$$(xcrun --sdk iphonesimulator --show-sdk-path)" \
		-target arm64-apple-ios16.0-simulator \
		-parse-as-library EvilCorp/*.swift

build: project
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'generic/platform=iOS Simulator' \
		CODE_SIGNING_ALLOWED=NO build

release-artifacts:
	VERSION=$(VERSION) ./scripts/build_release.sh

test: project
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' test

test-build: project
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'generic/platform=iOS Simulator' \
		CODE_SIGNING_ALLOWED=NO build-for-testing

format:
	xcrun swift-format format --in-place --recursive EvilCorp EvilCorpTests

check: catalog-check typecheck test-build
