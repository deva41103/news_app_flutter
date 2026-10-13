import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  bool build() {
    final box = Hive.box('auth');
    return box.get('isLoggedIn', defaultValue: false);
  }

  Future<void> login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      final box = Hive.box('auth');
      await box.put('isLoggedIn', true);
      state = true;
    }
  }

  Future<void> logout() async {
    final box = Hive.box('auth');
    await box.put('isLoggedIn', false);
    state = false;
  }
}
