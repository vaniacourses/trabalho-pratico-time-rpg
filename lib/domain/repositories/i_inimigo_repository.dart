import 'package:trabalho_rpg/domain/entities/inimigo.dart';

/// Define o "contrato" para o repositório de Inimigos.
abstract class IInimigoRepository {
  /// Salva um novo inimigo ou atualiza um existente.
  Future<void> save(Inimigo inimigo);

  /// Deleta um inimigo com base no seu ID.
  Future<void> delete(String id);

  /// Busca um único inimigo pelo seu ID. Retorna nulo se não for encontrado.
  Future<Inimigo?> getById(String id);

  /// Retorna uma lista com todos os inimigos cadastrados.
  Future<List<Inimigo>> getAll();
}