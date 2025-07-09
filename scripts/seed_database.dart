import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/factories/inimigo_factory_impl.dart';
import 'package:trabalho_rpg/data/factories/personagem_factory_impl.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_cura_model.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_dano_model.dart';
import 'package:trabalho_rpg/data/repositories/arma_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/armadura_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/classe_personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/habilidade_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/inimigo_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/raca_repository_impl.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_armadura_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:uuid/uuid.dart';

// Este script pode ser executado de forma independente para popular o banco de dados.
// Use o comando: dart scripts/seed_database.dart

Future<void> main() async {
  // Inicialização do SQFlite para ambiente Dart (não-Flutter)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // --- Injeção de Dependência Manual ---
  final dbHelper = DatabaseHelper.instance;
  final uuid = Uuid();

  final racaRepo = RacaRepositoryImpl(dbHelper: dbHelper);
  final classeRepo = ClassePersonagemRepositoryImpl(dbHelper: dbHelper);
  final armaRepo = ArmaRepositoryImpl(dbHelper: dbHelper);
  final armaduraRepo = ArmaduraRepositoryImpl(dbHelper: dbHelper);
  final habilidadeRepo = HabilidadeRepositoryImpl(dbHelper: dbHelper);
  
  // As dependências dos repositórios precisam ser construídas na ordem correta
  final personagemRepo = PersonagemRepositoryImpl(
    dbHelper: dbHelper,
    habilidadeRepository: habilidadeRepo,
    racaRepository: racaRepo,
    classeRepository: classeRepo,
    armaRepository: armaRepo,
    armaduraRepository: armaduraRepo,
  );
  
  final inimigoRepo = InimigoRepositoryImpl(
    dbHelper: dbHelper,
    habilidadeRepository: habilidadeRepo,
    armaRepository: armaRepo,
  );

  final personagemFactory = PersonagemFactoryImpl(
    racaRepository: racaRepo,
    classeRepository: classeRepo,
    armaRepository: armaRepo,
    armaduraRepository: armaduraRepo,
    habilidadeRepository: habilidadeRepo,
    uuid: uuid,
  );

  final inimigoFactory = InimigoFactoryImpl(
    armaRepository: armaRepo,
    armaduraRepository: armaduraRepo,
    habilidadeRepository: habilidadeRepo,
    uuid: uuid,
  );

  // --- LÓGICA DE LIMPEZA CORRIGIDA ---
  print('--- Limpando banco de dados antigo (se existir)... ---');
  // Obtém o caminho do banco de dados e o deleta diretamente.
  // Isso garante que o DatabaseHelper irá criar um novo do zero na próxima vez que for acessado.
  final dbPath = join(await getDatabasesPath(), 'rpg_database.db');
  await deleteDatabase(dbPath);
  print('--- Banco de dados limpo. ---');


  print('--- Iniciando Seeding do Banco de Dados ---');
  
  try {
    // 1. Popular entidades independentes
    await _seedRacas(racaRepo, uuid);
    await _seedClasses(classeRepo, uuid);
    await _seedArmas(armaRepo, uuid);
    await _seedArmaduras(armaduraRepo, uuid);
    await _seedHabilidades(habilidadeRepo, uuid);
    print('[OK] Entidades independentes populadas.');

    // 2. Buscar as entidades criadas para obter seus IDs
    final racas = await racaRepo.getAll();
    final classes = await classeRepo.getAll();
    final armas = await armaRepo.getAll();
    final armaduras = await armaduraRepo.getAllArmaduras();
    final habilidades = await habilidadeRepo.getAll();
    print('[OK] Entidades independentes buscadas do banco.');

    // 3. Popular entidades dependentes usando os dados buscados
    await _seedPersonagens(personagemRepo, personagemFactory, racas, classes, armas, armaduras, habilidades);
    await _seedInimigos(inimigoRepo, inimigoFactory, armas, armaduras, habilidades);
    print('[OK] Entidades dependentes populadas.');

    print('\n--- Seeding Concluído com Sucesso! ---');
  } catch (e, s) {
    print('\n--- OCORREU UM ERRO DURANTE O SEEDING ---');
    print('Erro: $e');
    print('StackTrace: $s');
  }
}

