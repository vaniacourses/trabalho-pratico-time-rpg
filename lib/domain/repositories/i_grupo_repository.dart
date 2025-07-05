import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';

abstract class IGrupoRepository<T extends Combatente> {
  Future<void> save(Grupo<T> grupo);
  Future<void> delete(String id);
  Future<Grupo<T>?> getById(String id);
  Future<List<Grupo<T>>> getAll();
}