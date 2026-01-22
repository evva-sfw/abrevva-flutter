test:
	$(MAKE) test-ios
	$(MAKE) test-android

test-ios:
	DEST_ID=$$(xcrun simctl list devices available | grep "iPhone 16" | sed -E 's/.*\(([-0-9A-F]+)\).*/\1/' | head -n 1); \
	xcodebuild -quiet \
        -workspace example/ios/Runner.xcworkspace \
        -scheme Runner \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,id=$$DEST_ID" \
        test || exit 1;

test-android:
	cd example/android && ./gradlew :abrevva:testDebugUnitTest || exit 1
