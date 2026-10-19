import 'package:consulta_servidor/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget conteudo;
  final String titulo;

  const MainLayout({super.key, required this.conteudo, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. BARRA LATERAL (Sidebar) Fixa
          Container(
            width: 250,
            color: AppTheme.azulEscuro,
            child: Column(
              children: [
                // Logo da Instituição
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Consulta de Dados dos Servidores Públicos',
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

                // Menus de Navegação
                _MenuItem(
                  icone: Icons.home_outlined,
                  titulo: 'Início',
                  ativo: false,
                ),
                _MenuItem(
                  icone: Icons.search,
                  titulo: 'Buscar',
                  ativo: true,
                ), // Ativo no mockup
                _MenuItem(
                  icone: Icons.star_border,
                  titulo: 'Favoritos',
                  ativo: false,
                ),
                _MenuItem(
                  icone: Icons.history,
                  titulo: 'Histórico',
                  ativo: false,
                ),
                _MenuItem(
                  icone: Icons.info_outline,
                  titulo: 'Sobre',
                  ativo: false,
                ),

                const Spacer(),

                // Perfil inferior na Sidebar
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    'Convidado',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Acesso público',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 2. ÁREA DE CONTEÚDO PRINCIPAL
          Expanded(
            child: Column(
              children: [
                // TopBar Branca
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textoPrincipal,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.light_mode_outlined),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      const CircleAvatar(
                        backgroundColor: AppTheme.azulPrincipal,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.bordas),

                // O conteúdo dinâmico (a tela em si)
                Expanded(child: conteudo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool ativo;

  const _MenuItem({
    required this.icone,
    required this.titulo,
    required this.ativo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ativo ? AppTheme.azulPrincipal : Colors.transparent,
      child: ListTile(
        leading: Icon(icone, color: Colors.white),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        onTap: () {
          // Lógica de navegação iria aqui
        },
      ),
    );
  }
}
