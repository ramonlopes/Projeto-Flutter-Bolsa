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

  // Seleções básicas
  int? _selectedUsuarioId;
  int? _selectedAcaoId;
  String _tipo = 'compra'; // 'compra' | 'venda'
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  // Opções (derivativos)
  String? _tipoOperacao; // null | 'PUT' | 'CALL'
  final _nomeOpcaoController = TextEditingController();
  final _valorMercadoController = TextEditingController();
  final _valorStrikeController = TextEditingController();

  // Novos campos
  DateTime? _dataExercicio;
  final _porcentagemPremioController = TextEditingController();
  final _valorPremioLiquidoController = TextEditingController();
  final _percentualRetornoController = TextEditingController();
  final _percentualRetornoLiquidoController = TextEditingController();
  final _situacaoMomentoController = TextEditingController();
  final _valorCoberturalController = TextEditingController();
  bool _exercidoOperacao = false;
  final _corretoraOperadaController = TextEditingController();
  final _valorIrrrfController = TextEditingController();

  List<Usuario> _usuarios = [];
  List<Acao> _acoes = [];
  bool _loading = true;

  bool get _isEdicao => widget.transacao != null;

  @override
  void initState() {
    super.initState();
    // Pré-carrega valores em caso de edição
    final t = widget.transacao;
    if (t != null) {
      _selectedUsuarioId = t.usuarioId;
      _selectedAcaoId = t.acaoId;
      _tipo = t.tipo;
      _quantidadeController.text = t.quantidade.toString();
      _precoController.text = t.precoUnitario.toString();

      _tipoOperacao = t.tipoOperacao;
      _nomeOpcaoController.text = t.nomeOpcao ?? '';
      _valorMercadoController.text = t.valorMercado?.toString() ?? '';
      _valorStrikeController.text = t.valorStrike?.toString() ?? '';

      _dataExercicio = t.dataExercicio;
      _porcentagemPremioController.text = t.porcentagemPremio?.toString() ?? '';
      _valorPremioLiquidoController.text = t.valorPremioLiquido?.toString() ?? '';
      _percentualRetornoController.text = t.percentualRetorno?.toString() ?? '';
      _percentualRetornoLiquidoController.text = t.percentualRetornoLiquido?.toString() ?? '';
      _situacaoMomentoController.text = t.situacaoMomento?.toString() ?? '';
      _valorCoberturalController.text = t.valorCobertural?.toString() ?? '';
      _exercidoOperacao = t.exercidoOperacao ?? false;
      _corretoraOperadaController.text = t.corretoraOperada ?? '';
      _valorIrrrfController.text = t.valorIrrrf?.toString() ?? '';
    }
    _carregarDados();
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _precoController.dispose();
    _nomeOpcaoController.dispose();
    _valorMercadoController.dispose();
    _valorStrikeController.dispose();
    _porcentagemPremioController.dispose();
    _valorPremioLiquidoController.dispose();
    _percentualRetornoController.dispose();
    _percentualRetornoLiquidoController.dispose();
    _situacaoMomentoController.dispose();
    _valorCoberturalController.dispose();
    _corretoraOperadaController.dispose();
    _valorIrrrfController.dispose();
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

  double? _toDouble(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.trim().replaceAll(',', '.'));

  String _formatYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDataExercicio() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataExercicio ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _dataExercicio = picked);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_usuarios.isEmpty || _acoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre/seed de usuários e ações antes.')),
      );
      return;
    }
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
        precoUnitario: double.parse(_precoController.text.replaceAll(',', '.')),
        tipoOperacao: _tipoOperacao,
        nomeOpcao: _nomeOpcaoController.text.isEmpty ? null : _nomeOpcaoController.text,
        valorMercado: _toDouble(_valorMercadoController.text),
        valorStrike: _toDouble(_valorStrikeController.text),

        dataExercicio: _dataExercicio,
        porcentagemPremio: _toDouble(_porcentagemPremioController.text),
        valorPremioLiquido: _toDouble(_valorPremioLiquidoController.text),
        percentualRetorno: _toDouble(_percentualRetornoController.text),
        percentualRetornoLiquido: _toDouble(_percentualRetornoLiquidoController.text),
        situacaoMomento: _toDouble(_situacaoMomentoController.text),
        valorCobertural: _toDouble(_valorCoberturalController.text),
        exercidoOperacao: _exercidoOperacao,
        corretoraOperada: _corretoraOperadaController.text.isEmpty ? null : _corretoraOperadaController.text,
        valorIrrrf: _toDouble(_valorIrrrfController.text),
      );

      if (_isEdicao) {
        await _transacaoService.atualizarTransacao(widget.transacao!.id!, transacao);
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Transação atualizada')));
      } else {
        await _transacaoService.criarTransacao(transacao);
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Transação criada')));
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdicao ? 'Editar Transação' : 'Nova Transação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Usuário
              DropdownButtonFormField<int>(
                value: _selectedUsuarioId,
                decoration: const InputDecoration(labelText: 'Usuário'),
                items: _usuarios
                    .map((u) => DropdownMenuItem(value: u.id, child: Text(u.nome)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedUsuarioId = val),
                validator: (val) => val == null ? 'Selecione um usuário' : null,
              ),
              const SizedBox(height: 12),

              // Ação
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
              const SizedBox(height: 12),

              // Tipo (compra/venda)
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'compra', child: Text('Compra')),
                  DropdownMenuItem(value: 'venda', child: Text('Venda')),
                ],
                onChanged: (val) => setState(() => _tipo = val!),
              ),
              const SizedBox(height: 12),

              // Quantidade
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
              const SizedBox(height: 12),

              // Preço Unitário
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(labelText: 'Preço Unitário'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Obrigatório';
                  final n = double.tryParse(val.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Deve ser > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo Operação (PUT/CALL)
              DropdownButtonFormField<String?>(
                value: _tipoOperacao,
                decoration: const InputDecoration(labelText: 'Tipo de Operação (opcional)'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Nenhum')),
                  DropdownMenuItem(value: 'PUT', child: Text('PUT')),
                  DropdownMenuItem(value: 'CALL', child: Text('CALL')),
                ],
                onChanged: (val) => setState(() => _tipoOperacao = val),
              ),
              const SizedBox(height: 12),

              // Nome da Opção
              TextFormField(
                controller: _nomeOpcaoController,
                decoration: const InputDecoration(labelText: 'Nome da Opção (opcional)'),
              ),
              const SizedBox(height: 12),

              // Valor de Mercado
              TextFormField(
                controller: _valorMercadoController,
                decoration: const InputDecoration(labelText: 'Valor de Mercado (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              // Valor Strike
              TextFormField(
                controller: _valorStrikeController,
                decoration: const InputDecoration(labelText: 'Valor do Strike (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Data de exercício
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Data de Exercício'),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dataExercicio == null
                            ? 'Não definida'
                            : _formatYmd(_dataExercicio!),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickDataExercicio,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Escolher'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Percentuais e valores relacionados
              TextFormField(
                controller: _porcentagemPremioController,
                decoration: const InputDecoration(labelText: 'Porcentagem Prêmio (%)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _valorPremioLiquidoController,
                decoration: const InputDecoration(labelText: 'Valor Prêmio Líquido (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _percentualRetornoController,
                decoration: const InputDecoration(labelText: 'Percentual Retorno (%)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _percentualRetornoLiquidoController,
                decoration: const InputDecoration(labelText: 'Percentual Retorno Líquido (%)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _situacaoMomentoController,
                decoration: const InputDecoration(labelText: 'Situação do Momento (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _valorCoberturalController,
                decoration: const InputDecoration(labelText: 'Valor Cobertural (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Exercido Operação'),
                value: _exercidoOperacao,
                onChanged: (v) => setState(() => _exercidoOperacao = v),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _corretoraOperadaController,
                decoration: const InputDecoration(labelText: 'Corretora Operada'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _valorIrrrfController,
                decoration: const InputDecoration(labelText: 'Valor IRRF (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),

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