import 'dart:async';

class AuthService {
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {

    await Future.delayed(const Duration(milliseconds: 900));
    const demoEmail = 'admin@gmail.com';
    const demoPass = 'Paddushafiya';

    final ok = (email == demoEmail && password == demoPass);

    return ok;
  }
}
