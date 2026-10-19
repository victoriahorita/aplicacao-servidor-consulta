import 'package:flutter/material.dart';

class NavigationUtils {
  /// Constrói uma rota com transição por Fade
  static Route<T> criarRotaFade<T>(Widget destino) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => destino,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 150),
    );
  }
}
