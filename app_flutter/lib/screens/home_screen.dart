import 'package:flutter/material.dart';
import 'acoes_screen.dart';
import 'usuarios_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bolsa de Valores - Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AcoesScreen()),
                );
              },
              child: const Text('Ver Ações'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsuariosScreen()),
                );
              },
              child: const Text('Usuários'),
            ),
          ],
        ),
      ),
    );
  }
}
