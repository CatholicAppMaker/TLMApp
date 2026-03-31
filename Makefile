PROJECT := LatinMassCompanion.xcodeproj
SCHEME := LatinMassCompanion
SIM_DESTINATION := platform=iOS Simulator,name=iPhone 17
TEST_FLAGS := -parallel-testing-enabled NO -maximum-parallel-testing-workers 1

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
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(SIM_DESTINATION)' CODE_SIGNING_ALLOWED=NO $(TEST_FLAGS) test

quality: catalog format lint build
