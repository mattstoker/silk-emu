import 'package:cricut_silkemu/silkemu.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    final _ = ensureLoaded;
  });

  group('SilkEmuTests', () {
    test('notMuch', () {
      expect(2 + 2, equals(4));
    });
  });
}
