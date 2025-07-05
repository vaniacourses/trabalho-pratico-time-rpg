import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';

class PersonagensViewModel extends ChangeNotifier {
  final IPersonagemRepository _personagemRepository;

  PersonagensViewModel({required IPersonagemRepository personagemRepository})
      : _personagemRepository = personagemRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Personagem> _personagens = [];
  List<Personagem> get personagens => _personagens;

  String? _error;
  String? get error => _error;

  Future<void> fetchPersonagens() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _personagens = await _personagemRepository.getAll();
    } catch (e) {
      _error = "Falha ao buscar personagens: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePersonagem(String id) async {
    try {
      await _personagemRepository.delete(id);
      await fetchPersonagens();
    } catch (e) {
      _error = "Falha ao deletar personagem: ${e.toString()}";
      notifyListeners();
    }
  }
}