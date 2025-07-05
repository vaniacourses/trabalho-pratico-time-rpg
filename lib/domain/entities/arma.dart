import 'alvo_de_acao.dart';
import 'combatente.dart';

class Arma {
  final String id;
  final String nome;
  final int danoBase;

  Arma({
    required this.id,
    required this.nome,
    required this.danoBase,
  });

  /// Método que encapsula a lógica do ataque básico.
  /// Ele precisa receber o 'autor' para acessar seus modificadores de atributo.
  void atacar({required Combatente autor, required AlvoDeAcao alvo}) {
    // A lógica é a mesma que estava na antiga classe AtaqueComArma.
    // Usamos o dano base da própria arma e adicionamos o bônus de atributo do autor.
    final int danoBruto = this.danoBase + autor.atributosBase.getModificador('forca');
    print(
      '${autor.nome} ataca o alvo com sua ${this.nome}, causando $danoBruto de dano bruto!',
    );
    // O alvo (Combatente ou Grupo) recebe o dano.
    alvo.receberDano(danoBruto);
  }
}