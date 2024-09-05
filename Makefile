test:
	$(MAKE) test-ios
	$(MAKE) test-android

test-ios:
	xcodebuild -quiet \
		-workspace example/ios/Runner.xcworkspace \
		-scheme Runner \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 15,OS=17.4' \
		test || exit 1

test-android:
	cd android && ./gradlew :abrevva:testDebugUnitTest || exit 1
