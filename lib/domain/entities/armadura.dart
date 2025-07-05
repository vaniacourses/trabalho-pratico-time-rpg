// Importa o enum de proficiência que definimos anteriormente.
import 'enums/proficiencias.dart';

/// Representa uma peça de armadura no domínio do jogo.
class Armadura {
  // O nome da armadura, por exemplo, "Armadura de Couro".
  final String nome;
  
  // O valor fixo de dano que esta armadura absorve de um ataque.
  // Este é o atributo principal para o seu sistema de combate determinístico.
  final int reducaoDeDano;
  
  // O nível de proficiência necessário para usar esta armadura efetivamente.
  final ProficienciaArmadura proficienciaRequerida;

  Armadura({
    required this.nome,
    required this.reducaoDeDano,
    required this.proficienciaRequerida,
  });
}