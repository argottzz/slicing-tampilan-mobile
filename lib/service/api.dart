import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  bool get unauthorized => statusCode == 401;
  bool get forbidden => statusCode == 403;

  @override
  String toString() => message;
}

class ApiService {
  static const String _tokenKey = 'gatix_token';

  static void Function()? onUnauthorized;

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _headers({
    bool auth = true,
    bool json = true,
  }) async {
    final token = auth ? await getToken() : null;

    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Uri _uri(String endpoint, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$apiBaseUrl$endpoint');

    if (query == null || query.isEmpty) return uri;

    final params = <String, String>{};
    query.forEach((key, value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isNotEmpty) params[key] = text;
    });

    if (params.isEmpty) return uri;
    return uri.replace(queryParameters: params);
  }

  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) {
    return _send(() async {
      final response = await http.get(
        _uri(endpoint, query),
        headers: await _headers(auth: auth),
      );
      return response;
    });
  }

  static Future<dynamic> post(
    String endpoint, {
    Object? body,
    bool auth = true,
    bool handleUnauthorized = true,
  }) {
    return _send(
      () async {
        final response = await http.post(
          _uri(endpoint),
          headers: await _headers(auth: auth),
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
        return response;
      },
      handleUnauthorized: handleUnauthorized,
    );
  }

  static Future<dynamic> patch(
    String endpoint, {
    Object? body,
    bool auth = true,
    bool handleUnauthorized = true,
  }) {
    return _send(
      () async {
        final response = await http.patch(
          _uri(endpoint),
          headers: await _headers(auth: auth),
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
        return response;
      },
      handleUnauthorized: handleUnauthorized,
    );
  }

  static Future<dynamic> delete(String endpoint, {bool auth = true}) {
    return _send(() async {
      final response = await http.delete(
        _uri(endpoint),
        headers: await _headers(auth: auth),
      );
      return response;
    });
  }

  static Future<dynamic> multipart(
    String method,
    String endpoint, {
    Map<String, String> fields = const {},
    String fileField = 'file',
    Uint8List? fileBytes,
    String? fileName,
  }) {
    return _send(() async {
      final request = http.MultipartRequest(method, _uri(endpoint));
      request.headers.addAll(await _headers(json: false));

      if (fields.isNotEmpty) request.fields.addAll(fields);

      if (fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
            contentType: _mediaType(fileName),
          ),
        );
      }

      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
  }

  static MediaType _mediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    return MediaType('image', 'jpeg');
  }

  static Future<dynamic> _send(
    Future<http.Response> Function() request, {
    bool handleUnauthorized = true,
  }) async {
    try {
      final response = await request().timeout(apiTimeout);
      return _processResponse(
        response,
        handleUnauthorized: handleUnauthorized,
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        0,
        'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } catch (_) {
      throw const ApiException(
        0,
        'Tidak dapat terhubung ke server. Pastikan backend berjalan.',
      );
    }
  }

  static dynamic _processResponse(
    http.Response response, {
    required bool handleUnauthorized,
  }) {
    dynamic body;

    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    final sukses = response.statusCode >= 200 && response.statusCode < 300;

    if (sukses) return body;

    if (response.statusCode == 401 && handleUnauthorized) {
      onUnauthorized?.call();
    }

    throw ApiException(
      response.statusCode,
      _pesanError(body, response.statusCode),
    );
  }

  static String _pesanError(dynamic body, int statusCode) {
    if (body is Map) {
      final pesan = body['message']?.toString().trim();
      final detail = _detailValidasi(body);

      if (pesan != null && pesan.isNotEmpty) {
        if (detail != null && pesan == 'Data tidak valid') {
          return '$pesan: $detail';
        }
        return pesan;
      }

      if (detail != null) return detail;
    }

    if (body is String && body.trim().isNotEmpty) return body.trim();

    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid.';
      case 401:
        return 'Sesi berakhir. Silakan login kembali.';
      case 403:
        return 'Kamu tidak memiliki akses untuk tindakan ini.';
      case 404:
        return 'Data tidak ditemukan.';
      case 429:
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 500:
        return 'Terjadi kesalahan pada server.';
      default:
        return 'Permintaan gagal (kode $statusCode).';
    }
  }

  static String? _detailValidasi(Map body) {
    final daftar = body['error'] ?? body['errors'];
    if (daftar is! List || daftar.isEmpty) return null;

    final pertama = daftar.first;
    if (pertama is Map) {
      final pesan = pertama['message']?.toString();
      if (pesan != null && pesan.isNotEmpty) return pesan;
    }

    return pertama.toString();
  }
}
