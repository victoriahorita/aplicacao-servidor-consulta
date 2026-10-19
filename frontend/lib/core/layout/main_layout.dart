// ARQUIVO: lib/core/layout/main_layout.dart

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/status_banco.dart';

class MainLayout extends StatelessWidget {
  final Widget conteudo;
  final String titulo;
  final int indiceMenuAtivo;
  final bool mostrarBotaoVoltar;

  const MainLayout({
    super.key,
    required this.conteudo,
    required this.titulo,
    this.indiceMenuAtivo = 1,
    this.mostrarBotaoVoltar = false,
  });

  /// Navega entre as páginas principais substituindo a pilha de telas.
  void _navegarPara(BuildContext context, int novoIndice) {
    // Evita recarregar a mesma tela se o usuário clicar no menu onde já está
    if (novoIndice == indiceMenuAtivo) return;

    switch (novoIndice) {
      case 1:
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/buscar', (route) => false);
      case 2:
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/historico', (route) => false);
      default:
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/buscar', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 800;

    return SelectionArea(
      child: Scaffold(
        // Menu Gaveta
        drawer: isMobile
            ? Drawer(
                backgroundColor: AppTheme.azulEscuro,
                child: _ConteudoBarraLateral(
                  indiceMenuAtivo: indiceMenuAtivo,
                  onNavegar: (indice) => _navegarPara(context, indice),
                ),
              )
            : null,
        body: Row(
          children: [
            // Barra Lateral Fixa para Monitores Desktop e Web
            if (!isMobile)
              Container(
                width: 250,
                color: AppTheme.azulEscuro,
                child: _ConteudoBarraLateral(
                  indiceMenuAtivo: indiceMenuAtivo,
                  onNavegar: (indice) => _navegarPara(context, indice),
                ),
              ),

            // Conteúdo Central
            Expanded(
              child: Column(
                children: [
                  // TopBar
                  Container(
                    height: 70,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Ícone do Drawer (Hamburguer) visível apenas no mobile
                        if (isMobile && !mostrarBotaoVoltar) ...[
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: AppTheme.textoPrincipal,
                              ),
                              tooltip: 'Abrir menu de navegação',
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Botão de voltar para telas empilhadas
                        if (mostrarBotaoVoltar) ...[
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppTheme.textoPrincipal,
                            ),
                            tooltip: 'Voltar',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Título
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textoPrincipal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          tooltip: 'Sobre o Sistema',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.azulPrincipal,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.bordas),

                  // Área onde a página (conteúdo) é desenhada
                  Expanded(child: conteudo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConteudoBarraLateral extends StatelessWidget {
  final int indiceMenuAtivo;
  final ValueChanged<int> onNavegar;

  const _ConteudoBarraLateral({
    required this.indiceMenuAtivo,
    required this.onNavegar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: const [
                Icon(Icons.account_balance, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Servidor Federal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),

          // Itens de Navegação com seus respectivos índices
          _MenuItem(
            icone: Icons.search,
            titulo: 'Buscar Servidores',
            ativo: indiceMenuAtivo == 1,
            onTap: () => onNavegar(1),
          ),
          _MenuItem(
            icone: Icons.history,
            titulo: 'Histórico de Buscas',
            ativo: indiceMenuAtivo == 2,
            onTap: () => onNavegar(2),
          ),

          const Spacer(),

          // Status na base da barra lateral
          const Divider(color: Colors.white24, height: 1),
          const StatusConexaoBanco(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool ativo;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icone,
    required this.titulo,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ativo ? AppTheme.azulPrincipal : Colors.transparent,
      child: ListTile(
        leading: Icon(icone, color: Colors.white, size: 20),
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
      ),
    );
  }
}
