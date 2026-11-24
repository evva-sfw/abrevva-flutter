import Foundation

/// Wraps Flutter's legacy not-implemented sentinel behind an Objective-C compatibility function.
enum FlutterConcurrencyCompatibility {
    /// Retrieves Flutter's shared sentinel without importing it as unsafe mutable Swift global state.
    static var methodNotImplemented: NSObject {
        AbrevvaFlutterMethodNotImplemented()
    }
}
