import 'package:trabalho_rpg/domain/entities/raca.dart';

/// Define o "contrato" para o repositório de Raças.
abstract class IRacaRepository {
  /// Salva uma nova raça ou atualiza uma existente.
  Future<void> save(Raca raca);

  /// Deleta uma raça com base no seu ID.
  Future<void> delete(String id);

  /// Busca uma única raça pelo seu ID. Retorna nulo se não for encontrado.
  Future<Raca?> getById(String id);

  /// Retorna uma lista com todas as raças cadastradas.
  Future<List<Raca>> getAll();
}
