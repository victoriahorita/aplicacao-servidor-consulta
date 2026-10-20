import 'package:flutter/material.dart';

class AppFeedback {
  /// Exibe um diálogo modal padronizado para erros ou alertas informativos
  static void mostrarAlerta(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String mensagem,
    bool isErro = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          icone,
          size: 52,
          color: isErro ? Colors.redAccent : Colors.amber.shade800,
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isErro
                  ? Colors.redAccent
                  : Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe uma SnackBar rápida com mensagem e cor temática
  static void mostrarSnackBar(
    BuildContext context, {
    required String mensagem,
    bool isSucesso = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isSucesso ? const Color(0xFF15803D) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
