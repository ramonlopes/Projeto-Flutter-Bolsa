import 'package:flutter/material.dart';
import '../models/acao.dart';
import '../services/acao_service.dart';
import '../services/yahoo_finance_service.dart';

class AcaoFormScreen extends StatefulWidget {
  final Acao? acao; // null = criar, não-null = editar

  const AcaoFormScreen({super.key, this.acao});

  @override
  State<AcaoFormScreen> createState() => _AcaoFormScreenState();
}

class _AcaoFormScreenState extends State<AcaoFormScreen> {
  final _formKey = GlobalKey<FormState>(); // ADICIONE
  final _service = AcaoService();
  final _yahoo = YahooFinanceService();
  final _codigoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _precoAtualController = TextEditingController();
  final _precoMedioController = TextEditingController(); // novo
  bool _buscandoPreco = false;

  @override
  void initState() {
    super.initState();
    if (widget.acao != null) {
      _codigoController.text = widget.acao!.codigo;
      _nomeController.text = widget.acao!.nomeEmpresa;
      _precoAtualController.text = (widget.acao!.precoAtual ?? '').toString();
      _precoMedioController.text = (widget.acao!.precoMedio ?? '').toString(); // novo
      // Busca cotação atualizada ao carregar para edição
      Future.microtask(() => _buscarCotacao());
    }
    _codigoController.addListener(_onCodigoChanged);
  }

  @override
  void dispose() {
    _codigoController.removeListener(_onCodigoChanged);
    _codigoController.dispose();
    _nomeController.dispose();
    _precoAtualController.dispose();
    _precoMedioController.dispose(); // novo
    _yahoo.dispose();
    super.dispose();
  }

  Future<void> _onCodigoChanged() async {
    final cod = _codigoController.text.trim();
    if (cod.length < 4) return;
    await _buscarCotacao();
  }

  Future<void> _buscarCotacao() async {
    final cod = _codigoController.text.trim();
    if (cod.isEmpty) return;

    setState(() => _buscandoPreco = true);
    try {
      final preco = await _yahoo.obterCotacao(cod);
      if (!mounted) return;
      if (preco != null) {
        _precoAtualController.text = preco.toStringAsFixed(2);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Não foi possível obter a cotação'),
              duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao buscar cotação: $e'),
            duration: const Duration(seconds: 2)),
      );
    } finally {
      if (mounted) {
        setState(() => _buscandoPreco = false);
      }
    }
  }

  double? _toDouble(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.replaceAll(',', '.'));

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final acao = Acao(
      id: widget.acao?.id ?? 0,
      codigo: _codigoController.text.trim(),
      nomeEmpresa: _nomeController.text.trim(),
      precoAtual: _toDouble(_precoAtualController.text),
      precoMedio: _toDouble(_precoMedioController.text), // novo
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.acao == null ? 'Nova Ação' : 'Editar Ação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                    labelText: 'Código', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                    labelText: 'Empresa', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoAtualController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Preço Atual (opcional)',
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_buscandoPreco)
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Atualizar cotação',
                          onPressed: _buscarCotacao,
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoMedioController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Preço Médio (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calculate),
                ),
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
