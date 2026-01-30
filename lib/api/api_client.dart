import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
final storage = FlutterSecureStorage();

class ApiClient {
  final String baseUrl;
  final storage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl});

  Future<http.Response> get(String path) async {
    return _sendRequest("GET", path);
  }

  Future<http.Response> patch(String path) async {
    return _sendRequest("PATCH", path);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return _sendRequest("POST", path, body: body);
  }

  Future<http.Response> _sendRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    String? accessToken = await storage.read(key: "access_token");

    Map<String, String> headers = {"Content-Type": "application/json"};
    if (accessToken != null) headers["Authorization"] = "Bearer $accessToken";

    late http.Response response;
    switch (method) {
      case "GET":
        response = await http.get(Uri.parse("$baseUrl$path"), headers: headers);
        break;
      case "POST":
        response = await http.post(
          Uri.parse("$baseUrl$path"),
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      case "PATCH":
        response = await http.patch(
          Uri.parse("$baseUrl$path"),
          headers: headers,
        );
        break;
    }

    // non autorizzato, ritento
    if (response.statusCode == 401) {
      final refreshToken = await storage.read(key: "refresh_token");
      if (refreshToken != null) {
        final success = await _refreshTokens(refreshToken);
        if (success) {
          accessToken = await storage.read(key: "access_token");
          headers["Authorization"] = "Bearer $accessToken";
          switch (method) {
            case "GET":
              response = await http.get(
                Uri.parse("$baseUrl$path"),
                headers: headers,
              );
              break;
            case "POST":
              response = await http.post(
                Uri.parse("$baseUrl$path"),
                headers: headers,
                body: jsonEncode(body),
              );
              break;
            case "PATCH":
              response = await http.patch(
                Uri.parse("$baseUrl$path"),
                headers: headers,
              );
              break;
          }
        }
      }
    }

    return response;
  }

  Future<bool> _refreshTokens(String refreshToken) async {
    try {
      final TokenResponse? response = await appAuth.token(
        TokenRequest(
          "admin-accreditamento-app",
          "com.example.accreditamento://login-callback",
          refreshToken: refreshToken,
          issuer: "http://10.0.2.2:8180/realms/users",
          allowInsecureConnections: true,
        ),
      );

      if (response != null) {
        final newAccessToken = response.accessToken;
        final newRefreshToken = response.refreshToken;

        await storage.write(key: "access_token", value: newAccessToken);
        await storage.write(key: "refresh_token", value: newRefreshToken);

        return true;
      }
    } catch (e) {
      print("Errore nel refresh token: $e");
    }

    return false;
  }
}
