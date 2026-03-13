FLUTTER := flutter

.PHONY: get analyze test test-integration coverage quality quality-full

get:
	$(FLUTTER) pub get

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

test-integration:
	$(FLUTTER) test integration_test -d macos

coverage:
	$(FLUTTER) test --coverage

quality:
	dart format --output=none --set-exit-if-changed lib test integration_test
	$(FLUTTER) analyze
	$(FLUTTER) test --coverage

quality-full:
	dart format --output=none --set-exit-if-changed lib test integration_test
	$(FLUTTER) analyze
	$(FLUTTER) test --coverage
	$(FLUTTER) test integration_test -d macos
