import 'package:trabalho_rpg/domain/entities/combatente.dart';

class Grupo<T extends Combatente> {
  final String id;
  String nome;
  List<T> membros;

  Grupo({
    required this.id,
    required this.nome,
    required this.membros,
  });
}