import 'package:consulta_servidor/core/utils/app_feedback.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:flutter/material.dart';

class FormConsulta extends StatefulWidget {
  final ConsultaController controller;
  final ValueChanged<ServidorFiltros> onBuscar;

  const FormConsulta({
    super.key,
    required this.controller,
    required this.onBuscar,
  });

  @override
  State<FormConsulta> createState() => _FormConsultaState();
}

class _FormConsultaState extends State<FormConsulta> {
  bool _mostrarFiltrosAvancados = false;
  bool _buscaSimilar = true;
  int _limiteSelecionado = 100;
  String? _ufSelecionada;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _orgaoController = TextEditingController();

  static const List<String> _estadosBrasil = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  static const List<int> _opcoesLimite = [25, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _sincronizarComController();
  }

  void _sincronizarComController() {
    final ativos = widget.controller.filtrosAtivos;
    if (ativos != null) {
      _nomeController.text = ativos.nome ?? '';
      _cargoController.text = ativos.cargo ?? '';
      _orgaoController.text = ativos.orgao ?? '';
      _ufSelecionada = ativos.uf;
      _limiteSelecionado = ativos.limite;
      _buscaSimilar = ativos.buscaSimilar;

      if ((ativos.cargo != null && ativos.cargo!.isNotEmpty) ||
          (ativos.orgao != null && ativos.orgao!.isNotEmpty) ||
          (ativos.uf != null && ativos.uf!.isNotEmpty)) {
        _mostrarFiltrosAvancados = true;
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cargoController.dispose();
    _orgaoController.dispose();
    super.dispose();
  }

  void _dispararBusca() {
    final nome = _nomeController.text.trim();
    final cargo = _cargoController.text.trim();
    final orgao = _orgaoController.text.trim();
    final uf = _ufSelecionada;

    // Exige ao menos um campo qualquer preenchido
    final bool temAoMenosUmCampo =
        nome.isNotEmpty ||
        cargo.isNotEmpty ||
        orgao.isNotEmpty ||
        (uf != null && uf.isNotEmpty);

    if (!temAoMenosUmCampo) {
      AppFeedback.mostrarSnackBar(
        context,
        mensagem:
            'Preencha ou selecione ao menos um campo para realizar a consulta.',
        isSucesso: false,
      );
      return;
    }

    final filtros = ServidorFiltros(
      nome: nome.isEmpty ? null : nome,
      cargo: cargo.isEmpty ? null : cargo,
      orgao: orgao.isEmpty ? null : orgao,
      uf: uf,
      buscaSimilar: _buscaSimilar,
      limite: _limiteSelecionado,
      pagina: 1,
    );

    widget.onBuscar(filtros);
  }

  void _limparTodosCampos() {
    setState(() {
      _nomeController.clear();
      _cargoController.clear();
      _orgaoController.clear();
      _ufSelecionada = null;
      _limiteSelecionado = 100;
      _buscaSimilar = true;
    });
    widget.controller.resetarBusca();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================================
            // 1. LINHA PRINCIPAL: Nome + Modo de Busca + Limite
            // ================================================================
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: 320,
                  child: _CampoComLabel(
                    label: 'Nome do Servidor',
                    child: TextField(
                      controller: _nomeController,
                      onSubmitted: (_) => _dispararBusca(),
                      decoration: InputDecoration(
                        hintText: 'Digite o nome...',
                        prefixIcon: const Icon(Icons.person_search_outlined),
                        suffixIcon: _nomeController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() => _nomeController.clear()),
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                _CampoComLabel(
                  label: 'Modo de Correspondência',
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Similaridade'),
                        icon: Icon(Icons.manage_search),
                        tooltip: 'Busca por partes do nome (ILIKE)',
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Exata'),
                        icon: Icon(Icons.text_fields),
                        tooltip: 'Busca exata',
                      ),
                    ],
                    selected: {_buscaSimilar},
                    onSelectionChanged: (Set<bool> novaSelecao) {
                      setState(() => _buscaSimilar = novaSelecao.first);
                    },
                  ),
                ),

                SizedBox(
                  width: 150,
                  child: _CampoComLabel(
                    label: 'Limite de Linhas',
                    child: DropdownButtonFormField<int>(
                      initialValue: _limiteSelecionado,
                      isExpanded: true,
                      items: _opcoesLimite.map((limite) {
                        return DropdownMenuItem<int>(
                          value: limite,
                          child: Text('$limite itens'),
                        );
                      }).toList(),
                      onChanged: (novoLimite) {
                        if (novoLimite != null) {
                          setState(() => _limiteSelecionado = novoLimite);
                        }
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ================================================================
            // 2. SANFONA DE FILTROS AVANÇADOS (Cargo, Órgão e UF)
            // ================================================================
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: !_mostrarFiltrosAvancados
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 32),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width: 300,
                                child: _CampoComLabel(
                                  label: 'Cargo / Profissão',
                                  child: TextField(
                                    controller: _cargoController,
                                    onSubmitted: (_) => _dispararBusca(),
                                    decoration: const InputDecoration(
                                      hintText: 'Ex: Auditor, Professor...',
                                      prefixIcon: Icon(Icons.work_outline),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 340,
                                child: _CampoComLabel(
                                  label: 'Órgão / Instituição',
                                  child: TextField(
                                    controller: _orgaoController,
                                    onSubmitted: (_) => _dispararBusca(),
                                    decoration: const InputDecoration(
                                      hintText: 'Ex: Ministério da Educação...',
                                      prefixIcon: Icon(
                                        Icons.account_balance_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 140,
                                child: _CampoComLabel(
                                  label: 'Estado (UF)',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _ufSelecionada,
                                    hint: const Text('Todos'),
                                    isExpanded: true,
                                    items: _estadosBrasil.map((uf) {
                                      return DropdownMenuItem<String>(
                                        value: uf,
                                        child: Text(uf),
                                      );
                                    }).toList(),
                                    onChanged: (novoUf) {
                                      setState(() => _ufSelecionada = novoUf);
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.map_outlined),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Barra de Ações
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 16,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(
                      () =>
                          _mostrarFiltrosAvancados = !_mostrarFiltrosAvancados,
                    );
                  },
                  icon: Icon(
                    _mostrarFiltrosAvancados ? Icons.expand_less : Icons.tune,
                  ),
                  label: Text(
                    _mostrarFiltrosAvancados
                        ? 'Ocultar filtros específicos'
                        : 'Mais opções (Cargo, Órgão, UF)',
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _limparTodosCampos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _dispararBusca,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text(
                        'Aplicar Filtros',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoComLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const _CampoComLabel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
