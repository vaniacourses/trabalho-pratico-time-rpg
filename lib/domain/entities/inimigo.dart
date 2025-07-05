import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';

class Inimigo extends Combatente {
  // Atributo específico do Inimigo para categorização.
  final String tipo;
  
  // Um inimigo também pode ter uma arma e armadura padrão.
  Arma? arma;
  Arma? armadura;

  Inimigo({
    // Atributos herdados de Combatente
    required super.id,
    required super.nome,
    required super.nivel,
    required super.vidaMax,
    required super.classeArmadura,
    required super.atributosBase,
    required super.habilidadesPreparadas,
    
    // Atributos específicos
    required this.tipo,
    this.arma,
    this.armadura,
  });
}