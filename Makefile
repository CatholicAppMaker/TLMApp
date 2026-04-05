PROJECT := LatinMassCompanion.xcodeproj
SCHEME := LatinMassCompanion
SIM_DESTINATION := platform=iOS Simulator,name=iPhone 17
TEST_FLAGS := -parallel-testing-enabled NO -maximum-parallel-testing-workers 1
TEST_COMMAND = xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(SIM_DESTINATION)' CODE_SIGNING_ALLOWED=NO $(TEST_FLAGS)
UI_TEST_TARGET := LatinMassCompanionUITests/LatinMassCompanionUITests
FLOW_UI_TEST_TARGET := LatinMassCompanionUITests/LatinMassCompanionFlowUITests
APPEARANCE_UI_TEST := $(UI_TEST_TARGET)/testAppearanceTogglePersistsDarkModeWithoutBreakingGuide
BOOKMARK_UI_TEST := $(UI_TEST_TARGET)/testBookmarkAppearsInLibraryBookmarks

.PHONY: catalog format lint build test quality

catalog:
	python3 scripts/build_mass_catalog.py

format:
	swiftformat .

lint:
	swiftlint lint --config .swiftlint.yml

build:
	$(MAKE) catalog
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

test:
	$(MAKE) catalog
	$(TEST_COMMAND) -only-testing:LatinMassCompanionTests test
	$(TEST_COMMAND) -only-testing:$(FLOW_UI_TEST_TARGET) test
	$(TEST_COMMAND) -only-testing:$(APPEARANCE_UI_TEST) test
	$(TEST_COMMAND) -only-testing:$(BOOKMARK_UI_TEST) test
	$(TEST_COMMAND) -only-testing:$(UI_TEST_TARGET) -skip-testing:$(APPEARANCE_UI_TEST) -skip-testing:$(BOOKMARK_UI_TEST) test

quality: catalog format lint build
