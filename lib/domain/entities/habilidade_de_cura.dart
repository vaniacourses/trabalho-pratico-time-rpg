import 'alvo_de_acao.dart';
import 'combatente.dart';
import 'habilidade.dart';

/// Uma implementação concreta de Habilidade que representa uma ação de cura.
class HabilidadeDeCura extends Habilidade {
  /// O valor base de cura da habilidade, antes de aplicar modificadores.
  final int curaBase;

  HabilidadeDeCura({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.custo,
    required super.nivelExigido,
    required this.curaBase,
  });

  /// Sobrescreve o método execute com a lógica específica para curar.
  @override
  void execute({required Combatente autor, required AlvoDeAcao alvo}) {
    // Exemplo de lógica: a cura é o valor base mais o modificador de Sabedoria do autor.
    // Ideal para uma magia divina de cura.
    final curaTotal = curaBase + autor.atributosBase.getModificador('sabedoria');

    print(
      '${autor.nome} usa a habilidade "${nome}", curando $curaTotal pontos de vida de seu alvo!',
    );

    // O alvo (seja um Combatente ou um Grupo) recebe a cura.
    alvo.receberCura(curaTotal);
  }
}