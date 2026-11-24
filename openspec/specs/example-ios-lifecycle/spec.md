# example-ios-lifecycle Specification

## Purpose

Defines the startup lifecycle of the Flutter example app on iOS, including compatibility with Apple's required scene-based UIKit lifecycle and continued plugin availability.

## Requirements

### Requirement: Example app launches through a single Flutter scene
The example iOS app MUST launch using a single application window scene on iOS versions that require the UIScene lifecycle, presenting its existing Flutter interface without Flutter's missing-scene-migration error.

#### Scenario: Launch on iOS 27
- **WHEN** the example app is launched on iOS 27 or later
- **THEN** UIKit creates the app's application scene and Flutter presents the existing app interface without the UIScene migration error

### Requirement: Plugins remain available after scene-based startup
The example app MUST register its generated Flutter plugins with the implicit engine during initialization so existing plugin channel calls remain available after scene-based startup.

#### Scenario: Flutter engine initializes for the application scene
- **WHEN** the implicit Flutter engine initializes for the application's scene
- **THEN** generated plugins are registered with that engine before the Flutter interface uses their channels
