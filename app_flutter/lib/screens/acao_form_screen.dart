import 'package:flutter/material.dart';
import '../models/acao.dart';
import '../services/acao_service.dart';

class AcaoFormScreen extends StatefulWidget {
  final Acao? acao; // null = criar, não-null = editar

  const AcaoFormScreen({super.key, this.acao});

  @override
  State<AcaoFormScreen> createState() => _AcaoFormScreenState();
}

class _AcaoFormScreenState extends State<AcaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AcaoService();

  final _codigoController = TextEditingController();
  final _nomeEmpresaController = TextEditingController();
  final _precoAtualController = TextEditingController();

  bool get _isEdicao => widget.acao != null;

  @override
  void initState() {
    super.initState();
    if (_isEdicao) {
      _codigoController.text = widget.acao!.codigo;
      _nomeEmpresaController.text = widget.acao!.nomeEmpresa;
      _precoAtualController.text = widget.acao!.precoAtual.toString();
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeEmpresaController.dispose();
    _precoAtualController.dispose();
    super.dispose();
  }

  double? _toDouble(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final acao = Acao(
        id: widget.acao?.id ?? 0,
        codigo: _codigoController.text.trim().toUpperCase(),
        nomeEmpresa: _nomeEmpresaController.text.trim(),
        precoAtual: _toDouble(_precoAtualController.text)!,
      );

      if (_isEdicao) {
        await _service.atualizarAcao(widget.acao!.id, acao);
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Ação atualizada')));
      } else {
        await _service.criarAcao(acao);
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Ação criada')));
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdicao ? 'Editar Ação' : 'Nova Ação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código da Ação',
                  hintText: 'Ex.: PETR4, VALE3',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeEmpresaController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Empresa',
                  hintText: 'Ex.: Petrobras PN',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoAtualController,
                decoration: const InputDecoration(
                  labelText: 'Preço Atual (R\$)',
                  hintText: 'Ex.: 37.20',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Obrigatório';
                  final n = _toDouble(val);
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