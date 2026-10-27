import '../model/app_user.dart';
import '../model/model_utils.dart';
import 'api.dart';

class AuthResult {
  final AppUser user;
  final String token;

  const AuthResult({required this.user, required this.token});
}

class AuthService {
  static Future<AuthResult> login(String email, String password) async {
    final response = await ApiService.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
      handleUnauthorized: false,
    );

    return _bacaHasilAuth(response);
  }

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
      auth: false,
      handleUnauthorized: false,
    );

    return _bacaHasilAuth(response);
  }

  static Future<AppUser> me() async {
    final response = await ApiService.get('/auth/me');
    return _bacaUser(response);
  }

  static Future<AppUser> updateName(String name) async {
    final response = await ApiService.patch(
      '/auth/me',
      body: {'name': name},
    );
    return _bacaUser(response);
  }

  static Future<AuthResult> becomeOrganizer() async {
    final response = await ApiService.post('/auth/become-organizer');
    return _bacaHasilAuth(response);
  }

  static AuthResult _bacaHasilAuth(dynamic response) {
    final body = readMap(response);
    final token = readText(body['token']);

    if (token.isEmpty) {
      throw const ApiException(0, 'Token autentikasi tidak diterima dari server.');
    }

    return AuthResult(user: _bacaUser(response), token: token);
  }

  static AppUser _bacaUser(dynamic response) {
    final body = readMap(response);
    final data = readMap(body['data']);

    if (data.isEmpty) {
      throw const ApiException(0, 'Data pengguna tidak ditemukan.');
    }

    return AppUser.fromJson(data);
  }
}
