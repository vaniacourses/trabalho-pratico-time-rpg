import 'package:trabalho_rpg/domain/entities/habilidade.dart';

/// Define o "contrato" para o repositório de Habilidades.
abstract class IHabilidadeRepository {
  /// Salva uma nova habilidade ou atualiza uma existente.
  Future<void> save(Habilidade habilidade);

  /// Deleta uma habilidade com base no seu ID.
  Future<void> delete(String id);

  /// Busca uma única habilidade pelo seu ID. Retorna nulo se não for encontrado.
  Future<Habilidade?> getById(String id);

  /// Retorna uma lista com todas as habilidades cadastradas.
  Future<List<Habilidade>> getAll();

  /// ATUALIZAÇÃO: Novo método para buscar todas as habilidades de um combatente.
  /// Retorna um Map com as listas de habilidades conhecidas e preparadas.
  Future<Map<String, List<Habilidade>>> getAllForCombatente(String combatenteId);
}