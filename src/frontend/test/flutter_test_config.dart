import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Flutter Test Configuration
///
/// Configures the test environment for the Naruto Rebirth Game project.
///
/// This configuration file:
/// - Sets up golden file testing
/// - Configures test timeout duration
/// - Initializes test services and mocks
/// - Provides global test utilities

/// Default test timeout duration
const defaultTestTimeout = Duration(minutes: 5);

/// Global test setup before all tests
void main() {
  // Configure test timeout
  setUpAll(() async {
    // Increase timeout for integration tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // Add any global initialization here
    print('✓ Test environment initialized');
  });

  // Global teardown after all tests
  tearDownAll(() async {
    print('✓ Test environment cleaned up');
  });
}

/// Custom test group for unit tests
void unitTest(String description, Future<void> Function() body) {
  test('Unit: $description', () async {
    await body();
  });
}

/// Custom test group for widget tests
void widgetTest(String description, WidgetTesterCallback callback) {
  testWidgets('Widget: $description', callback);
}

/// Custom test group for integration tests
void integrationTest(String description, Future<void> Function() body) {
  test('Integration: $description', () async {
    await body();
  }, timeout: defaultTestTimeout);
}

/// Mock response data generator for API calls
class MockResponseGenerator {
  static Map<String, dynamic> successResponse<T>(T data) {
    return {
      'success': true,
      'data': data,
      'message': 'Success',
    };
  }

  static Map<String, dynamic> errorResponse(String message, int statusCode) {
    return {
      'success': false,
      'error': message,
      'statusCode': statusCode,
    };
  }
}
