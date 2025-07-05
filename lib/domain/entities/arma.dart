import 'enums/proficiencias.dart';

class Arma {
  final String nome;
  final int danoBase;
  final ProficienciaArma proficienciaRequerida;
  Arma({
    required this.proficienciaRequerida,
    required this.nome,
    required this.danoBase,
  });
}