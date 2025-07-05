import 'arma.dart';
import 'classe_personagem.dart';
import 'combatente.dart';
import 'habilidade.dart';
import 'raca.dart';
//import 'atributos_base.dart';

class Personagem extends Combatente {
  final Raca raca;
  final ClassePersonagem classe;
  // REMOVIDO: Atributos 'armadura' e 'arma' movidos para Combatente.
  
  // Equipamentos e habilidades específicas do personagem
  final Map<String, Arma> equipamentos;
  final List<Habilidade> habilidadesConhecidas;

  Personagem({
    // Parâmetros da classe Pai (Combatente)
    required super.id,
    required super.nome,
    required super.nivel,
    required super.vidaMax,
    required super.classeArmadura,
    required super.atributosBase,
    required super.habilidadesPreparadas,
    // ADICIONADO: Passando 'arma' e 'armadura' para o construtor super.
    super.arma,
    super.armadura,
    
    // Parâmetros específicos de Personagem
    required this.raca,
    required this.classe,
    required this.equipamentos,
    required this.habilidadesConhecidas,
  });
}