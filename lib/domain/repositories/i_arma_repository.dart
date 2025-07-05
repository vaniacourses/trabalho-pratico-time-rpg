import 'package:trabalho_rpg/domain/entities/arma.dart';

/// Define o "contrato" para o repositório de Armas.
abstract class IArmaRepository {
  /// Salva uma nova arma ou atualiza uma existente.
  Future<void> save(Arma arma);

  /// Deleta uma arma com base no seu ID.
  Future<void> delete(String id);

  /// Busca uma única arma pelo seu ID. Retorna nulo se não for encontrado.
  Future<Arma?> getById(String id);

  /// Retorna uma lista com todas as armas cadastradas.
  Future<List<Arma>> getAll();
}