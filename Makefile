.PHONY: build build-release run clean analyze test

# Required environment variables
ifndef GOOGLE_CLIENT_ID
$(error GOOGLE_CLIENT_ID is not set)
endif

# Configuration
POCKETBASE_URL ?= https://admin.geoffjay.com
GOOGLE_REDIRECT_URI ?= $(POCKETBASE_URL)/api/oauth2-redirect

all: build

# Build release APK
build: build-release

build-release:
	flutter build apk \
		--dart-define=POCKETBASE_URL=$(POCKETBASE_URL) \
		--dart-define=GOOGLE_SERVER_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		--dart-define=GOOGLE_REDIRECT_URI=$(GOOGLE_REDIRECT_URI)

# Build debug APK for local development
build-debug:
	flutter build apk --debug \
		--dart-define=POCKETBASE_URL=http://127.0.0.1:8090 \
		--dart-define=GOOGLE_SERVER_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		--dart-define=GOOGLE_REDIRECT_URI=http://127.0.0.1:8090/api/oauth2-redirect

# Run on connected device (debug mode, local PocketBase)
run:
	flutter run \
		--dart-define=POCKETBASE_URL=http://127.0.0.1:8090 \
		--dart-define=GOOGLE_SERVER_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		--dart-define=GOOGLE_REDIRECT_URI=http://127.0.0.1:8090/api/oauth2-redirect

# Run on connected device (release mode, production PocketBase)
run-release:
	flutter run --release \
		--dart-define=POCKETBASE_URL=$(POCKETBASE_URL) \
		--dart-define=GOOGLE_SERVER_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		--dart-define=GOOGLE_REDIRECT_URI=$(GOOGLE_REDIRECT_URI)

# Install release APK on connected device
install: build-release
	flutter install

# Static analysis
analyze:
	flutter analyze

# Run tests
test:
	flutter test

# Clean build artifacts
clean:
	flutter clean

# Get dependencies
deps:
	flutter pub get
