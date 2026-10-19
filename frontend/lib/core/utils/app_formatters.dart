import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _moedaReal = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final DateFormat _dataHora = DateFormat("dd/MM 'às' HH:mm");

  /// Formata um valor double para real (ex: R$ 8.500,00)
  static String formatarMoeda(double valor) => _moedaReal.format(valor);

  /// Formata uma data para o padrão de histórico (ex: 15/10 às 14:30)
  static String formatarDataHora(DateTime data) => _dataHora.format(data);
}
