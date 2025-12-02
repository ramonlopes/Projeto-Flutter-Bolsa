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
  final _nomeController = TextEditingController();
  final _precoAtualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.acao != null) {
      _codigoController.text = widget.acao!.codigo;
      _nomeController.text = widget.acao!.nomeEmpresa;
      _precoAtualController.text = (widget.acao!.precoAtual ?? '').toString();
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    _precoAtualController.dispose();
    super.dispose();
  }

  double? _toDouble(String s) => s.trim().isEmpty ? null : double.tryParse(s.replaceAll(',', '.'));

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final acao = Acao(
      id: widget.acao?.id ?? 0,
      codigo: _codigoController.text.trim(),
      nomeEmpresa: _nomeController.text.trim(),
      precoAtual: _toDouble(_precoAtualController.text),
    );

    try {
      if (widget.acao == null) {
        await _service.criarAcao(acao);
      } else {
        await _service.atualizarAcao(widget.acao!.id, acao);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.acao == null ? 'Nova Ação' : 'Editar Ação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Empresa', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoAtualController,
                decoration: const InputDecoration(labelText: 'Preço Atual (opcional)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}