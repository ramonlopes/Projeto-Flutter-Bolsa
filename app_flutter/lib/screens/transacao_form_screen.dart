import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../models/transacao.dart';
import '../services/transacao_service.dart';
import '../services/auth_service.dart';
import '../services/acao_service.dart';
import '../services/corretora_service.dart';
import '../services/yahoo_finance_service.dart';
import '../models/acao.dart';
import '../models/corretora.dart';

class TransacaoFormScreen extends StatefulWidget {
  final Transacao? transacao;
  const TransacaoFormScreen({super.key, this.transacao});

  @override
  State<TransacaoFormScreen> createState() => _TransacaoFormScreenState();
}

class _TransacaoFormScreenState extends State<TransacaoFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _transacaoService = TransacaoService();
  final _acaoService = AcaoService();
  final _auth = AuthService();
  final _corretoraService = CorretoraService();
  final _yahooService = YahooFinanceService();

  int? _usuarioIdLogado;

  List<Acao> _acoes = [];
  List<Corretora> _corretoras = [];
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  late TabController _tabController;

  // Campos básicos
  int? _selectedUsuarioId;
  int? _selectedAcaoId;
  int? _selectedCorretoraId;
  String _tipo = 'compra';
  final _quantidadeController = TextEditingController();
  final _precoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
    initialValue: 0.0, // ADICIONE
  );
  final _valorOperacaoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );

  // Opções
  String? _tipoOperacao;
  final _nomeOpcaoController = TextEditingController();
  final _valorMercadoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
    initialValue: 0.0, // ADICIONE
  );
  final _valorStrikeController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );

  // Financeiro
  DateTime? _dataExercicio;
  final _porcentagemPremioController = TextEditingController();
  final _valorPremioLiquidoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  final _percentualRetornoController = TextEditingController();
  final _percentualRetornoLiquidoController = TextEditingController();
  final _situacaoMomentoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  final _valorCoberturalController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  bool _exercidoOperacao = false;
  final _corretoraOperadaController = TextEditingController();
  final _valorIRRFController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );

  bool _loading = true;
  bool _buscandoCotacao = false;

  bool get _isEdicao => widget.transacao != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (!_isEdicao) {
      _porcentagemPremioController.text = '85.00';
    }

    _carregarUsuarioLogado();
    _carregarAcoes();
    _carregarCorretoras();
    
    // Chame _preencherEdicao() APÓS o build estar pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preencherEdicao();
    });

    // Use o usuário da transação (edição) como usuário atual
    _usuarioIdLogado = widget.transacao?.usuarioId;
    _selectedUsuarioId = _usuarioIdLogado;
  }

  void _preencherEdicao() {
    final t = widget.transacao;
    if (t == null) return;
    
    _selectedUsuarioId = t.usuarioId;
    _selectedAcaoId = t.acaoId;
    _tipo = t.tipo;
    _quantidadeController.text = t.quantidade.toString();
    
    // Use try-catch para evitar erro com MoneyMaskedTextController
    try {
      if (t.precoUnitario > 0) _precoController.updateValue(t.precoUnitario);
      if ((t.valorMercado ?? 0) > 0) _valorMercadoController.updateValue(t.valorMercado ?? 0.0);
      if ((t.valorStrike ?? 0) > 0) _valorStrikeController.updateValue(t.valorStrike ?? 0.0);
      if ((t.valorPremioLiquido ?? 0) > 0) _valorPremioLiquidoController.updateValue(t.valorPremioLiquido ?? 0.0);
      if ((t.situacaoMomento ?? 0) > 0) _situacaoMomentoController.updateValue(t.situacaoMomento ?? 0.0);
      if ((t.valorCobertural ?? 0) > 0) _valorCoberturalController.updateValue(t.valorCobertural ?? 0.0);
      if ((t.valorIRRF ?? 0) > 0) _valorIRRFController.updateValue(t.valorIRRF ?? 0.0);
      if ((t.valorOperacao ?? 0) > 0) _valorOperacaoController.updateValue(t.valorOperacao ?? 0.0);
    } catch (e) {
      print('Erro ao preencher valores: $e');
    }
    
    _selectedCorretoraId = t.corretoraId;
    _tipoOperacao = t.tipoOperacao;
    _nomeOpcaoController.text = t.nomeOpcao ?? '';
    _dataExercicio = t.dataExercicio;
    _porcentagemPremioController.text = t.porcentagemPremio?.toString() ?? '';
    _percentualRetornoController.text = t.percentualRetorno?.toString() ?? '';
    _percentualRetornoLiquidoController.text = t.percentualRetornoLiquido?.toString() ?? '';
    _exercidoOperacao = t.exercidoOperacao ?? false;
    _corretoraOperadaController.text = t.corretoraOperada ?? '';
  }

  Future<void> _carregarUsuarioLogado() async {
    final u = await _auth.getUsuario();
    if (mounted) setState(() => _usuarioIdLogado = u?.id);
  }

  Future<void> _carregarAcoes() async {
    try {
      final acoes = await _acaoService.listarAcoes();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao carregar ações: $e')));
    }
  }

  Future<void> _carregarCorretoras() async {
    try {
      final lista = await _corretoraService.listar();
      if (!mounted) return;
      setState(() {
        _corretoras = lista;
        if (_selectedCorretoraId == null && lista.isNotEmpty) {
          _selectedCorretoraId = lista.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar corretoras: $e')),
      );
    }
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
    _valorIRRFController.dispose();
    _valorOperacaoController.dispose();
    _yahooService.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_usuarioIdLogado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Usuário não carregado')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final transacao = Transacao(
        id: widget.transacao?.id,
        usuarioId: _usuarioIdLogado!,
        acaoId: _selectedAcaoId!,
        corretoraId: _selectedCorretoraId,
        tipo: _tipo,
        quantidade: int.parse(_quantidadeController.text),
        precoUnitario: _precoController.numberValue.toDouble(),
        tipoOperacao: _tipoOperacao,
        nomeOpcao: _nomeOpcaoController.text.isEmpty
            ? null
            : _nomeOpcaoController.text,
        valorMercado: _valorMercadoController.numberValue > 0
            ? _valorMercadoController.numberValue.toDouble()
            : null,
        valorStrike: _valorStrikeController.numberValue > 0
            ? _valorStrikeController.numberValue.toDouble()
            : null,
        dataExercicio: _dataExercicio,
        porcentagemPremio: _toDouble(_porcentagemPremioController.text),
        valorPremioLiquido: _valorPremioLiquidoController.numberValue > 0
            ? _valorPremioLiquidoController.numberValue.toDouble()
            : null,
        percentualRetorno: _toDouble(_percentualRetornoController.text),
        percentualRetornoLiquido:
            _toDouble(_percentualRetornoLiquidoController.text),
        situacaoMomento: _situacaoMomentoController.numberValue > 0
            ? _situacaoMomentoController.numberValue.toDouble()
            : null,
        valorCobertural: _valorCoberturalController.numberValue > 0
            ? _valorCoberturalController.numberValue.toDouble()
            : null,
        exercidoOperacao: _exercidoOperacao,
        corretoraOperada: _corretoraOperadaController.text.isEmpty
            ? null
            : _corretoraOperadaController.text,
        valorIRRF: _valorIRRFController.numberValue > 0
            ? _valorIRRFController.numberValue.toDouble()
            : null,
        valorOperacao: _valorOperacaoController.numberValue > 0
            ? _valorOperacaoController.numberValue.toDouble()
            : null,
      );

      if (_isEdicao) {
        await _transacaoService.atualizarTransacao(
            widget.transacao!.id!, transacao);
        if (!mounted) return;
        messenger.showSnackBar(
            const SnackBar(content: Text('✓ Transação atualizada')));
      } else {
        await _transacaoService.criarTransacao(transacao);
        if (!mounted) return;
        messenger
            .showSnackBar(const SnackBar(content: Text('✓ Transação criada')));
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  double? _toDouble(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.replaceAll(',', '.'));

  Widget _buildCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
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
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _buscarCotacaoAcao(int acaoId) async {
    final acao =
        _acoes.firstWhere((a) => a.id == acaoId, orElse: () => _acoes.first);

    setState(() => _buscandoCotacao = true);

    try {
      final preco = await _yahooService.obterCotacao(acao.codigo);

      if (!mounted) return;

      if (preco != null) {
        _valorMercadoController.updateValue(preco);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Cotação de ${acao.codigo}: ${_currency.format(preco)}'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cotação de ${acao.codigo} não disponível'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar cotação: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _buscandoCotacao = false);
    }
  }

  void _calcularSituacaoMomento() {
    // Verifica se tem tipo de operação (CALL ou PUT)
    if (_tipoOperacao == null || _tipoOperacao!.isEmpty) {
      _situacaoMomentoController.updateValue(0.0);
      return;
    }

    final valorMercado = _valorMercadoController.numberValue;
    final strike = _valorStrikeController.numberValue;
    final qtd = int.tryParse(_quantidadeController.text) ?? 0;

    // Precisa ter valores válidos
    if (valorMercado <= 0 || strike <= 0 || qtd <= 0) {
      _situacaoMomentoController.updateValue(0.0);
      return;
    }

    double situacao = 0.0;

    if (_tipoOperacao == 'CALL') {
      // CALL: positivo se mercado > strike
      if (valorMercado > strike) {
        situacao = (valorMercado - strike) * qtd; // lucro potencial
      } else {
        situacao = 0.0; // fora do dinheiro
      }
    } else if (_tipoOperacao == 'PUT') {
      // PUT: positivo se mercado < strike
      if (valorMercado < strike) {
        situacao = (strike - valorMercado) * qtd; // lucro potencial
      } else {
        situacao = 0.0; // fora do dinheiro
      }
    }

    _situacaoMomentoController.updateValue(situacao);
  }

  void _atualizarCobertura() {
    final qtd = int.tryParse(_quantidadeController.text) ?? 0;
    final strike = _valorStrikeController.numberValue;
    final cobertura = qtd * strike;
    _valorCoberturalController.updateValue(cobertura);
    _calcularSituacaoMomento(); // ADICIONE
  }

  void _calcularValorOperacao() {
    final qtd = int.tryParse(_quantidadeController.text) ?? 0;
    final preco = _precoController.numberValue;
    final valorOperacao = qtd * preco;
    _valorOperacaoController.updateValue(valorOperacao);
    _calcularIRRF(); // Recalcula IRRF após atualizar valor operação
  }

  void _calcularPremioLiquido() {
    final qtd = int.tryParse(_quantidadeController.text) ?? 0;
    final preco = _precoController.numberValue;
    final percentualPremio =
        double.tryParse(_porcentagemPremioController.text.replaceAll(',', '.')) ?? 0.0;
    final premioLiquido = qtd * preco * (percentualPremio / 100);
    _valorPremioLiquidoController.updateValue(premioLiquido);
    _calcularIRRF(); // Recalcula IRRF após atualizar prêmio
  }

  // NOVA: Calcular IRRF automaticamente
  void _calcularIRRF() {
    final qtd = int.tryParse(_quantidadeController.text) ?? 0;
    final premio = _valorPremioLiquidoController.numberValue;
    final valorOperacao = _valorOperacaoController.numberValue;
    final percentualPremio = double.tryParse(_porcentagemPremioController.text.replaceAll(',', '.')) ?? 0.0;    

    final irrf = (valorOperacao) * ((100 - percentualPremio) / 100);

    _valorIRRFController.updateValue(irrf);
  }

  void _corrigirQuantidade() {
    final texto = _quantidadeController.text.trim();
    final valor = int.tryParse(texto);
    if (valor == null || valor <= 0) return;

    final corrigido = valor;
    _quantidadeController.text = corrigido.toString();
    _atualizarCobertura();
    _calcularValorOperacao(); // ADICIONE
    _calcularPremioLiquido();
    setState(() {});
  }

  // Substitua o Dropdown de usuário que usa _auth.usuarios por um item único do usuário atual
  Widget _usuarioDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedUsuarioId, // was: value
      decoration: const InputDecoration(labelText: 'Usuário'),
      items: (_usuarioIdLogado == null)
          ? const []
          : [
              DropdownMenuItem<int>(
                value: _usuarioIdLogado,
                child: const Text('Usuário atual'),
              ),
            ],
      onChanged: (val) => setState(() => _selectedUsuarioId = val),
      validator: (val) => val == null ? 'Usuário inválido' : null,
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
              Text('Carregando...',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Transação' : 'Nova Transação'),
        bottom: TabBar(
          controller: _tabController,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
            _usuarioDropdown(),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedAcaoId, // was: value
              decoration: InputDecoration(
                labelText: 'Ação',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.show_chart),
                suffixIcon: _buscandoCotacao
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              items: _acoes
                  .map<DropdownMenuItem<int>>(
                    (a) => DropdownMenuItem<int>(
                      value: a.id,
                      child: Text('${a.codigo} - ${a.nomeEmpresa}'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedAcaoId = val);
                  _buscarCotacaoAcao(val);
                }
              },
              validator: (val) => val == null ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedCorretoraId, // was: value
              decoration: InputDecoration(
                labelText: 'Corretora',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.account_balance),
              ),
              items: _corretoras
                  .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCorretoraId = v),
              validator: (v) => v == null ? 'Selecione uma corretora' : null,
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
                ButtonSegment(
                    value: 'compra',
                    label: Text('Compra'),
                    icon: Icon(Icons.arrow_downward, color: Colors.green)),
                ButtonSegment(
                    value: 'venda',
                    label: Text('Venda'),
                    icon: Icon(Icons.arrow_upward, color: Colors.red)),
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.numbers),
                      helperText: 'Múltiplos de 100',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) {
                      setState(() {});
                      _atualizarCobertura();
                      _calcularValorOperacao(); // ADICIONE
                      _calcularPremioLiquido();
                    },
                    onEditingComplete: _corrigirQuantidade,
                    onTapOutside: (_) => _corrigirQuantidade(),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Obrigatório';
                      final n = int.tryParse(val);
                      if (n == null) return 'Digite um número válido';
                      if (n <= 0) return 'Deve ser > 0';
                      if (n % 100 != 0) return 'Deve ser múltiplo de 100';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _precoController,
                    decoration: InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                      _calcularValorOperacao(); // ADICIONE
                      _calcularPremioLiquido();
                    },
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Obrigatório';
                      }
                      if (_precoController.numberValue <= 0) {
                        return 'Deve ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // NOVO: Widget que exibe o total calculado
            _buildTotalOperacao(),
          ],
        ),
      ],
    );
  }

  // NOVO: Método para calcular e exibir o total
  Widget _buildTotalOperacao() {
    final qtd = int.tryParse(_quantidadeController.text) ?? 0;
    final preco = _precoController.numberValue;
    final total = qtd * preco;

    final theme = Theme.of(context);
    final isCompra = _tipo == 'compra';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompra
            ? Colors.red.withValues(alpha: 0.08)   // was: withOpacity(0.08)
            : Colors.green.withValues(alpha: 0.08),// was: withOpacity(0.08)
        border: Border.all(
          color: isCompra ? Colors.red.shade300 : Colors.green.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valor Total da Operação',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currency.format(total),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCompra ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$qtd ação${qtd != 1 ? 's' : ''} × ${_currency.format(preco)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Icon(
            isCompra ? Icons.arrow_downward : Icons.arrow_upward,
            size: 48,
            color: isCompra ? Colors.red.shade300 : Colors.green.shade300,
          ),
        ],
      ),
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
              initialValue: _tipoOperacao, // was: value + wrong non-nullable generic
              decoration: InputDecoration(
                labelText: 'Tipo de Operação',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.swap_calls),
              ),
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('Nenhum')),
                DropdownMenuItem<String?>(value: 'PUT', child: Text('PUT')),
                DropdownMenuItem<String?>(value: 'CALL', child: Text('CALL')),
              ],
              onChanged: (val) {
                setState(() => _tipoOperacao = val);
                _calcularSituacaoMomento();
              },
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixIcon: _buscandoCotacao
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Atualizar cotação',
                              onPressed: _selectedAcaoId == null
                                  ? null
                                  : () => _buscarCotacaoAcao(_selectedAcaoId!),
                            ),
                      helperText: _buscandoCotacao
                          ? 'Buscando cotação...'
                          : 'Cotação em tempo real',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: _buscandoCotacao,
                    onChanged: (_) => _calcularSituacaoMomento(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _valorStrikeController,
                    decoration: InputDecoration(
                      labelText: 'Strike',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.gps_fixed),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _atualizarCobertura();
                      _calcularSituacaoMomento();
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.percent),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _valorPremioLiquidoController,
                    decoration: InputDecoration(
                      labelText: 'Prêmio Líq.',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                      helperText: 'Auto-calculado: Qtd × Preço × Prêmio(%)',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true, // TORNE READONLY
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.trending_up),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _percentualRetornoLiquidoController,
                    decoration: InputDecoration(
                      labelText: 'Retorno Líq. (%)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.show_chart),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valorIRRFController,
                    decoration: InputDecoration(
                      labelText: 'IRRF',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.account_balance),
                      helperText: 'Auto-calculado',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _valorCoberturalController,
                    decoration: InputDecoration(
                      labelText: 'Cobertural',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.shield),
                      helperText: 'Auto-calculado: Qtd × Strike',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _situacaoMomentoController,
              decoration: InputDecoration(
                labelText: 'Situação Momento',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.info_outline),
                helperText: 'CALL: Mercado > Strike | PUT: Mercado < Strike',
              ),
              keyboardType: TextInputType.number,
              readOnly: true, // TORNE READONLY
            ),
          ],
        ),
      ],
    );
  }
}
