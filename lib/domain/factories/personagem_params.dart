import 'package:trabalho_rpg/domain/entities/atributos_base.dart';

/// Agrupa todos os parâmetros necessários para criar um novo personagem.
class PersonagemParams {
  final String nome;
  final int nivel;
  final String racaId; // <-- Recebemos o ID, não o objeto
  final String classeId; // <-- Recebemos o ID, não o objeto
  final AtributosBase atributos;
  // Poderíamos adicionar IDs de armas, armaduras, etc. aqui também.

  PersonagemParams({
    required this.nome,
    required this.nivel,
    required this.racaId,
    required this.classeId,
    required this.atributos,
  });
}