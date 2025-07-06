import 'package:flutter/material.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
import 'package:trabalho_rpg/domain/repositories/i_armadura_repository.dart';
import 'package:uuid/uuid.dart';

class ArmadurasViewModel extends ChangeNotifier {
  final IArmaduraRepository armaduraRepository;
  final Uuid uuid;

  List<Armadura> _armaduras = [];
  bool _isLoading = false;
  String? _error;

  List<Armadura> get armaduras => _armaduras;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ArmadurasViewModel({required this.armaduraRepository, required this.uuid});

  Future<void> fetchArmaduras() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _armaduras = await armaduraRepository.getAllArmaduras();
    } catch (e) {
      _error = 'Failed to load armors: ${e.toString()}';
      debugPrint('Error fetching armors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveArmadura({
    String? id,
    required String nome,
    required int danoReduzido,
    required ProficienciaArmadura proficienciaRequerida,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      Armadura armadura;
      if (id == null) {
        armadura = Armadura(
          id: uuid.v4(),
          nome: nome,
          danoReduzido: danoReduzido,
          proficienciaRequerida: proficienciaRequerida,
        );
      } else {
        armadura = Armadura(
          id: id,
          nome: nome,
          danoReduzido: danoReduzido,
          proficienciaRequerida: proficienciaRequerida,
        );
      }
      await armaduraRepository.saveArmadura(armadura);
      await fetchArmaduras();
    } catch (e) {
      _error = 'Failed to save armor: ${e.toString()}';
      debugPrint('Error saving armor: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteArmadura(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await armaduraRepository.deleteArmadura(id);
      await fetchArmaduras();
    } catch (e) {
      _error = 'Failed to delete armor: ${e.toString()}';
      debugPrint('Error deleting armor: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}