// Funções de seeding para cada entidade (sem alterações)

Future<void> _seedRacas(IRacaRepository repo, Uuid uuid) async {
  final racas = [
    Raca(id: uuid.v4(), nome: 'Humano', modificadoresDeAtributo: {'carisma': 1, 'constituicao': 1}),
    Raca(id: uuid.v4(), nome: 'Elfo da Floresta', modificadoresDeAtributo: {'destreza': 2, 'sabedoria': 1}),
    Raca(id: uuid.v4(), nome: 'Anão da Montanha', modificadoresDeAtributo: {'forca': 2, 'constituicao': 2}),
    Raca(id: uuid.v4(), nome: 'Halfling Pés Leves', modificadoresDeAtributo: {'destreza': 2, 'carisma': 1}),
    Raca(id: uuid.v4(), nome: 'Draconato', modificadoresDeAtributo: {'forca': 2, 'carisma': 1}),
  ];
  for (final raca in racas) {
    await repo.save(raca);
  }
}

Future<void> _seedClasses(IClassePersonagemRepository repo, Uuid uuid) async {
  final classes = [
    ClassePersonagem(id: uuid.v4(), nome: 'Guerreiro', proficienciaArmadura: ProficienciaArmadura.Pesada, proficienciaArma: ProficienciaArma.Marcial, habilidadesDisponiveis: []),
    ClassePersonagem(id: uuid.v4(), nome: 'Mago', proficienciaArmadura: ProficienciaArmadura.Nenhuma, proficienciaArma: ProficienciaArma.Simples, habilidadesDisponiveis: []),
    ClassePersonagem(id: uuid.v4(), nome: 'Ladino', proficienciaArmadura: ProficienciaArmadura.Leve, proficienciaArma: ProficienciaArma.Simples, habilidadesDisponiveis: []),
    ClassePersonagem(id: uuid.v4(), nome: 'Clérigo', proficienciaArmadura: ProficienciaArmadura.Media, proficienciaArma: ProficienciaArma.Simples, habilidadesDisponiveis: []),
    ClassePersonagem(id: uuid.v4(), nome: 'Patrulheiro', proficienciaArmadura: ProficienciaArmadura.Media, proficienciaArma: ProficienciaArma.Marcial, habilidadesDisponiveis: []),
  ];
  for (final classe in classes) {
    await repo.save(classe);
  }
}

Future<void> _seedArmas(IArmaRepository repo, Uuid uuid) async {
  final armas = [
    Arma(id: uuid.v4(), nome: 'Espada Longa', danoBase: 8),
    Arma(id: uuid.v4(), nome: 'Adaga', danoBase: 4),
    Arma(id: uuid.v4(), nome: 'Arco Curto', danoBase: 6),
    Arma(id: uuid.v4(), nome: 'Machado Grande', danoBase: 12),
    Arma(id: uuid.v4(), nome: 'Cajado Místico', danoBase: 4),
  ];
  for (final arma in armas) {
    await repo.save(arma);
  }
}

Future<void> _seedArmaduras(IArmaduraRepository repo, Uuid uuid) async {
  final armaduras = [
    Armadura(id: uuid.v4(), nome: 'Armadura de Couro', danoReduzido: 2, proficienciaRequerida: ProficienciaArmadura.Leve),
    Armadura(id: uuid.v4(), nome: 'Cota de Malha', danoReduzido: 4, proficienciaRequerida: ProficienciaArmadura.Media),
    Armadura(id: uuid.v4(), nome: 'Armadura de Placas', danoReduzido: 6, proficienciaRequerida: ProficienciaArmadura.Pesada),
    Armadura(id: uuid.v4(), nome: 'Roupas Acolchoadas', danoReduzido: 1, proficienciaRequerida: ProficienciaArmadura.Leve),
  ];
  for (final armadura in armaduras) {
    await repo.saveArmadura(armadura);
  }
}

