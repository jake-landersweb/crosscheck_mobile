-include .env
export


.DEFAULT_GOAL := help


.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo
	@echo "Available targets:"
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; \
		       {printf "  %-10s %s\n", $$1, $$2}'


.PHONY: build-android
build-android: ## Build the app for android and open the android build folder
	@fvm flutter build appbundle


.PHONY: build-ios
build-ios: ## Build the app for ios and push to the app store
	@fvm flutter build ipa
	$(MAKE) upload-ios


.PHONY: upload-ios
upload-ios: ## Upload a compiled binary to the ios store
	xcrun altool --upload-app --type ios -f ./build/ios/ipa/*.ipa --apiKey $(APPLE_API_KEY) --apiIssuer $(APPLE_ISSUER_ID)


.PHONY: build-android build-ios
build: build-android build-ios ## Build the application for both stores