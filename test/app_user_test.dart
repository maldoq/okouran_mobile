import 'package:flutter_test/flutter_test.dart';
import 'package:okouran/features/auth/domain/app_user.dart';

void main() {
  group('AppUser', () {
    const user = AppUser(
      id: 'test-user',
      firstName: 'Aya Marie',
      lastName: 'Kouassi',
      phone: '0708442190',
      email: 'aya@example.com',
    );

    test('builds initials from the first and last names', () {
      expect(user.initials, 'AK');
    });

    test('copyWith updates profile fields and can clear optional data', () {
      final updated = user.copyWith(
        firstName: 'Aya',
        clearEmail: true,
        clearCommune: true,
        isVerified: true,
      );

      expect(updated.firstName, 'Aya');
      expect(updated.lastName, 'Kouassi');
      expect(updated.phone, user.phone);
      expect(updated.email, isNull);
      expect(updated.commune, isNull);
      expect(updated.isVerified, isTrue);
    });
  });
}
