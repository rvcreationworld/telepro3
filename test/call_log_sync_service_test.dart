import 'package:flutter_test/flutter_test.dart';
import 'package:telepro3/src/services/call_log_sync_service.dart';

void main() {
  test('normalizes readable international numbers', () {
    expect(
      CallLogSyncService.normalizeNumber('+91 98765-43210'),
      '+919876543210',
    );
  });

  test('keeps local numbers as digits for server-side normalization', () {
    expect(
      CallLogSyncService.normalizeNumber('(0987) 654 3210'),
      '09876543210',
    );
  });
}
