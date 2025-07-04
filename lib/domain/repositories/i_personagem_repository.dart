import 'package:trabalho_rpg/domain/entities/personagem.dart';

/// Define o "contrato" para o repositório de personagens.
///
/// Qualquer classe que queira atuar como um repositório de personagens
/// deve implementar todos os métodos definidos aqui. Isso garante
/// o desacoplamento entre a camada de dados e a camada de apresentação.
abstract class IPersonagemRepository {
  /// Salva um novo personagem ou atualiza um existente.
  Future<void> save(Personagem personagem);

  /// Deleta um personagem com base no seu ID.
  Future<void> delete(String id);

  /// Busca um único personagem pelo seu ID. Retorna nulo se não for encontrado.
  Future<Personagem?> getById(String id);

  /// Retorna uma lista com todos os personagens.
  Future<List<Personagem>> getAll();
}
