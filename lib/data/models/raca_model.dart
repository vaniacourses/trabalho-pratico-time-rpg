import 'dart:convert';
import 'package:trabalho_rpg/domain/entities/raca.dart';

class RacaModel extends Raca {
  RacaModel({
    required super.id,
    required super.nome,
    required super.modificadoresDeAtributo,
  });

  /// Construtor de fábrica para criar uma instância de RacaModel a partir de um Map.
  /// Este Map vem diretamente da linha do banco de dados.
  factory RacaModel.fromMap(Map<String, dynamic> map) {
    return RacaModel(
      id: map['id'],
      nome: map['nome'],
      // Decodifica a string JSON armazenada no banco de dados de volta para um Map.
      // O `as Map<String, int>` garante a tipagem correta.
      modificadoresDeAtributo: Map<String, int>.from(
        json.decode(map['modificadoresDeAtributo']),
      ),
    );
  }

  /// Método para converter a instância de RacaModel para um Map.
  /// Este Map será usado para inserir/atualizar a linha no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      // Codifica o Map de modificadores para uma string no formato JSON.
      'modificadoresDeAtributo': json.encode(modificadoresDeAtributo),
    };
  }
}
