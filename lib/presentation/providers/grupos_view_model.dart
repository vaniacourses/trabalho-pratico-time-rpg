import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/repositories/i_grupo_repository.dart';
import 'package:uuid/uuid.dart';

class GruposViewModel extends ChangeNotifier {
  final IGrupoRepository<Personagem> _grupoPersonagemRepository;
  final IGrupoRepository<Inimigo> _grupoInimigoRepository;
  final Uuid _uuid;

  GruposViewModel({
    required IGrupoRepository<Personagem> grupoPersonagemRepository,
    required IGrupoRepository<Inimigo> grupoInimigoRepository,
    required Uuid uuid,
  })  : _grupoPersonagemRepository = grupoPersonagemRepository,
        _grupoInimigoRepository = grupoInimigoRepository,
        _uuid = uuid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Grupo<Personagem>> _gruposDePersonagens = [];
  List<Grupo<Personagem>> get gruposDePersonagens => _gruposDePersonagens;

  List<Grupo<Inimigo>> _gruposDeInimigos = [];
  List<Grupo<Inimigo>> get gruposDeInimigos => _gruposDeInimigos;

  Future<void> fetchTodosOsGrupos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _grupoPersonagemRepository.getAll(),
        _grupoInimigoRepository.getAll(),
      ]);
      _gruposDePersonagens = results[0] as List<Grupo<Personagem>>;
      _gruposDeInimigos = results[1] as List<Grupo<Inimigo>>;
    } catch (e) {
      _error = "Falha ao buscar grupos: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveGrupoDePersonagens({
    String? id,
    required String nome,
    required List<Personagem> membros,
  }) async {
    final grupo = Grupo<Personagem>(
      id: id ?? _uuid.v4(),
      nome: nome,
      membros: membros,
    );
    await _grupoPersonagemRepository.save(grupo);
    await fetchTodosOsGrupos();
  }

  Future<void> saveGrupoDeInimigos({
    String? id,
    required String nome,
    required List<Inimigo> membros,
  }) async {
    final grupo = Grupo<Inimigo>(
      id: id ?? _uuid.v4(),
      nome: nome,
      membros: membros,
    );
    await _grupoInimigoRepository.save(grupo);
    await fetchTodosOsGrupos();
  }

  Future<void> deleteGrupo(String id) async {
    // Tentamos deletar dos dois repositórios; um deles funcionará.
    try {
      await _grupoPersonagemRepository.delete(id);
    } catch (_) {}
    try {
      await _grupoInimigoRepository.delete(id);
    } catch (_) {}
    await fetchTodosOsGrupos();
  }
}