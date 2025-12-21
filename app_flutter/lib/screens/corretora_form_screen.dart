import 'package:flutter/material.dart';
import '../models/corretora.dart';
import '../services/corretora_service.dart';

class CorretoraFormScreen extends StatefulWidget {
  final Corretora? corretora; // null = criar, não-null = editar

  const CorretoraFormScreen({super.key, this.corretora});

  @override
  State<CorretoraFormScreen> createState() => _CorretoraFormScreenState();
}

class _CorretoraFormScreenState extends State<CorretoraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CorretoraService();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _taxaController = TextEditingController();
  final _saldoController = TextEditingController(); // novo
  int? _usuarioId; // novo

  @override
  void initState() {
    super.initState();
    if (widget.corretora != null) {
      _nomeController.text = widget.corretora!.nome;
      _cnpjController.text = widget.corretora!.cnpj ?? '';
      _taxaController.text = (widget.corretora!.taxaCorretagem)?.toString() ?? '';
      final saldo = widget.corretora?.saldo ?? 0;
      _saldoController.text = saldo.toStringAsFixed(2);
    }
    _usuarioId = widget.corretora?.usuarioId ?? 0; // valor padrão
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _taxaController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  double? _toDouble(String s) {
    final clean = s.trim().replaceAll(',', '.');
    return clean.isEmpty ? null : double.tryParse(clean);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final corretora = Corretora(
      id: widget.corretora?.id ?? 0,
      nome: _nomeController.text.trim(),
      cnpj: _cnpjController.text.trim().isEmpty ? null : _cnpjController.text.trim(),
      taxaCorretagem: _toDouble(_taxaController.text),
      saldo: double.parse(_saldoController.text.replaceAll(',', '.')),
      usuarioId: _usuarioId,
    );

    try {
      if (widget.corretora == null) {
        await _service.criar(corretora);
      } else {
        final id = widget.corretora?.id;
        if (id == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Corretora sem ID. Não é possível atualizar.')),
          );
          return;
        }
        await _service.atualizar(id, corretora); // id garantido
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro: $e'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.corretora == null ? 'Nova Corretora' : 'Editar Corretora'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.withOpacity(0.06), Colors.teal.shade700.withOpacity(0.06)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance, color: Colors.teal),
                            const SizedBox(width: 8),
                            const Text('Dados da Corretora', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome *',
                            hintText: 'Ex: XP Investimentos',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.business),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cnpjController,
                          decoration: InputDecoration(
                            labelText: 'CNPJ (opcional)',
                            hintText: '00.000.000/0001-00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.badge),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _taxaController,
                          decoration: InputDecoration(
                            labelText: 'Taxa de Corretagem (opcional)',
                            hintText: 'Ex: 10.50',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _saldoController,
                          decoration: InputDecoration(
                            labelText: 'Saldo',
                            prefixIcon: const Icon(Icons.account_balance_wallet),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe o saldo';
                            return double.tryParse(v.replaceAll(',', '.')) == null ? 'Valor inválido' : null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _salvar,
                  icon: const Icon(Icons.check),
                  label: Text(widget.corretora == null ? 'Criar Corretora' : 'Atualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          final corretora = Corretora(
            id: widget.corretora?.id,
            nome: _nomeController.text.trim(),
            cnpj: _cnpjController.text.trim().isEmpty ? null : _cnpjController.text.trim(),
            taxaCorretagem: double.tryParse(_taxaController.text.replaceAll(',', '.')),
            usuarioId: _usuarioId,
            saldo: double.tryParse(_saldoController.text.replaceAll(',', '.')) ?? 0,
          );

          if (widget.corretora == null) {
            await _service.criar(corretora);
          } else {
            final id = widget.corretora?.id;
            if (id == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Corretora sem ID. Não é possível atualizar.')),
              );
              return;
            }
            await _service.atualizar(id, corretora);
          }

          if (!mounted) return;
          Navigator.pop(context, true);
        },
        label: const Text('Salvar'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}