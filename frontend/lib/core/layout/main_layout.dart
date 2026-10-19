import 'package:consulta_servidor/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget conteudo;
  final String titulo;
  final int indiceMenuAtivo;
  final bool mostrarBotaoVoltar;

  const MainLayout({
    super.key,
    required this.conteudo,
    required this.titulo,
    this.indiceMenuAtivo = 1, // 0: Início, 1: Buscar, 2: Histórico
    this.mostrarBotaoVoltar = false,
  });

  void _navegarPara(BuildContext context, int novoIndice) {
    if (novoIndice == indiceMenuAtivo) return;

    // Remove todas as rotas anteriores e substitui pela tela selecionada
    // evitando empilhar páginas infinitas na memória do navegador/desktop
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
    // SelectionArea no topo garante seleção de texto com o mouse em qualquer tela do app
    return SelectionArea(
      child: Scaffold(
        body: Row(
          children: [
            // ==========================================
            // 1. BARRA LATERAL (Sidebar Fixa)
            // ==========================================
            Container(
              width: 250,
              color: AppTheme.azulEscuro,
              child: Column(
                children: [
                  // Logo Institucional
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Servidor Federal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),

                  // Menus Relevantes e com Ação Real
                  _MenuItem(
                    icone: Icons.search,
                    titulo: 'Buscar Servidores',
                    ativo: indiceMenuAtivo == 1,
                    onTap: () => _navegarPara(context, 1),
                  ),
                  _MenuItem(
                    icone: Icons.history,
                    titulo: 'Histórico de Buscas',
                    ativo: indiceMenuAtivo == 2,
                    onTap: () => _navegarPara(context, 2),
                  ),

                  const Spacer(),

                  // Perfil do Usuário
                  const Divider(color: Colors.white24, height: 1),
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      'Convidado',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Acesso Público',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ==========================================
            // 2. CONTEÚDO PRINCIPAL (Com TopBar Única)
            // ==========================================
            Expanded(
              child: Column(
                children: [
                  // TopBar Padronizada
                  Container(
                    height: 70,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        if (mostrarBotaoVoltar) ...[
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppTheme.textoPrincipal,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'Voltar para a página anterior',
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textoPrincipal,
                          ),
                        ),
                        const Spacer(),
                        const CircleAvatar(
                          backgroundColor: AppTheme.azulPrincipal,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.bordas),

                  // O conteúdo de cada tela é injetado aqui sem criar outro Scaffold
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
        leading: Icon(icone, color: Colors.white),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
      ),
    );
  }
}
