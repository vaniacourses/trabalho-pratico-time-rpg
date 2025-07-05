import 'package:trabalho_rpg/domain/entities/atributos_base.dart';

class InimigoParams {
  final String nome;
  final int nivel;
  final String tipo;
  final AtributosBase atributos;
  // ATUALIZAÇÃO: Campos adicionados
  final String? armaId;
  final String? armaduraId;
  final List<String> habilidadesIds;

  InimigoParams({
    required this.nome,
    required this.nivel,
    required this.tipo,
    required this.atributos,
    this.armaId,
    this.armaduraId,
    this.habilidadesIds = const [], // Garante que seja sempre uma lista
  });
}