import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:uuid/uuid.dart';

class ArmasViewModel extends ChangeNotifier {
  final IArmaRepository _armaRepository;
  final Uuid _uuid;

  ArmasViewModel({
    required IArmaRepository armaRepository,
    required Uuid uuid,
  })  : _armaRepository = armaRepository,
        _uuid = uuid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Arma> _armas = [];
  List<Arma> get armas => _armas;

  String? _error;
  String? get error => _error;

  Future<void> fetchArmas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _armas = await _armaRepository.getAll();
    } catch (e) {
      _error = "Falha ao buscar armas: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveArma({
    String? id,
    required String nome,
    required int danoBase,
  }) async {
    final arma = Arma(
      id: id ?? _uuid.v4(),
      nome: nome,
      danoBase: danoBase,
    );

    try {
      await _armaRepository.save(arma);
      await fetchArmas();
    } catch (e) {
      _error = "Falha ao salvar arma: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> deleteArma(String id) async {
    try {
      await _armaRepository.delete(id);
      await fetchArmas();
    } catch (e) {
      _error = "Falha ao deletar arma: ${e.toString()}";
      notifyListeners();
    }
  }
}