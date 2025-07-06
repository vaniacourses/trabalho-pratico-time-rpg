import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_armadura_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';

class CriarPersonagemViewModel extends ChangeNotifier {
  final IRacaRepository _racaRepository;
  final IClassePersonagemRepository _classeRepository;
  final IArmaRepository _armaRepository;
  final IArmaduraRepository _armaduraRepository;
  final IHabilidadeRepository _habilidadeRepository;
  final IPersonagemRepository _personagemRepository;
  final IFichaFactory _fichaFactory;

  CriarPersonagemViewModel({
    required IRacaRepository racaRepository,
    required IClassePersonagemRepository classeRepository,
    required IArmaRepository armaRepository,
    required IArmaduraRepository armaduraRepository,
    required IHabilidadeRepository habilidadeRepository,
    required IPersonagemRepository personagemRepository,
    required IFichaFactory fichaFactory,
  })  : _racaRepository = racaRepository,
        _classeRepository = classeRepository,
        _armaRepository = armaRepository,
        _armaduraRepository = armaduraRepository,
        _habilidadeRepository = habilidadeRepository,
        _personagemRepository = personagemRepository,
        _fichaFactory = fichaFactory;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Raca> _racasDisponiveis = [];
  List<Raca> get racasDisponiveis => _racasDisponiveis;

  List<ClassePersonagem> _classesDisponiveis = [];
  List<ClassePersonagem> get classesDisponiveis => _classesDisponiveis;

  List<Arma> _armasDisponiveis = [];
  List<Arma> get armasDisponiveis => _armasDisponiveis;

  List<Armadura> _armadurasDisponiveis = [];
  List<Armadura> get armadurasDisponiveis => _armadurasDisponiveis;

  List<Habilidade> _habilidadesDisponiveis = [];
  List<Habilidade> get habilidadesDisponiveis => _habilidadesDisponiveis;

  Future<void> carregarDadosIniciais() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _racaRepository.getAll(),
        _classeRepository.getAll(),
        _armaRepository.getAll(), // Correct method name
        _armaduraRepository.getAllArmaduras(), // Correct method name
        _habilidadeRepository.getAll(),
      ]);
      _racasDisponiveis = results[0] as List<Raca>;
      _classesDisponiveis = results[1] as List<ClassePersonagem>;
      _armasDisponiveis = results[2] as List<Arma>;
      _armadurasDisponiveis = results[3] as List<Armadura>;
      _habilidadesDisponiveis = results[4] as List<Habilidade>;
    } catch (e) {
      _error = "Failed to load options: ${e.toString()}";
      debugPrint('Error loading initial data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarOuAtualizarPersonagem(
    PersonagemParams params, {
    String? id,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Personagem personagem = await _fichaFactory.criarPersonagem(
        params,
        id: id,
      );
      await _personagemRepository.save(personagem);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to save character: ${e.toString()}";
      debugPrint('Error saving character: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}