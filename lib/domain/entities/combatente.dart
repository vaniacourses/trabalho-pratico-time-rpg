import 'atributos_base.dart';
import 'habilidade.dart';

abstract class Combatente {
  final String id;
  String nome;
  int nivel;
  int vidaMax;
  int classeArmadura;
  AtributosBase atributosBase;
  List<Habilidade> habilidadesPreparadas;
  
  Combatente({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.vidaMax,
    required this.classeArmadura,
    required this.atributosBase,
    required this.habilidadesPreparadas,
  });
}