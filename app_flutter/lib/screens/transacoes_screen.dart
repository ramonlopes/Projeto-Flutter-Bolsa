import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transacao_service.dart';
import '../models/transacao.dart';
import 'transacao_form_screen.dart';
import '../services/acao_service.dart';

class TransacoesScreen extends StatefulWidget {
  const TransacoesScreen({super.key});

  @override
  State<TransacoesScreen> createState() => _TransacoesScreenState();
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  late Future<List<Transacao>> _futuro;
  final service = TransacaoService();
  final _acaoService = AcaoService();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _date = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _futuro = service.listarTransacoes();
  }

  void _recarregar() {
    setState(() => _futuro = service.listarTransacoes());
  }

  Color _corTipo(Transacao t) => t.tipo.toLowerCase() == 'compra'
      ? Colors.green.shade600
      : Colors.red.shade600;

  Color _corOperacao(Transacao t) {
    if (t.tipoOperacao == 'CALL') return Colors.orange.shade700;
    if (t.tipoOperacao == 'PUT') return Colors.purple.shade700;
    return Colors.grey.shade600;
  }

  Future<void> _confirmarExclusao(Transacao t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir transação?'),
        content: Text('Confirma excluir ${t.tipo} - ${t.acaoCodigo ?? 'Ação ${t.acaoId}'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await service.deletarTransacao(t.id!);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Transação excluída')));
      _recarregar();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  Widget _chip(String label, {Color? color, IconData? icon}) {
    return Chip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 16, color: Colors.white) : null,
      backgroundColor: color ?? Colors.grey.shade200,
      labelStyle: TextStyle(
        color: color != null ? Colors.white : Colors.black87,
        fontSize: 12,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _precoChip(String codigo) {
    return FutureBuilder<AcaoPreco>(
      future: _acaoService.obterPreco(codigo),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Chip(label: Text('Carregando preço...'));
        }
        if (!snap.hasData) {
          return const Chip(label: Text('Sem preço'));
        }
        final p = snap.data!;
        final cor = (p.variacaoPercent ?? 0) >= 0 ? Colors.green : Colors.red;
        return Chip(
          label: Text('${p.moeda} ${p.preco.toStringAsFixed(2)} (${p.variacaoPercent?.toStringAsFixed(2) ?? '-'}%)'),
          backgroundColor: cor.withOpacity(0.12),
          labelStyle: TextStyle(color: cor, fontWeight: FontWeight.w600),
        );
      },
    );
  }

  Widget _card(Transacao t) {
    final total = t.precoUnitario * t.quantidade;
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _corTipo(t).withOpacity(0.12),
          child: Text(
            (t.acaoCodigo ?? 'A').substring(0, 1).toUpperCase(),
            style: TextStyle(color: _corTipo(t), fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _corTipo(t).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                t.tipo.toUpperCase(),
                style: TextStyle(
                  color: _corTipo(t),
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.acaoCodigo ?? 'Ação ${t.acaoId}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${t.quantidade} un. @ ${_currency.format(t.precoUnitario)}'),
                  const SizedBox(width: 12),
                  Text('Total: ${_currency.format(total)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: -6,
                children: [
                  if (t.tipoOperacao != null)
                    _chip(t.tipoOperacao!, color: _corOperacao(t)),
                  if ((t.nomeOpcao ?? '').isNotEmpty) _chip('Opção: ${t.nomeOpcao!}'),
                  if (t.dataExercicio != null)
                    _chip('Exercício: ${_date.format(t.dataExercicio!)}', icon: Icons.event),
                  if (t.valorStrike != null)
                    _chip('Strike: ${_currency.format(t.valorStrike)}'),
                  if (t.porcentagemPremio != null)
                    _chip('Prêmio: ${t.porcentagemPremio!.toStringAsFixed(2)}%'),
                  if (t.valorPremioLiquido != null)
                    _chip('Prêmio Líq.: ${_currency.format(t.valorPremioLiquido)}'),
                  if (t.percentualRetorno != null)
                    _chip('Retorno: ${t.percentualRetorno!.toStringAsFixed(2)}%'),
                  if (t.percentualRetornoLiquido != null)
                    _chip('Retorno Líq.: ${t.percentualRetornoLiquido!.toStringAsFixed(2)}%'),
                  if (t.situacaoMomento != null)
                    _chip('Momento: ${_currency.format(t.situacaoMomento)}'),
                  if (t.valorCobertural != null)
                    _chip('Cobert.: ${_currency.format(t.valorCobertural)}'),
                  if (t.corretoraOperada != null && t.corretoraOperada!.isNotEmpty)
                    _chip('Corretora: ${t.corretoraOperada!}'),
                  if (t.exercidoOperacao == true)
                    _chip('Exercido', color: Colors.teal.shade700, icon: Icons.check),
                  if (t.valorIrrrf != null)
                    _chip('IRRF: ${_currency.format(t.valorIrrrf)}'),
                  if (t.acaoCodigo != null) _precoChip(t.acaoCodigo!),
                ],
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.dataTransacao != null ? _date.format(t.dataTransacao!) : '',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  final ok = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => TransacaoFormScreen(transacao: t)),
                  );
                  if (ok == true) _recarregar();
                } else if (v == 'delete') {
                  _confirmarExclusao(t);
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      body: RefreshIndicator(
        onRefresh: () async => _recarregar(),
        child: FutureBuilder<List<Transacao>>(
          future: _futuro,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Erro ao carregar: ${snap.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _recarregar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final lista = snap.data ?? [];
            if (lista.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade500),
                      const SizedBox(height: 12),
                      const Text('Nenhuma transação ainda'),
                      const SizedBox(height: 8),
                      Text(
                        'Toque em "Adicionar" para lançar sua primeira transação.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: lista.length,
              itemBuilder: (_, i) => _card(lista[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const TransacaoFormScreen()),
          );
          if (ok == true) _recarregar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}