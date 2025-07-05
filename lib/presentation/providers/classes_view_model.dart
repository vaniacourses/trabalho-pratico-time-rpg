import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:uuid/uuid.dart';

class ClassesViewModel extends ChangeNotifier {
  final IClassePersonagemRepository _classeRepository;
  final Uuid _uuid;

  ClassesViewModel({
    required IClassePersonagemRepository classeRepository,
    required Uuid uuid,
  })  : _classeRepository = classeRepository,
        _uuid = uuid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ClassePersonagem> _classes = [];
  List<ClassePersonagem> get classes => _classes;

  String? _error;
  String? get error => _error;

  Future<void> fetchClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classes = await _classeRepository.getAll();
    } catch (e) {
      _error = "Falha ao buscar classes: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveClasse({
    String? id,
    required String nome,
    // MUDANÇA: Os tipos dos parâmetros foram atualizados de 'int' para os enums.
    required ProficienciaArmadura profArmadura,
    required ProficienciaArma profArma,
  }) async {
    // Agora a entidade é criada passando os valores de enum diretamente.
    final classe = ClassePersonagem(
      id: id ?? _uuid.v4(),
      nome: nome,
      proficienciaArmadura: profArmadura,
      proficienciaArma: profArma,
      habilidadesDisponiveis: [], // Deixado vazio por enquanto
    );

    try {
      await _classeRepository.save(classe);
      await fetchClasses();
    } catch (e) {
      _error = "Falha ao salvar classe: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> deleteClasse(String id) async {
    try {
      await _classeRepository.delete(id);
      await fetchClasses();
    } catch (e) {
      _error = "Falha ao deletar classe: ${e.toString()}";
      notifyListeners();
    }
  }
}