import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart'; // Mantemos Grupo para tipos base
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/repositories/i_grupo_repository.dart';
import 'package:uuid/uuid.dart';

// Importe o GrupoModel para usar o tipo específico
import 'package:trabalho_rpg/data/models/grupo_model.dart'; // <-- Ajuste este caminho se necessário!

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

  // <--- CORREÇÃO AQUI: Alteramos o tipo das listas internas e dos getters para GrupoModel
  List<GrupoModel<Personagem>> _gruposDePersonagens = [];
  List<GrupoModel<Personagem>> get gruposDePersonagens => _gruposDePersonagens;

  List<GrupoModel<Inimigo>> _gruposDeInimigos = [];
  List<GrupoModel<Inimigo>> get gruposDeInimigos => _gruposDeInimigos;

  Future<void> fetchTodosOsGrupos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _grupoPersonagemRepository.getAll(),
        _grupoInimigoRepository.getAll(),
      ]);

      // <--- CORREÇÃO AQUI: Cast explícito na atribuição
      // Assumimos que getAll() retorna GruposModel, mas como o retorno é List<Grupo<T>>,
      // precisamos do cast para atribuir à lista de GruposModel.
      _gruposDePersonagens = (results[0] as List<Grupo<Personagem>>)
          .cast<GrupoModel<Personagem>>();
      _gruposDeInimigos = (results[1] as List<Grupo<Inimigo>>)
          .cast<GrupoModel<Inimigo>>();
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
    // <--- CORREÇÃO AQUI: Instanciamos GrupoModel em vez de Grupo
    final grupo = GrupoModel<Personagem>(
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
    final grupo = GrupoModel<Inimigo>(
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
    } catch (_) {
      // Ignorar erro se o grupo não for encontrado em um repositório
    }
    try {
      await _grupoInimigoRepository.delete(id);
    } catch (_) {
      // Ignorar erro se o grupo não for encontrado em outro repositório
    }
    await fetchTodosOsGrupos();
  }
}