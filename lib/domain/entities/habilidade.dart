import 'package:trabalho_rpg/domain/entities/combatente.dart';

abstract class Habilidade {
  final String id;
  final String nome;
  final String descricao;
  final int custo;
  final int nivelExigido;

  Habilidade({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.custo,
    required this.nivelExigido,
  });

  void execute({required Combatente autor, required Combatente alvo});

  // ATUALIZAÇÃO: Adicionado método para persistência polimórfica.
  Map<String, dynamic> toPersistenceMap();
}