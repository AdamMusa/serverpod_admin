# Serverpod Admin Dashboard Tests

This directory contains tests for the `serverpod_admin_dashboard` package.

## Test Structure

- `widget/` - Widget tests for UI components
- `unit/` - Unit tests for controllers and business logic (when applicable)

## Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/widget/user_avatar_test.dart
```

## Test Coverage

### Widget Tests

- **user_avatar_test.dart** - Tests for the UserAvatar widget
- **user_info_display_test.dart** - Tests for the UserInfoDisplay widget
- **user_menu_item_test.dart** - Tests for the UserMenuItem model and extension
- **coming_soon_dialog_test.dart** - Tests for the ComingSoonDialog widget

### Notes

- Controller tests (like `AuthController`) require complex mocking of Serverpod client instances and are better suited for integration tests with a real server setup.
- Widget tests use Flutter's test framework and can be run without a server connection.

