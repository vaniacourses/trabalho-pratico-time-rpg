import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:uuid/uuid.dart';

class RacasViewModel extends ChangeNotifier {
  final IRacaRepository _racaRepository;
  final Uuid _uuid;

  RacasViewModel({
    required IRacaRepository racaRepository,
    required Uuid uuid,
  })  : _racaRepository = racaRepository,
        _uuid = uuid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Raca> _racas = [];
  List<Raca> get racas => _racas;

  String? _error;
  String? get error => _error;

  Future<void> fetchRacas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _racas = await _racaRepository.getAll();
    } catch (e) {
      _error = "Falha ao buscar raças: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ATUALIZAÇÃO: O método agora aceita o mapa de modificadores.
  Future<void> saveRaca({
    String? id,
    required String nome,
    required Map<String, int> modificadores, // <-- NOVO PARÂMETRO
  }) async {
    final raca = Raca(
      id: id ?? _uuid.v4(),
      nome: nome,
      modificadoresDeAtributo: modificadores, // <-- USA O NOVO PARÂMETRO
    );

    try {
      await _racaRepository.save(raca);
      await fetchRacas();
    } catch (e) {
      _error = "Falha ao salvar raça: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> deleteRaca(String id) async {
    try {
      await _racaRepository.delete(id);
      await fetchRacas();
    } catch (e) {
      _error = "Falha ao deletar raça: ${e.toString()}";
      notifyListeners();
    }
  }
}