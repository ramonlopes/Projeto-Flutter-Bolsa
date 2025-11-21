import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  late Future<List<Usuario>> _futuro;
  final service = UsuarioService();

  @override
  void initState() {
    super.initState();
    _futuro = service.listarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: FutureBuilder<List<Usuario>>(
        future: _futuro,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhum usuário'));
          }
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final u = lista[i];
              return ListTile(
                title: Text(u.nome),
                subtitle: Text(u.email),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Exemplo simples de criação
          try {
            final novo = await service.criarUsuario(
              Usuario(nome: 'Teste ${DateTime.now().millisecondsSinceEpoch}', email: 'teste${DateTime.now().millisecondsSinceEpoch}@mail.com', senha: '123'),
            );
            setState(() {
              _futuro = service.listarUsuarios();
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Criado: ${novo.email}')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}