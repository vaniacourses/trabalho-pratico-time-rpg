import 'alvo_de_acao.dart';
import 'combatente.dart';
import 'habilidade.dart';

/// Uma implementação concreta de Habilidade que representa uma ação de dano.
class HabilidadeDeDano extends Habilidade {
  /// O valor base de dano da habilidade, antes de aplicar modificadores.
  final int danoBase;

  HabilidadeDeDano({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.custo,
    required super.nivelExigido,
    required this.danoBase,
  });

  @override
  void execute({required Combatente autor, required AlvoDeAcao alvo}) {
    // Exemplo de lógica: o dano é o valor base mais o modificador de Inteligência do autor.
    // Ideal para uma magia de ataque.
    final danoTotal = danoBase + autor.atributosBase.getModificador('inteligencia');
    print(
      '${autor.nome} usa a habilidade "${nome}", causando $danoTotal de dano em seu alvo!',
    );
    // O alvo (seja um Combatente ou um Grupo) recebe o dano.
    alvo.receberDano(danoTotal);
  }
}