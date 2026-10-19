// O programa só pode estar em um destes estados em qualquer momento. O estado é imutável, ou seja, não pode ser alterado depois de criado.
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';

sealed class ConsultaState {}

// State 1: Estado inicial, quando o usuário ainda não realizou nenhuma busca.
class ConsultaInitial extends ConsultaState {}

// State 2: Aguardando a API
class ConsultaLoading extends ConsultaState {}

// State 3: Estado de sucesso, quando a busca foi realizada com sucesso e os dados foram retornados.
class ConsultaSuccess extends ConsultaState {
  final List<Servidor> servidores;

  ConsultaSuccess(this.servidores);
}

// State 4: Estado de erro, quando houve algum problema na busca.
class ConsultaError extends ConsultaState {
  final String message;
  ConsultaError(this.message);
}
