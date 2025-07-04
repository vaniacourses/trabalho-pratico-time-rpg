import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';

/// Define o "contrato" para o repositório de Classes de Personagem.
abstract class IClassePersonagemRepository {
  /// Salva uma nova classe ou atualiza uma existente.
  Future<void> save(ClassePersonagem classe);

  /// Deleta uma classe com base no seu ID.
  Future<void> delete(String id);

  /// Busca uma única classe pelo seu ID. Retorna nulo se não for encontrado.
  Future<ClassePersonagem?> getById(String id);

  /// Retorna uma lista com todas as classes cadastradas.
  Future<List<ClassePersonagem>> getAll();
}