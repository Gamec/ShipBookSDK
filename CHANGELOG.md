# Changelog

## [2.0.2]
- Stop retrying `loginSdk` after a 4xx response — broken credentials no longer cause an upload-loop against the server until app restart.
- Fix dead-token-restore loop in `refreshToken`: on a 4xx refresh the SDK now stops retrying instead of restoring the expired token and immediately re-trying.

## [2.0.1]
- Swift 6 compatibility

## [2.0.0]

### Added
- Custom appender support via `ShipBook.registerAppender(type:appenderClass:)`

### Removed
- CocoaPods and Carthage support — SPM is now the only installation method
- tvOS target
