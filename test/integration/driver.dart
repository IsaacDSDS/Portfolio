import 'package:integration_test/integration_test_driver.dart';

/// Driver for `test/integration/window_performance.dart`. By default it writes
/// the data the test reports (frame timings) to
/// `build/integration_response_data.json`.
Future<void> main() => integrationDriver();
