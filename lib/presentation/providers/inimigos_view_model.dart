import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/data/factories/inimigo_factory_impl.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';

class InimigosViewModel extends ChangeNotifier {
  final IInimigoRepository _inimigoRepository;
  final IArmaRepository _armaRepository;
  final IHabilidadeRepository _habilidadeRepository;
  final InimigoFactoryImpl _inimigoFactory;

  InimigosViewModel({
    required IInimigoRepository inimigoRepository,
    required IArmaRepository armaRepository,
    required IHabilidadeRepository habilidadeRepository,
    required InimigoFactoryImpl inimigoFactory,
  })  : _inimigoRepository = inimigoRepository,
       _armaRepository = armaRepository,
       _habilidadeRepository = habilidadeRepository,
       _inimigoFactory = inimigoFactory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Inimigo> _inimigos = [];
  List<Inimigo> get inimigos => _inimigos;

  // ATUALIZAÇÃO: Listas de opções para a UI
  List<Arma> _armasDisponiveis = [];
  List<Arma> get armasDisponiveis => _armasDisponiveis;

  List<Habilidade> _habilidadesDisponiveis = [];
  List<Habilidade> get habilidadesDisponiveis => _habilidadesDisponiveis;

  String? _error;
  String? get error => _error;

  Future<void> fetchInimigos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _inimigos = await _inimigoRepository.getAll();
    } catch (e) {
      _error = "Falha ao buscar inimigos: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ATUALIZAÇÃO: Método para carregar as opções para a tela de criação
  Future<void> carregarOpcoes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _armaRepository.getAll(),
        _habilidadeRepository.getAll(),
      ]);
      _armasDisponiveis = results[0] as List<Arma>;
      _habilidadesDisponiveis = results[1] as List<Habilidade>;
    } catch (e) {
      _error = "Falha ao carregar opções: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarOuAtualizarInimigo(InimigoParams params, {String? id}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final inimigo = await _inimigoFactory.criarInimigo(params);
      
      final inimigoParaSalvar = Inimigo(
        id: id ?? inimigo.id,
        nome: inimigo.nome,
        nivel: inimigo.nivel,
        vidaMax: inimigo.vidaMax,
        classeArmadura: inimigo.classeArmadura,
        atributosBase: inimigo.atributosBase,
        habilidadesPreparadas: inimigo.habilidadesPreparadas,
        tipo: inimigo.tipo,
        arma: inimigo.arma,
        armadura: inimigo.armadura,
      );
      
      await _inimigoRepository.save(inimigoParaSalvar);
      await fetchInimigos();
      return true;
    } catch (e) {
      _error = "Falha ao salvar inimigo: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInimigo(String id) async {
    try {
      await _inimigoRepository.delete(id);
      await fetchInimigos();
    } catch (e) {
      _error = "Falha ao deletar inimigo: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> clonarInimigo(Inimigo inimigo) async {
    try {
      final clone = inimigo.clone();
      await _inimigoRepository.save(clone);
      await fetchInimigos();
    } catch (e) {
      _error = "Falha ao clonar inimigo: ${e.toString()}";
      notifyListeners();
    }
  }
}