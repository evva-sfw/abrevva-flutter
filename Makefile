test:
	$(MAKE) test-ios
	$(MAKE) test-android

test-ios:
	xcodebuild -quiet \
		-workspace example/ios/Runner.xcworkspace \
		-scheme Runner \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,OS=18.0,name=iPhone 16' \
		test || exit 1

test-android:
	cd example/android && ./gradlew :abrevva:testDebugUnitTest || exit 1
