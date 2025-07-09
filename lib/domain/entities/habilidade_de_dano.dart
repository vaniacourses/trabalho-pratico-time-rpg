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
    // Modificador baseado em inteligência do autor
    final int modificadorInt = autor.atributosBase.getModificador('inteligencia');

    // Dano bruto sem considerar defesa
    final int danoBruto = danoBase + modificadorInt;

    // Caso o alvo seja um Combatente, calcula redução por armadura ou CA
    int danoFinal = danoBruto;
    if (alvo is Combatente) {
      int defesa = 0;
      if (alvo.armadura != null) {
        defesa = alvo.armadura!.danoReduzido;
      } else {
        defesa = alvo.classeArmadura;
      }

      danoFinal -= defesa;

      if (danoFinal < 1) danoFinal = 1;

      print('>>> ${autor.nome} usa "${nome}"!');
      print('    Dano base: $danoBase');
      print('    Mod. INT de ${autor.nome}: $modificadorInt');
      print('    Defesa de ${alvo.nome}: $defesa');
      print('    Dano final aplicado: $danoFinal');
    } else {
      print('>>> ${autor.nome} usa "${nome}"!');
      print('    Dano base: $danoBase');
      print('    Mod. INT de ${autor.nome}: $modificadorInt');
      print('    Dano final (sem defesa): $danoFinal');
    }

    alvo.receberDano(danoFinal);
  }
}