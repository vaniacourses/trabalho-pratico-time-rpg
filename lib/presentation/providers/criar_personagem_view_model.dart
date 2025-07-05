import 'package:flutter/foundation.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';

class CriarPersonagemViewModel extends ChangeNotifier {
  final IRacaRepository _racaRepository;
  final IClassePersonagemRepository _classeRepository;
  final IArmaRepository _armaRepository;
  final IHabilidadeRepository _habilidadeRepository;
  final IPersonagemRepository _personagemRepository;
  final IFichaFactory _fichaFactory;

  CriarPersonagemViewModel({
    required IRacaRepository racaRepository,
    required IClassePersonagemRepository classeRepository,
    required IArmaRepository armaRepository,
    required IHabilidadeRepository habilidadeRepository,
    required IPersonagemRepository personagemRepository,
    required IFichaFactory fichaFactory,
  })  : _racaRepository = racaRepository,
        _classeRepository = classeRepository,
        _armaRepository = armaRepository,
        _habilidadeRepository = habilidadeRepository,
        _personagemRepository = personagemRepository,
        _fichaFactory = fichaFactory;

  // --- ESTADO DA UI ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Raca> _racasDisponiveis = [];
  List<Raca> get racasDisponiveis => _racasDisponiveis;

  List<ClassePersonagem> _classesDisponiveis = [];
  List<ClassePersonagem> get classesDisponiveis => _classesDisponiveis;
  
  // (Opcional) Poderíamos carregar armas e habilidades aqui também.

  // --- AÇÕES ---

  /// Carrega todas as opções necessárias dos repositórios.
  Future<void> carregarDadosIniciais() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Executa todas as buscas em paralelo para mais eficiência.
      final results = await Future.wait([
        _racaRepository.getAll(),
        _classeRepository.getAll(),
      ]);
      _racasDisponiveis = results[0] as List<Raca>;
      _classesDisponiveis = results[1] as List<ClassePersonagem>;
    } catch (e) {
      _error = "Falha ao carregar opções: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Usa a factory para criar e o repositório para salvar o personagem.
  Future<bool> criarEsalvarPersonagem(PersonagemParams params) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Usa a factory para criar a instância complexa do personagem.
      Personagem novoPersonagem = await _fichaFactory.criarPersonagem(params);
      
      // Usa o repositório para salvar o personagem no banco de dados.
      await _personagemRepository.save(novoPersonagem);
      
      _isLoading = false;
      notifyListeners();
      return true; // Retorna sucesso
    } catch (e) {
      _error = "Falha ao criar personagem: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false; // Retorna falha
    }
  }
}