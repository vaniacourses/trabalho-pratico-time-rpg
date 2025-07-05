import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';

import 'habilidade.dart';

class ClassePersonagem {
  final String id;
  final String nome;
  final ProficienciaArmadura proficienciaArmadura;
  final ProficienciaArma proficienciaArma;
  // Lista de habilidades que esta classe pode aprender
  final List<Habilidade> habilidadesDisponiveis;

  ClassePersonagem({
    required this.id,
    required this.nome,
    required this.proficienciaArmadura,
    required this.proficienciaArma,
    required this.habilidadesDisponiveis,
  });
}
