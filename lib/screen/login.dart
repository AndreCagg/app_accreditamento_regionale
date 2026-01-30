import 'package:accreditamento/screen/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final String clientId = "admin-accreditamento-app";

  final String redirectUri = "com.example.accreditamento://login-callback";

  final String issuer = "http://10.0.2.2:8180/realms/users";

  Future<void> login() async {
    try {
      final AuthorizationTokenResponse? result = await appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              clientId,
              redirectUri,
              issuer: issuer,
              scopes: ["openid", "profile", "email", "offline_access"],
              allowInsecureConnections: true,
            ),
          );

      if (result != null) {
        //Provider.of<IdentityProvider>(context, listen: false).piva = piva;
        /*Provider.of<IdentityProvider>(context, listen: false).token =
            result.accessToken!;
        Provider.of<IdentityProvider>(context, listen: false).refreshToken =
            result.refreshToken!;
        Provider.of<IdentityProvider>(context, listen: false).idToken =
            result.idToken!;*/

        await secureStorage.write(
          key: "access_token",
          value: result.accessToken,
        );
        await secureStorage.write(
          key: "refresh_token",
          value: result.refreshToken,
        );

        print("Access Token: ${result.accessToken}");
        print("Refresh Token: ${result.refreshToken}");
        print("ID Token: ${result.idToken}");
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Welcome();
          },
        ),
      );
    } catch (e) {
      print("Login fallito: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login funzionario regionale")),
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: FilledButton(onPressed: login, child: Text("Login")),
        ),
      ),
    );
  }
}
