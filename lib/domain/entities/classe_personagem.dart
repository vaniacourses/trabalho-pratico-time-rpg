import 'habilidade.dart';

class ClassePersonagem {
  final String id;
  final String nome;
  final int proficienciaArmadura;
  final int proficienciaArma;
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
