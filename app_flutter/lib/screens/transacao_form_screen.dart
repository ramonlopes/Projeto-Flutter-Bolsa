import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../services/transacao_service.dart';
import '../services/usuario_service.dart';
import '../services/acao_service.dart';
import '../models/usuario.dart';
import '../models/acao.dart';

class TransacaoFormScreen extends StatefulWidget {
  final Transacao? transacao; // null = criar, não-null = editar

  const TransacaoFormScreen({super.key, this.transacao});

  @override
  State<TransacaoFormScreen> createState() => _TransacaoFormScreenState();
}

class _TransacaoFormScreenState extends State<TransacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transacaoService = TransacaoService();
  final _usuarioService = UsuarioService();
  final _acaoService = AcaoService();

  int? _selectedUsuarioId;
  int? _selectedAcaoId;
  String _tipo = 'compra';
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  List<Usuario> _usuarios = [];
  List<Acao> _acoes = [];
  bool _loading = true;

  bool get _isEdicao => widget.transacao != null;

  @override
  void initState() {
    super.initState();
    if (_isEdicao) {
      _selectedUsuarioId = widget.transacao!.usuarioId;
      _selectedAcaoId = widget.transacao!.acaoId;
      _tipo = widget.transacao!.tipo;
      _quantidadeController.text = widget.transacao!.quantidade.toString();
      _precoController.text = widget.transacao!.precoUnitario.toString();
    }
    _carregarDados();
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final usuarios = await _usuarioService.listarUsuarios();
      final acoes = await _acaoService.listarAcoes();
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _acoes = acoes;
        _loading = false;
        if (!_isEdicao) {
          if (_usuarios.isNotEmpty) _selectedUsuarioId = _usuarios.first.id;
          if (_acoes.isNotEmpty) _selectedAcaoId = _acoes.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUsuarioId == null || _selectedAcaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione usuário e ação')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final transacao = Transacao(
        id: widget.transacao?.id,
        usuarioId: _selectedUsuarioId!,
        acaoId: _selectedAcaoId!,
        tipo: _tipo,
        quantidade: int.parse(_quantidadeController.text),
        precoUnitario: double.parse(_precoController.text),
      );

      if (_isEdicao) {
        await _transacaoService.atualizarTransacao(widget.transacao!.id!, transacao);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Transação atualizada com sucesso')),
        );
      } else {
        await _transacaoService.criarTransacao(transacao);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Transação criada com sucesso')),
        );
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao salvar transação: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Transação' : 'Nova Transação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedUsuarioId,
                decoration: const InputDecoration(labelText: 'Usuário'),
                items: _usuarios
                    .map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(u.nome),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedUsuarioId = val),
                validator: (val) => val == null ? 'Selecione um usuário' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedAcaoId,
                decoration: const InputDecoration(labelText: 'Ação'),
                items: _acoes
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.codigo} - ${a.nomeEmpresa}'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedAcaoId = val),
                validator: (val) => val == null ? 'Selecione uma ação' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'compra', child: Text('Compra')),
                  DropdownMenuItem(value: 'venda', child: Text('Venda')),
                ],
                onChanged: (val) => setState(() => _tipo = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Obrigatório';
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) return 'Deve ser > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(labelText: 'Preço Unitário'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Obrigatório';
                  final n = double.tryParse(val);
                  if (n == null || n <= 0) return 'Deve ser > 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(_isEdicao ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}