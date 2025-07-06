// Importa o enum de proficiência que definimos.
import 'enums/proficiencias.dart';

/// Representa uma peça de armadura no domínio do jogo.
class Armadura {
  /// O identificador único da armadura.
  final String id;

  /// O nome da armadura, que será exibido na UI. Ex: "Cota de Malha".
  final String nome;

  /// O valor fixo de dano que esta armadura absorve de cada ataque.
  final int danoReduzido;

  /// O nível de proficiência necessário para que um personagem
  /// possa usar esta armadura e se beneficiar da sua redução de dano.
  final ProficienciaArmadura proficienciaRequerida;

  Armadura({
    required this.id,
    required this.nome,
    required this.danoReduzido,
    required this.proficienciaRequerida,
  });

  // Added for convenience in update operations
  Armadura copyWith({
    String? id,
    String? nome,
    int? danoReduzido,
    ProficienciaArmadura? proficienciaRequerida,
  }) {
    return Armadura(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      danoReduzido: danoReduzido ?? this.danoReduzido,
      proficienciaRequerida: proficienciaRequerida ?? this.proficienciaRequerida,
    );
  }
}