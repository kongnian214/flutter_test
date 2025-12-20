import 'package:flutter_test/flutter_test.dart';
import 'package:lcs1/some_service.dart';

void main() {
  group('SomeService', () {
    test('returns doubled value', () {
      final service = SomeService();
      expect(service.doubleIt(3), 6);
    });
  });
}
