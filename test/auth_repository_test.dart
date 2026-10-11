import 'package:flutter_test/flutter_test.dart';
import 'package:okouran/features/auth/data/mock_auth_repository.dart';

void main() {
  group('MockAuthRepository', () {
    const repository = MockAuthRepository();

    test('finds each demo account by phone', () {
      expect(repository.findByPhone('0708442190')?.user.id, 'u1');
      expect(repository.findByPhone('0708442191')?.user.id, 'u2');
      expect(repository.findByPhone('0000000000'), isNull);
    });

    test('demo accounts retain their commune and login details', () {
      expect(demoAccounts.first.user.commune, 'Cocody');
      expect(demoAccounts.last.user.commune, 'Yopougon');
      expect(demoAccounts.first.password, isNotEmpty);
      expect(demoAccounts.last.password, isNotEmpty);
    });
  });
}
