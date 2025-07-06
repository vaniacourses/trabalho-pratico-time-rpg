// data/models/armadura_model.dart
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';

class ArmaduraModel extends Armadura {
  ArmaduraModel({
    required super.id,
    required super.nome,
    required super.danoReduzido,
    required super.proficienciaRequerida,
  });

  // Factory constructor to create an ArmaduraModel from a Map (e.g., from SQLite)
  factory ArmaduraModel.fromMap(Map<String, dynamic> map) {
    return ArmaduraModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      danoReduzido: map['danoReduzido'] as int,
      proficienciaRequerida: ProficienciaArmadura.values[map['proficienciaRequerida'] as int],
    );
  }

  // Method to convert an ArmaduraModel to a Map (e.g., for SQLite insertion/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'danoReduzido': danoReduzido,
      'proficienciaRequerida': proficienciaRequerida.index, // Store the enum's index
    };
  }

  // Factory constructor to create an ArmaduraModel from an Armadura entity
  factory ArmaduraModel.fromEntity(Armadura entity) {
    return ArmaduraModel(
      id: entity.id,
      nome: entity.nome,
      danoReduzido: entity.danoReduzido,
      proficienciaRequerida: entity.proficienciaRequerida,
    );
  }
}