import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';

class InimigosViewModel extends ChangeNotifier {
  final IInimigoRepository _inimigoRepository;
  final IFichaFactory _fichaFactory;

  InimigosViewModel({
    required IInimigoRepository inimigoRepository,
    required IFichaFactory fichaFactory,
  })  : _inimigoRepository = inimigoRepository,
        _fichaFactory = fichaFactory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Inimigo> _inimigos = [];
  List<Inimigo> get inimigos => _inimigos;

  String? _error;
  String? get error => _error;

  Future<void> fetchInimigos() async {
    _isLoading = true;
    _error = null;
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

  Future<bool> criarOuAtualizarInimigo(InimigoParams params, {String? id}) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Usamos a factory para criar a instância.
      // Em uma implementação real, o InimigoFactory seria usado aqui.
      // Por simplicidade, vamos criar direto no repositório.
      // Esta lógica pode ser movida para a factory depois.
      final inimigo = await _fichaFactory.criarInimigo(params);
      
      // Se for edição, mantemos o ID original.
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
      // Usa o padrão Prototype!
      final clone = inimigo.clone();
      await _inimigoRepository.save(clone);
      await fetchInimigos();
    } catch (e) {
      _error = "Falha ao clonar inimigo: ${e.toString()}";
      notifyListeners();
    }
  }
}