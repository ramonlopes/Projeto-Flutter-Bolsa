import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Para web é recomendado informar o clientId da credencial "Web application"
  final GoogleSignIn _google = GoogleSignIn(
    clientId: kIsWeb ? 'SEU_CLIENT_ID_WEB.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );

  final _auth = AuthService();

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final acc = await _google.signIn();
      if (acc == null) return; // usuário cancelou
      final auth = await acc.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('ID Token não recebido');
      final user = await _auth.signInWithGoogle(idToken);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bem-vindo, ${user['nome']}')),
      );
      // TODO: navegar para a home do app
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AcoesScreen()));
    } catch (e) {
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