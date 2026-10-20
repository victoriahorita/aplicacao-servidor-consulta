import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';

sealed class ConsultaState {}

class ConsultaInitial extends ConsultaState {}

class ConsultaLoading extends ConsultaState {}

class ConsultaSuccess extends ConsultaState {
  final ResultadoPaginado resultado;

  ConsultaSuccess(this.resultado);
}

class ConsultaError extends ConsultaState {
  final String message;
  ConsultaError(this.message);
}
