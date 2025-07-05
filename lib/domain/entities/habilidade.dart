import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
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

  // ATUALIZAÇÃO: O tipo do alvo agora é a interface genérica 'AlvoDeAcao'.
  void execute({required Combatente autor, required AlvoDeAcao alvo});

  Map<String, dynamic> toPersistenceMap();
}