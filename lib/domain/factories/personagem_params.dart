// Adicionamos os campos que faltavam
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';

class PersonagemParams {
  final String nome;
  final int nivel;
  final String racaId;
  final String classeId;
  final AtributosBase atributos;
  final String? armaId;
  final String? armaduraId;
  final List<String> habilidadesConhecidasIds;
  final List<String> habilidadesPreparadasIds;

  PersonagemParams({
    required this.nome,
    required this.nivel,
    required this.racaId,
    required this.classeId,
    required this.atributos,
    this.armaId,
    this.armaduraId,
    required this.habilidadesConhecidasIds,
    required this.habilidadesPreparadasIds,
  });
}