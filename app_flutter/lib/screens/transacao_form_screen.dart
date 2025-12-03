import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transacao.dart';
import '../services/transacao_service.dart';
import '../services/auth_service.dart';
import '../services/acao_service.dart';
import '../models/acao.dart'; // ADICIONE este import

class TransacaoFormScreen extends StatefulWidget {
  final Transacao? transacao;
  const TransacaoFormScreen({super.key, this.transacao});

  @override
  State<TransacaoFormScreen> createState() => _TransacaoFormScreenState();
}

class _TransacaoFormScreenState extends State<TransacaoFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _transacaoService = TransacaoService();
  final _acaoService = AcaoService();
  final _auth = AuthService();

  int? _usuarioIdLogado;

  List<Acao> _acoes = []; // TIPADO com Acao
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  late TabController _tabController;

  // Campos básicos
  int? _selectedUsuarioId;
  int? _selectedAcaoId;
  String _tipo = 'compra';
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  // Opções
  String? _tipoOperacao;
  final _nomeOpcaoController = TextEditingController();
  final _valorMercadoController = TextEditingController();
  final _valorStrikeController = TextEditingController();

  // Financeiro
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

  bool _loading = true;

  bool get _isEdicao => widget.transacao != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarUsuarioLogado();
    _carregarAcoes();
    _preencherEdicao();
  }

  Future<void> _carregarUsuarioLogado() async {
    final u = await _auth.getUsuario();
    if (mounted) setState(() => _usuarioIdLogado = u?.id);
  }

  Future<void> _carregarAcoes() async {
    try {
      final acoes = await _acaoService.listarAcoes(); // deve retornar List<Acao>
      if (!mounted) return;
      setState(() {
        _acoes = acoes;
        _loading = false;
        if (!_isEdicao && _acoes.isNotEmpty) {
          _selectedAcaoId = _acoes.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar ações: $e')));
    }
  }

  void _preencherEdicao() {
    final t = widget.transacao;
    if (t == null) return;
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

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_usuarioIdLogado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não carregado')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final transacao = Transacao(
        id: widget.transacao?.id,
        usuarioId: _usuarioIdLogado!, // backend vai usar o token
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
        messenger.showSnackBar(const SnackBar(content: Text('✓ Transação atualizada')));
      } else {
        await _transacaoService.criarTransacao(transacao);
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('✓ Transação criada')));
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  double? _toDouble(String s) => s.trim().isEmpty ? null : double.tryParse(s.replaceAll(',', '.'));

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Garante cor visível do ícone do título do card
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Carregando...', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Transação' : 'Nova Transação'),
        bottom: TabBar(
          controller: _tabController,
          // Cores explícitas para manter ícones/labels visíveis sobre a AppBar
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.assessment), text: 'Básico'),
            Tab(icon: Icon(Icons.analytics), text: 'Opções'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Financeiro'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicoTab(),
            _buildOpcoesTab(),
            _buildFinanceiroTab(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _salvar,
            icon: const Icon(Icons.check),
            label: Text(_isEdicao ? 'Atualizar' : 'Salvar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: 'Identificação',
          icon: Icons.person,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedAcaoId,
              decoration: InputDecoration(
                labelText: 'Ação',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.show_chart),
              ),
              items: _acoes
                  .map<DropdownMenuItem<int>>(
                    (a) => DropdownMenuItem<int>(
                      value: a.id,
                      child: Text('${a.codigo} - ${a.nomeEmpresa}'),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedAcaoId = val),
              validator: (val) => val == null ? 'Obrigatório' : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: 'Detalhes da Operação',
          icon: Icons.receipt_long,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'compra', label: Text('Compra'), icon: Icon(Icons.arrow_downward, color: Colors.green)),
                ButtonSegment(value: 'venda', label: Text('Venda'), icon: Icon(Icons.arrow_upward, color: Colors.red)),
              ],
              selected: {_tipo},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _tipo = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantidadeController,
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Obrigatório';
                      final n = int.tryParse(val);
                      if (n == null || n <= 0) return 'Deve ser > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _precoController,
                    decoration: InputDecoration(
                      labelText: 'Preço (R\$)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Obrigatório';
                      final n = _toDouble(val);
                      if (n == null || n <= 0) return 'Deve ser > 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpcoesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: 'Derivativos (Opções)',
          icon: Icons.trending_up,
          children: [
            DropdownButtonFormField<String?>(
              value: _tipoOperacao,
              decoration: InputDecoration(
                labelText: 'Tipo de Operação',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.swap_calls),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Nenhum')),
                DropdownMenuItem(value: 'PUT', child: Text('PUT')),
                DropdownMenuItem(value: 'CALL', child: Text('CALL')),
              ],
              onChanged: (val) => setState(() => _tipoOperacao = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeOpcaoController,
              decoration: InputDecoration(
                labelText: 'Nome da Opção',
                hintText: 'Ex.: PETR4C40',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valorMercadoController,
                    decoration: InputDecoration(
                      labelText: 'Valor Mercado',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _valorStrikeController,
                    decoration: InputDecoration(
                      labelText: 'Strike',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.gps_fixed),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinanceiroTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: 'Prêmios e Retornos',
          icon: Icons.monetization_on,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _porcentagemPremioController,
                    decoration: InputDecoration(
                      labelText: 'Prêmio (%)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.percent),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _valorPremioLiquidoController,
                    decoration: InputDecoration(
                      labelText: 'Prêmio Líq. (R\$)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _percentualRetornoController,
                    decoration: InputDecoration(
                      labelText: 'Retorno (%)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.trending_up),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _percentualRetornoLiquidoController,
                    decoration: InputDecoration(
                      labelText: 'Retorno Líq. (%)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.show_chart),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: 'Exercício e Impostos',
          icon: Icons.event,
          children: [
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dataExercicio ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _dataExercicio = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Exercício',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _dataExercicio == null
                      ? 'Selecionar data'
                      : DateFormat('dd/MM/yyyy').format(_dataExercicio!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Operação Exercida'),
              value: _exercidoOperacao,
              onChanged: (v) => setState(() => _exercidoOperacao = v),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _corretoraOperadaController,
              decoration: InputDecoration(
                labelText: 'Corretora',
                hintText: 'Ex.: Clear, Rico',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valorIrrrfController,
                    decoration: InputDecoration(
                      labelText: 'IRRF (R\$)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _valorCoberturalController,
                    decoration: InputDecoration(
                      labelText: 'Cobertural (R\$)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.shield),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _situacaoMomentoController,
              decoration: InputDecoration(
                labelText: 'Situação Momento (R\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.info_outline),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ],
    );
  }
}