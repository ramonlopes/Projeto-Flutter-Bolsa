import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'transacoes_screen.dart';
import 'acoes_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  String _nomeUsuario = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await _authService.getUsuario();
    if (usuario != null && mounted) {
      setState(() => _nomeUsuario = usuario.nome);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bolsa de Valores')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_nomeUsuario),
              accountEmail: const Text(''),
              currentAccountPicture: CircleAvatar(
                child: Text(_nomeUsuario.isNotEmpty ? _nomeUsuario[0].toUpperCase() : 'U'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Transações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TransacoesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Ações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AcoesScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Bem-vindo! Use o menu lateral.')),
    );
  }
}
