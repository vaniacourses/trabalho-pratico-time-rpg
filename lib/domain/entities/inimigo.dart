import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/iprototype.dart';
import 'package:uuid/uuid.dart';

// ATUALIZAÇÃO: Inimigo agora implementa IPrototype<Inimigo>
class Inimigo extends Combatente implements IPrototype<Inimigo> {
  final String tipo;
  Arma? arma;
  Arma? armadura;

  Inimigo({
    required super.id,
    required super.nome,
    required super.nivel,
    required super.vidaMax,
    required super.classeArmadura,
    required super.atributosBase,
    required super.habilidadesPreparadas,
    required this.tipo,
    this.arma,
    this.armadura,
  });

  // ATUALIZAÇÃO: Implementação do método clone do padrão Prototype.
  @override
  Inimigo clone() {
    print('Clonando o inimigo: "${this.nome}"...');

    // Cria uma nova instância de AtributosBase para que o clone tenha a sua própria.
    final atributosBaseClone = AtributosBase(
      forca: this.atributosBase.forca,
      destreza: this.atributosBase.destreza,
      constituicao: this.atributosBase.constituicao,
      inteligencia: this.atributosBase.inteligencia,
      sabedoria: this.atributosBase.sabedoria,
      carisma: this.atributosBase.carisma,
    );

    return Inimigo(
      // PONTO CRÍTICO: O clone DEVE ter um novo ID único.
      id: Uuid().v4(),
      nome: this.nome, // O nome é copiado.
      nivel: this.nivel,
      vidaMax: this.vidaMax,
      classeArmadura: this.classeArmadura,
      atributosBase: atributosBaseClone, // Usa a cópia dos atributos.
      // Cria uma nova lista, mas as habilidades em si são as mesmas referências.
      habilidadesPreparadas: List.from(this.habilidadesPreparadas),
      tipo: this.tipo,
      arma: this.arma, // Arma e armadura são compartilhadas (cópia rasa).
      armadura: this.armadura,
    );
  }
}