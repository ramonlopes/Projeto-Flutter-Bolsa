import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final GoogleSignIn _google = GoogleSignIn(
    clientId: kIsWeb ? 'SEU_CLIENT_ID_WEB.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );

  final _auth = AuthService();

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final acc = await _google.signIn();
      if (acc == null) return;
      final auth = await acc.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('ID Token não recebido');

      // checagem antes de usar context após awaits
      if (!context.mounted) return;
      final user = await _auth.signInWithGoogle(idToken);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bem-vindo, ${user['nome']}')),
      );
      // if (!context.mounted) return;
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AcoesScreen()));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleSignIn(context),
          child: const Text('Login com Google'),
        ),
      ),
    );
  }
}