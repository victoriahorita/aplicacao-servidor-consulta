import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:flutter/material.dart';

class FormConsulta extends StatefulWidget {
  final bool isCarregando;
  final ValueChanged<ServidorFiltros> onBuscar;

  const FormConsulta({
    super.key,
    required this.isCarregando,
    required this.onBuscar,
  });

  @override
  State<FormConsulta> createState() => _FormConsultaState();
}

class _FormConsultaState extends State<FormConsulta> {
  bool _mostrarFiltrosAvancados = false;

  // Estado do seletor moderno: true = Similaridade, false = Exata
  bool _buscaSimilar = true;

  // Limite padrão alinhado com o api.py
  int _limiteSelecionado = 100;

  // UF selecionada
  String? _ufSelecionada;

  // Controladores de Texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _orgaoController = TextEditingController();

  // Lista oficial das 27 Unidades Federativas do Brasil
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

  // Opções de limite para a consulta no banco
  static const List<int> _opcoesLimite = [25, 50, 100, 200];

  @override
  void dispose() {
    _nomeController.dispose();
    _cargoController.dispose();
    _orgaoController.dispose();
    super.dispose();
  }

  void _dispararBusca() {
    // Empacota todos os filtros selecionados
    final filtros = ServidorFiltros(
      nome: _nomeController.text.trim().isEmpty
          ? null
          : _nomeController.text.trim(),
      cargo: _cargoController.text.trim().isEmpty
          ? null
          : _cargoController.text.trim(),
      orgao: _orgaoController.text.trim().isEmpty
          ? null
          : _orgaoController.text.trim(),
      uf: _ufSelecionada,
      buscaSimilar: _buscaSimilar,
      limite: _limiteSelecionado,
    );

    // Emite o evento para a tela inteligente pai
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
            // 1. LINHA PRINCIPAL: Nome + Alternador de Similaridade
            // ================================================================
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                // Campo Nome com botão para limpar
                SizedBox(
                  width: 360,
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
                                onPressed: () {
                                  setState(() {
                                    _nomeController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) =>
                          setState(() {}), // Atualiza ícone de limpar
                    ),
                  ),
                ),

                // Alternador de Modo de Busca (SegmentedButton do Material 3)
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
                        tooltip: 'Busca o nome exatamente como digitado',
                      ),
                    ],
                    selected: {_buscaSimilar},
                    onSelectionChanged: (Set<bool> novaSelecao) {
                      setState(() {
                        _buscaSimilar = novaSelecao.first;
                      });
                    },
                  ),
                ),
              ],
            ),

            // ================================================================
            // 2. SANFONA DE FILTROS AVANÇADOS (Órgão, Cargo, UF e Limite)
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
                              // Cargo
                              SizedBox(
                                width: 280,
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

                              // Órgão / Instituição
                              SizedBox(
                                width: 320,
                                child: _CampoComLabel(
                                  label: 'Órgão / Instituição',
                                  child: TextField(
                                    controller: _orgaoController,
                                    onSubmitted: (_) => _dispararBusca(),
                                    decoration: const InputDecoration(
                                      hintText: 'Ex: Ministério da Saúde...',
                                      prefixIcon: Icon(
                                        Icons.account_balance_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Dropdown de UF
                              SizedBox(
                                width: 130,
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
                                      setState(() {
                                        _ufSelecionada = novoUf;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.map_outlined),
                                    ),
                                  ),
                                ),
                              ),

                              // Dropdown de Limite de Resultados (Requisito da API)
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
                                        child: Text('$limite registros'),
                                      );
                                    }).toList(),
                                    onChanged: (novoLimite) {
                                      if (novoLimite != null) {
                                        setState(() {
                                          _limiteSelecionado = novoLimite;
                                        });
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.format_list_numbered,
                                      ),
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

            // ================================================================
            // 3. BARRA DE AÇÕES (Limpar, Expandir e Submeter)
            // ================================================================
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 16,
              children: [
                // Botão de Sanfona
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _mostrarFiltrosAvancados = !_mostrarFiltrosAvancados;
                    });
                  },
                  icon: Icon(
                    _mostrarFiltrosAvancados ? Icons.expand_less : Icons.tune,
                  ),
                  label: Text(
                    _mostrarFiltrosAvancados
                        ? 'Recolher filtros'
                        : 'Filtros avançados (Órgão, UF, Limite)',
                  ),
                ),

                // Grupo de botões da direita
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão para resetar formulário
                    TextButton.icon(
                      onPressed: widget.isCarregando
                          ? null
                          : _limparTodosCampos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpar'),
                    ),
                    const SizedBox(width: 12),

                    // Botão Principal de Busca
                    ElevatedButton.icon(
                      onPressed: widget.isCarregando ? null : _dispararBusca,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        elevation: 2,
                      ),
                      icon: widget.isCarregando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        widget.isCarregando
                            ? 'Consultando...'
                            : 'Aplicar Filtros',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

/// Componente utilitário que padroniza o visual de Rótulo acima do Campo
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
