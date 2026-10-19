import 'package:flutter/material.dart';

class AppTheme {
  // Cores exatas baseadas no seu design
  static const Color azulEscuro = Color(0xFF0B1B3D); // Cor da Sidebar
  static const Color azulPrincipal = Color(0xFF0D6EFD); // Botões
  static const Color fundoTelas = Color(0xFFF8F9FA); // Fundo cinza bem claro
  static const Color textoPrincipal = Color(0xFF2B3648);
  static const Color bordas = Color(0xFFE2E8F0);

  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: fundoTelas,
      colorScheme: ColorScheme.fromSeed(seedColor: azulPrincipal),
      useMaterial3: true,
      fontFamily:
          'Roboto', // Substitua pela fonte do seu design (ex: Inter, Poppins)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textoPrincipal),
        titleTextStyle: TextStyle(
          color: textoPrincipal,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: bordas),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: azulPrincipal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: bordas),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: bordas),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
