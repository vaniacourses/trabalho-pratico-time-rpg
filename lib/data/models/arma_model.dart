import 'package:trabalho_rpg/domain/entities/arma.dart';

class ArmaModel extends Arma {
  ArmaModel({
    required super.id,
    required super.nome,
    required super.danoBase,
  });

  /// Construtor de fábrica para criar uma instância a partir de um Map do BD.
  factory ArmaModel.fromMap(Map<String, dynamic> map) {
    return ArmaModel(
      id: map['id'],
      nome: map['nome'],
      danoBase: map['danoBase'],
    );
  }

  /// Método para converter a instância para um Map para o BD.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'danoBase': danoBase,
    };
  }
}