import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_cura_model.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_dano_model.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:uuid/uuid.dart';

class HabilidadesViewModel extends ChangeNotifier {
  final IHabilidadeRepository _habilidadeRepository;
  final Uuid _uuid;

  HabilidadesViewModel({
    required IHabilidadeRepository habilidadeRepository,
    required Uuid uuid,
  })  : _habilidadeRepository = habilidadeRepository,
        _uuid = uuid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Habilidade> _habilidades = [];
  List<Habilidade> get habilidades => _habilidades;

  String? _error;
  String? get error => _error;

  Future<void> fetchHabilidades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habilidades = await _habilidadeRepository.getAll();
    } catch (e) {
      _error = "Falha ao buscar habilidades: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveHabilidade({
    String? id,
    required String nome,
    required String descricao,
    required int custo,
    required int nivelExigido,
    required String categoria, // 'dano' ou 'cura'
    required int valorBase, // danoBase ou curaBase
  }) async {
    late Habilidade habilidade;

    // Lógica para criar o tipo correto de habilidade
    if (categoria == 'dano') {
      habilidade = HabilidadeDeDanoModel(
        id: id ?? _uuid.v4(),
        nome: nome,
        descricao: descricao,
        custo: custo,
        nivelExigido: nivelExigido,
        danoBase: valorBase,
      );
    } else if (categoria == 'cura') {
      habilidade = HabilidadeDeCuraModel(
        id: id ?? _uuid.v4(),
        nome: nome,
        descricao: descricao,
        custo: custo,
        nivelExigido: nivelExigido,
        curaBase: valorBase,
      );
    } else {
      _error = "Categoria de habilidade inválida.";
      notifyListeners();
      return;
    }

    try {
      await _habilidadeRepository.save(habilidade);
      await fetchHabilidades();
    } catch (e) {
      _error = "Falha ao salvar habilidade: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> deleteHabilidade(String id) async {
    try {
      await _habilidadeRepository.delete(id);
      await fetchHabilidades();
    } catch (e) {
      _error = "Falha ao deletar habilidade: ${e.toString()}";
      notifyListeners();
    }
  }
}