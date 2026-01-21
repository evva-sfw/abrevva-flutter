test:
	$(MAKE) test-ios
	$(MAKE) test-android

test-ios:
	xcodebuild \
		-workspace example/ios/Runner.xcworkspace \
		-scheme Runner \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 17' \
		test || exit 1

test-android:
	cd example/android && ./gradlew :abrevva:testDebugUnitTest || exit 1