Future<void> _seedHabilidades(IHabilidadeRepository repo, Uuid uuid) async {
  final habilidades = [
    HabilidadeDeDanoModel(id: uuid.v4(), nome: 'Bola de Fogo', descricao: 'Explosão de fogo em área.', custo: 15, nivelExigido: 3, danoBase: 20),
    HabilidadeDeDanoModel(id: uuid.v4(), nome: 'Míssil Mágico', descricao: 'Projétil de energia que nunca erra.', custo: 5, nivelExigido: 1, danoBase: 10),
    HabilidadeDeCuraModel(id: uuid.v4(), nome: 'Curar Ferimentos', descricao: 'Restaura pontos de vida de um alvo.', custo: 10, nivelExigido: 1, curaBase: 15),
    HabilidadeDeCuraModel(id: uuid.v4(), nome: 'Palavra de Cura', descricao: 'Cura um alvo à distância.', custo: 8, nivelExigido: 2, curaBase: 12),
    HabilidadeDeDanoModel(id: uuid.v4(), nome: 'Ataque Furtivo', descricao: 'Causa dano extra ao atacar com vantagem.', custo: 0, nivelExigido: 1, danoBase: 6),
  ];
  for (final habilidade in habilidades) {
    await repo.save(habilidade);
  }
}

Future<void> _seedPersonagens(
  IPersonagemRepository repo,
  PersonagemFactoryImpl factory,
  List<Raca> racas,
  List<ClassePersonagem> classes,
  List<Arma> armas,
  List<Armadura> armaduras,
  List<Habilidade> habilidades,
) async {
  final random = Random();
  final nomes = ['Aragorn', 'Legolas', 'Gimli', 'Gandalf', 'Frodo', 'Galadriel', 'Boromir'];
  
  for (int i = 0; i < 5; i++) {
    final raca = racas[random.nextInt(racas.length)];
    final classe = classes[random.nextInt(classes.length)];
    final arma = armas[random.nextInt(armas.length)];
    final armadura = armaduras[random.nextInt(armaduras.length)];
    final habilidade = habilidades[random.nextInt(habilidades.length)];

    final params = PersonagemParams(
      nome: '${nomes[random.nextInt(nomes.length)]} ${i+1}',
      nivel: random.nextInt(5) + 1,
      racaId: raca.id,
      classeId: classe.id,
      armaId: arma.id,
      armaduraId: armadura.id,
      habilidadesConhecidasIds: [habilidade.id],
      habilidadesPreparadasIds: [habilidade.id],
      atributos: AtributosBase(forca: 10 + random.nextInt(9), destreza: 10 + random.nextInt(9), constituicao: 10 + random.nextInt(9), inteligencia: 10 + random.nextInt(9), sabedoria: 10 + random.nextInt(9), carisma: 10 + random.nextInt(9)),
    );
    final personagem = await factory.criarPersonagem(params);
    await repo.save(personagem);
  }
}

Future<void> _seedInimigos(
  IInimigoRepository repo,
  InimigoFactoryImpl factory,
  List<Arma> armas,
  List<Armadura> armaduras,
  List<Habilidade> habilidades,
) async {
  final random = Random();
  final nomes = ['Goblin', 'Orc', 'Esqueleto', 'Lobo', 'Bandido', 'Cultista'];
  
  for (int i = 0; i < 10; i++) {
     final arma = armas[random.nextInt(armas.length)];
     final armadura = armaduras[random.nextInt(armaduras.length)];
     final habilidade = habilidades[random.nextInt(habilidades.length)];

     final params = InimigoParams(
      nome: '${nomes[random.nextInt(nomes.length)]} ${i+1}',
      nivel: random.nextInt(4) + 1,
      tipo: 'Monstro',
      armaId: arma.id,
      armaduraId: armadura.id,
      habilidadesIds: [habilidade.id],
      atributos: AtributosBase(forca: 8 + random.nextInt(7), destreza: 8 + random.nextInt(7), constituicao: 8 + random.nextInt(7), inteligencia: 4 + random.nextInt(5), sabedoria: 6 + random.nextInt(5), carisma: 4 + random.nextInt(5)),
    );
    final inimigo = await factory.criarInimigo(params);
    await repo.save(inimigo);
  }
}