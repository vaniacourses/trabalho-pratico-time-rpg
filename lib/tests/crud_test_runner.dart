import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/factories/inimigo_factory_impl.dart';
import 'package:trabalho_rpg/data/factories/personagem_factory_impl.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_dano_model.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_cura_model.dart';
import 'package:trabalho_rpg/data/repositories/arma_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/armadura_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/classe_personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/grupo_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/habilidade_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/inimigo_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/raca_repository_impl.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:uuid/uuid.dart';

class CrudTestRunner {
  final DatabaseHelper dbHelper;
  final RacaRepositoryImpl racaRepo;
  final ClassePersonagemRepositoryImpl classeRepo;
  final ArmaRepositoryImpl armaRepo;
  final ArmaduraRepositoryImpl armaduraRepo;
  final HabilidadeRepositoryImpl habilidadeRepo;
  final PersonagemRepositoryImpl personagemRepo;
  final InimigoRepositoryImpl inimigoRepo;
  final Uuid uuid;

  CrudTestRunner(this.dbHelper)
      : racaRepo = RacaRepositoryImpl(dbHelper: dbHelper),
        classeRepo = ClassePersonagemRepositoryImpl(dbHelper: dbHelper),
        armaRepo = ArmaRepositoryImpl(dbHelper: dbHelper),
        armaduraRepo = ArmaduraRepositoryImpl(dbHelper: dbHelper),
        habilidadeRepo = HabilidadeRepositoryImpl(dbHelper: dbHelper),
        // CORREÇÃO: Injetando a dependência do repositório de habilidades.
        personagemRepo = PersonagemRepositoryImpl(
          dbHelper: dbHelper,
          habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: dbHelper),
          racaRepository: RacaRepositoryImpl(dbHelper: dbHelper),
          classeRepository: ClassePersonagemRepositoryImpl(dbHelper: dbHelper),
          armaRepository: ArmaRepositoryImpl(dbHelper: dbHelper),
          armaduraRepository: ArmaduraRepositoryImpl(dbHelper: dbHelper),
          
        ),
        inimigoRepo = InimigoRepositoryImpl(
          dbHelper: dbHelper,
          habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: dbHelper),
          armaRepository: ArmaRepositoryImpl(dbHelper: dbHelper),
        ),
        uuid = const Uuid();

  Future<void> testarCrudDePersonagem() async {
    print('--- INICIANDO TESTE DE CRUD DE PERSONAGEM ---');

    print('\n[PASSO 1/5] Criando dados de pré-requisito...');
    final racaHumano = Raca(id: uuid.v4(), nome: 'Humano', modificadoresDeAtributo: {'carisma': 1, 'inteligencia': 1});
    final classeGuerreiro = ClassePersonagem(id: uuid.v4(), nome: 'Guerreiro', proficienciaArmadura: ProficienciaArmadura.Pesada, proficienciaArma: ProficienciaArma.Marcial, habilidadesDisponiveis: []);
    final espadaLonga = Arma(id: uuid.v4(), nome: 'Espada Longa', danoBase: 8);
    final escudoDeAco = Armadura(id: uuid.v4(), nome: 'Escudo de Aço', danoReduzido: 2, proficienciaRequerida: ProficienciaArmadura.Pesada);
    final adaga = Arma(id: uuid.v4(), nome: 'Adaga', danoBase: 4);

    // CORREÇÃO: Instanciando as classes concretas de habilidade.
    final bolaDeFogo = HabilidadeDeDanoModel(id: uuid.v4(), nome: 'Bola de Fogo', descricao: 'Lança uma bola de fogo', custo: 10, nivelExigido: 3, danoBase: 15);
    final curaLeve = HabilidadeDeCuraModel(id: uuid.v4(), nome: 'Cura Leve', descricao: 'Cura ferimentos leves', custo: 5, nivelExigido: 1, curaBase: 8);
    
    await Future.wait([
      racaRepo.save(racaHumano),
      classeRepo.save(classeGuerreiro),
      armaRepo.save(espadaLonga),
      armaduraRepo.saveArmadura(escudoDeAco),
      armaRepo.save(adaga),
      habilidadeRepo.save(bolaDeFogo),
      habilidadeRepo.save(curaLeve),
    ]);
    print('Pré-requisitos salvos no banco.');

    print('\n[PASSO 2/5] Criando e salvando um novo personagem...');
    final personagemAragorn = Personagem(
      id: uuid.v4(), nome: 'Aragorn', nivel: 5, vidaMax: 50, classeArmadura: 16,
      raca: racaHumano, classe: classeGuerreiro,
      atributosBase: AtributosBase(forca: 18, destreza: 14, constituicao: 16, inteligencia: 12, sabedoria: 14, carisma: 16),
      arma: espadaLonga, armadura: escudoDeAco,
      habilidadesConhecidas: [bolaDeFogo, curaLeve], habilidadesPreparadas: [bolaDeFogo],
      equipamentos: {'bota_reserva': adaga},
    );
    await personagemRepo.save(personagemAragorn);
    print('Personagem "${personagemAragorn.nome}" salvo com sucesso!');

    print('\n[PASSO 3/5] Lendo e verificando o personagem...');
    final pSalvo = await personagemRepo.getById(personagemAragorn.id);
    assert(pSalvo != null, 'ERRO: Personagem não encontrado após salvar!');

    assert(pSalvo!.arma!.nome == 'Espada Longa', 'ERRO: Arma incorreta!');
    assert(pSalvo!.habilidadesConhecidas.length == 2, 'ERRO: Habilidades conhecidas incorretas!');
    assert(pSalvo!.habilidadesPreparadas.length == 1, 'ERRO: Habilidades preparadas incorretas!');
    assert(pSalvo!.equipamentos['bota_reserva']?.nome == 'Adaga', 'ERRO: Equipamento incorreto!');
    print('Verificação de leitura bem-sucedida!');

    print('\n[PASSO 4/5] Atualizando o personagem...');
    final machadoDeBatalha = Arma(id: uuid.v4(), nome: 'Machado de Batalha', danoBase: 10);
    await armaRepo.save(machadoDeBatalha);
    
    pSalvo!.arma = machadoDeBatalha;
    pSalvo.habilidadesPreparadas = [curaLeve];
    pSalvo.equipamentos.remove('bota_reserva');
    await personagemRepo.save(pSalvo);
    
    final pAtualizado = await personagemRepo.getById(pSalvo.id);
    assert(pAtualizado != null, 'ERRO: Personagem não encontrado após atualizar!');

    assert(pAtualizado!.arma?.nome == 'Machado de Batalha', 'ERRO: Arma não atualizou!');
    assert(pAtualizado!.habilidadesPreparadas.first.nome == 'Cura Leve', 'ERRO: Habilidades não atualizaram!');
    assert(pAtualizado!.equipamentos.isEmpty, 'ERRO: Equipamento não foi removido!');
    print('Verificação de atualização bem-sucedida!');

    print('\n[PASSO 5/5] Deletando o personagem...');
    await personagemRepo.delete(personagemAragorn.id);
    final pDeletado = await personagemRepo.getById(personagemAragorn.id);
    assert(pDeletado == null, 'ERRO: Personagem não foi deletado!');
    print('Verificação de deleção bem-sucedida!');

    print('\n--- TESTE DE CRUD DE PERSONAGEM FINALIZADO COM SUCESSO ---');
  }

  Future<void> testarCrudDeInimigo() async {
    print('--- INICIANDO TESTE DE CRUD DE INIMIGO ---');

    print('\n[PASSO 1/5] Criando dados de pré-requisito...');
    final maosMisticas = Arma(id: uuid.v4(), nome: 'Mãos Místicas', danoBase: 12);
    final peleDePedra = Armadura(id: uuid.v4(), nome: 'Pele de Pedra', danoReduzido: 5, proficienciaRequerida: ProficienciaArmadura.Pesada);
    // CORREÇÃO: Instanciando classe concreta
    final baforadaDeFogo = HabilidadeDeDanoModel(id: uuid.v4(), nome: 'Baforada de Fogo', descricao: 'Cospe fogo nos inimigos', custo: 15, nivelExigido: 10, danoBase: 20);
    await armaRepo.save(maosMisticas);
    await armaduraRepo.saveArmadura(peleDePedra);
    await habilidadeRepo.save(baforadaDeFogo);
    print('Pré-requisitos salvos no banco.');

    print('\n[PASSO 2/5] Criando e salvando um novo inimigo...');
    final golemDePedra = Inimigo(
      id: uuid.v4(), nome: 'Golem de Pedra', nivel: 10, vidaMax: 100, classeArmadura: 20,
      tipo: 'Constructo',
      atributosBase: AtributosBase(forca: 22, destreza: 9, constituicao: 20, inteligencia: 3, sabedoria: 11, carisma: 1),
      habilidadesPreparadas: [baforadaDeFogo],
      arma: maosMisticas,
      armadura: peleDePedra
    );
    await inimigoRepo.save(golemDePedra);
    print('Inimigo "${golemDePedra.nome}" salvo com sucesso!');

    print('\n[PASSO 3/5] Lendo e verificando o inimigo...');
    final iSalvo = await inimigoRepo.getById(golemDePedra.id);
    assert(iSalvo != null, 'ERRO: Inimigo não encontrado após salvar!');
    
    assert(iSalvo!.tipo == 'Constructo', 'ERRO: Tipo incorreto!');
    assert(iSalvo!.arma!.nome == 'Mãos Místicas', 'ERRO: Arma incorreta!');
    assert(iSalvo!.habilidadesPreparadas.length == 1, 'ERRO: Habilidades incorretas!');
    print('Verificação de leitura bem-sucedida!');

    print('\n[PASSO 4/5] Atualizando o inimigo...');
    iSalvo!.nivel = 11;
    iSalvo.nome = 'Golem de Pedra Enfurecido';
    await inimigoRepo.save(iSalvo);
    
    final iAtualizado = await inimigoRepo.getById(iSalvo.id);
    assert(iAtualizado != null, 'ERRO: Inimigo não encontrado após atualizar!');
    
    assert(iAtualizado!.nome == 'Golem de Pedra Enfurecido', 'ERRO: Nome não atualizou!');
    assert(iAtualizado!.nivel == 11, 'ERRO: Nível não atualizou!');
    print('Verificação de atualização bem-sucedida!');

    print('\n[PASSO 5/5] Deletando o inimigo...');
    await inimigoRepo.delete(golemDePedra.id);
    final iDeletado = await inimigoRepo.getById(golemDePedra.id);
    assert(iDeletado == null, 'ERRO: Inimigo não foi deletado!');
    print('Verificação de deleção bem-sucedida!');

    print('\n--- TESTE DE CRUD DE INIMIGO FINALIZADO COM SUCESSO ---');
  }

  Future<void> testarCrudDeGrupo() async {
    print('--- INICIANDO TESTE DE CRUD DE GRUPO ---');

    print('\n[PARTE 1/2] Testando Grupo<Personagem>...');
    
    print('\n[PASSO 1/4] Criando personagens para o grupo...');
    final racaAnao = Raca(id: uuid.v4(), nome: 'Anão', modificadoresDeAtributo: {'constituicao': 2});
    final classeClerigo = ClassePersonagem(id: uuid.v4(), nome: 'Clérigo', proficienciaArmadura: ProficienciaArmadura.Pesada, proficienciaArma: ProficienciaArma.Simples, habilidadesDisponiveis: []);
    await racaRepo.save(racaAnao);
    await classeRepo.save(classeClerigo);

    final p1 = Personagem(
      id: uuid.v4(), nome: 'Gimli', nivel: 7, vidaMax: 75, classeArmadura: 18,
      raca: racaAnao, classe: classeClerigo,
      atributosBase: AtributosBase(forca: 16, destreza: 12, constituicao: 18, inteligencia: 10, sabedoria: 16, carisma: 11),
      habilidadesConhecidas: [], habilidadesPreparadas: [], equipamentos: {},
    );
    final p2 = Personagem(
      id: uuid.v4(), nome: 'Balin', nivel: 8, vidaMax: 80, classeArmadura: 17,
      raca: racaAnao, classe: classeClerigo,
      atributosBase: AtributosBase(forca: 15, destreza: 14, constituicao: 17, inteligencia: 12, sabedoria: 18, carisma: 13),
      habilidadesConhecidas: [], habilidadesPreparadas: [], equipamentos: {},
    );
    await personagemRepo.save(p1);
    await personagemRepo.save(p2);

    print('\n[PASSO 2/4] Criando e salvando o grupo de personagens...');
    final grupoDePersonagens = Grupo<Personagem>(
      id: uuid.v4(),
      nome: 'Comitiva dos Anões',
      membros: [p1, p2],
    );

    final grupoPersonagemRepo = GrupoRepositoryImpl<Personagem>(
      dbHelper: dbHelper,
      personagemRepository: personagemRepo,
      inimigoRepository: inimigoRepo,
    );
    await grupoPersonagemRepo.save(grupoDePersonagens);
    print('Grupo "${grupoDePersonagens.nome}" salvo.');

    print('\n[PASSO 3/4] Lendo e verificando o grupo de personagens...');
    final grupoSalvo = await grupoPersonagemRepo.getById(grupoDePersonagens.id);
    assert(grupoSalvo != null, 'ERRO: Grupo de Personagens não encontrado!');
    assert(grupoSalvo!.nome == 'Comitiva dos Anões', 'ERRO: Nome do grupo incorreto!');
    assert(grupoSalvo!.membros.length == 2, 'ERRO: Número de membros incorreto!');
    assert(grupoSalvo!.membros.any((m) => m.nome == 'Gimli'), 'ERRO: Membro Gimli não encontrado!');
    print('Verificação de leitura bem-sucedida!');
    
    print('\n[PASSO 4/4] Deletando o grupo de personagens...');
    await grupoPersonagemRepo.delete(grupoDePersonagens.id);
    final grupoDeletado = await grupoPersonagemRepo.getById(grupoDePersonagens.id);
    assert(grupoDeletado == null, 'ERRO: Grupo de personagens não foi deletado!');
    print('Verificação de deleção bem-sucedida!');

    print('\n[PARTE 2/2] Testando Grupo<Inimigo>...');

    print('\n[PASSO 1/4] Criando inimigos para o grupo...');
    final i1 = Inimigo(
      id: uuid.v4(), nome: 'Orc Batedor', nivel: 2, vidaMax: 15, classeArmadura: 13,
      tipo: 'Humanoide',
      atributosBase: AtributosBase(forca: 12, destreza: 16, constituicao: 12, inteligencia: 8, sabedoria: 9, carisma: 7),
      habilidadesPreparadas: [],
    );
    final i2 = Inimigo(
      id: uuid.v4(), nome: 'Orc Chefe', nivel: 4, vidaMax: 45, classeArmadura: 16,
      tipo: 'Humanoide',
      atributosBase: AtributosBase(forca: 18, destreza: 12, constituicao: 16, inteligencia: 10, sabedoria: 11, carisma: 12),
      habilidadesPreparadas: [],
    );
    await inimigoRepo.save(i1);
    await inimigoRepo.save(i2);
    
    print('\n[PASSO 2/4] Criando e salvando o grupo de inimigos...');
    final grupoDeInimigos = Grupo<Inimigo>(
      id: uuid.v4(),
      nome: 'Horda Orc',
      membros: [i1, i2],
    );

    final grupoInimigoRepo = GrupoRepositoryImpl<Inimigo>(
      dbHelper: dbHelper,
      personagemRepository: personagemRepo,
      inimigoRepository: inimigoRepo,
    );
    await grupoInimigoRepo.save(grupoDeInimigos);
    print('Grupo "${grupoDeInimigos.nome}" salvo.');

    print('\n[PASSO 3/4] Lendo e verificando o grupo de inimigos...');
    final grupoInimigoSalvo = await grupoInimigoRepo.getById(grupoDeInimigos.id);
    assert(grupoInimigoSalvo != null, 'ERRO: Grupo de Inimigos não encontrado!');
    assert(grupoInimigoSalvo!.nome == 'Horda Orc', 'ERRO: Nome do grupo incorreto!');
    assert(grupoInimigoSalvo!.membros.length == 2, 'ERRO: Número de membros incorreto!');
    assert(grupoInimigoSalvo!.membros.any((m) => m.nome == 'Orc Chefe'), 'ERRO: Membro Orc Chefe não encontrado!');
    print('Verificação de leitura bem-sucedida!');

    print('\n[PASSO 4/4] Deletando o grupo de inimigos...');
    await grupoInimigoRepo.delete(grupoDeInimigos.id);
    final grupoInimigoDeletado = await grupoInimigoRepo.getById(grupoDeInimigos.id);
    assert(grupoInimigoDeletado == null, 'ERRO: Grupo de inimigos não foi deletado!');
    print('Verificação de deleção bem-sucedida!');

    print('\n--- TESTE DE CRUD DE GRUPO FINALIZADO COM SUCESSO ---');
  }

  Future<void> testarFactoryDePersonagem() async {
    print('--- INICIANDO TESTE DO FACTORY METHOD ---');
    
    print('\n[PASSO 1/3] Criando dados de pré-requisito (Raça e Classe)...');
    final racaElfo = Raca(id: uuid.v4(), nome: 'Elfo', modificadoresDeAtributo: {'destreza': 2});
    final classeMago = ClassePersonagem(id: uuid.v4(), nome: 'Mago', proficienciaArmadura: ProficienciaArmadura.Nenhuma, proficienciaArma: ProficienciaArma.Simples, habilidadesDisponiveis: []);
    await racaRepo.save(racaElfo);
    await classeRepo.save(classeMago);
    print('Pré-requisitos salvos.');

    print('\n[PASSO 2/3] Usando a Factory para criar uma instância de Personagem...');
    
    final factory = PersonagemFactoryImpl(
      racaRepository: racaRepo,
      classeRepository: classeRepo,
      uuid: uuid,
      armaRepository: armaRepo,
      armaduraRepository: armaduraRepo,
      habilidadeRepository: habilidadeRepo,
    );

    final params = PersonagemParams(
      nome: 'Elara',
      nivel: 1,
      racaId: racaElfo.id,
      classeId: classeMago.id,
      atributos: AtributosBase(
        forca: 8,
        destreza: 16,
        constituicao: 12,
        inteligencia: 18,
        sabedoria: 14,
        carisma: 10,
      ),
      habilidadesConhecidasIds: [],
      habilidadesPreparadasIds: [],
    );
    
    final novoPersonagem = await factory.criarPersonagem(params);

    assert(novoPersonagem.nome == 'Elara', 'ERRO: Nome incorreto!');
    print('Personagem "${novoPersonagem.nome}" criado com sucesso pela factory!');

    print('\n[PASSO 3/3] Salvando o personagem criado no banco de dados...');
    await personagemRepo.save(novoPersonagem);
    
    final personagemSalvo = await personagemRepo.getById(novoPersonagem.id);
    assert(personagemSalvo != null, 'ERRO: Personagem criado pela factory não foi salvo corretamente!');
    print('Verificação de persistência bem-sucedida!');
    
    print('\n--- TESTE DE FACTORY METHOD FINALIZADO COM SUCESSO ---');
  }

  Future<void> testarFactoryDeInimigo() async {
    print('--- INICIANDO TESTE DO FACTORY DE INIMIGO ---');

    print('\n[PASSO 1/3] Criando dados de pré-requisito...');
    final garras = Arma(id: uuid.v4(), nome: 'Garras Afiadas', danoBase: 6);
    final mordida = HabilidadeDeDanoModel(id: uuid.v4(), nome: 'Mordida', descricao: 'Ataque de mordida', custo: 0, nivelExigido: 1, danoBase: 4);
    await armaRepo.save(garras);
    await habilidadeRepo.save(mordida);
    print('Pré-requisitos salvos.');

    print('\n[PASSO 2/3] Usando a Factory para criar uma instância de Inimigo...');
    
    // CORREÇÃO: Passando os repositórios necessários para a factory.
    final factory = InimigoFactoryImpl(
      armaRepository: armaRepo,
      habilidadeRepository: habilidadeRepo,
      armaduraRepository: armaduraRepo,
      uuid: uuid,
    );

    final params = InimigoParams(
      nome: 'Lobo',
      nivel: 2,
      tipo: 'Besta',
      armaId: garras.id,
      habilidadesIds: [mordida.id],
      atributos: AtributosBase(forca: 14, destreza: 16, constituicao: 13, inteligencia: 3, sabedoria: 12, carisma: 6)
    );
    
    final novoInimigo = await factory.criarInimigo(params);

    assert(novoInimigo.nome == 'Lobo', 'ERRO: Nome incorreto!');
    print('Inimigo "${novoInimigo.nome}" criado com sucesso pela factory!');

    print('\n[PASSO 3/3] Salvando o inimigo criado no banco de dados...');
    await inimigoRepo.save(novoInimigo);
    
    final inimigoSalvo = await inimigoRepo.getById(novoInimigo.id);
    assert(
      inimigoSalvo != null,
      'ERRO: Inimigo criado pela factory não foi salvo corretamente!',
    );
    print('Verificação de persistência bem-sucedida!');
    
    print('\n--- TESTE DE FACTORY DE INIMIGO FINALIZADO COM SUCESSO ---');
  }
  /// Função que testa a implementação do padrão Strategy.
  Future<void> testarStrategyHabilidade() async {
    print('--- INICIANDO TESTE DO PADRÃO STRATEGY ---');

    print('\n[PASSO 1/4] Criando autor e alvo para o teste...');
    final racaGuerreiro = Raca(id: uuid.v4(), nome: 'Meio-Orc', modificadoresDeAtributo: {'forca': 2, 'constituicao': 1});
    final classeBarbaro = ClassePersonagem(id: uuid.v4(), nome: 'Bárbaro', proficienciaArmadura: ProficienciaArmadura.Media, proficienciaArma: ProficienciaArma.Marcial, habilidadesDisponiveis: []);
    await racaRepo.save(racaGuerreiro);
    await classeRepo.save(classeBarbaro);

    final autor = Personagem(
      id: uuid.v4(), nome: 'Grog', nivel: 5, vidaMax: 60, classeArmadura: 14,
      raca: racaGuerreiro, classe: classeBarbaro,
      atributosBase: AtributosBase(forca: 18, destreza: 14, constituicao: 16, inteligencia: 8, sabedoria: 12, carisma: 10),
      habilidadesConhecidas: [], habilidadesPreparadas: [], equipamentos: {},
    );

    final alvo = Inimigo(
      id: uuid.v4(), nome: 'Urso-Coruja', nivel: 3, vidaMax: 59, classeArmadura: 13,
      tipo: 'Monstruosidade',
      atributosBase: AtributosBase(forca: 20, destreza: 12, constituicao: 17, inteligencia: 3, sabedoria: 12, carisma: 7),
      habilidadesPreparadas: [],
    );

    final vidaInicialAlvo = alvo.vidaAtual;
    print('Vida inicial do alvo "${alvo.nome}": $vidaInicialAlvo');

    print('\n[PASSO 2/4] Criando e salvando as estratégias (habilidades)...');
    final ataquePoderoso = HabilidadeDeDanoModel(
        id: uuid.v4(), nome: 'Ataque Poderoso', descricao: 'Um golpe devastador.',
        custo: 5, nivelExigido: 1, danoBase: 12);
        
    final gritoDeCura = HabilidadeDeCuraModel(
        id: uuid.v4(), nome: 'Grito de Cura', descricao: 'Recupera o fôlego e um pouco de vida.',
        custo: 10, nivelExigido: 2, curaBase: 8);
    
    await habilidadeRepo.save(ataquePoderoso);
    await habilidadeRepo.save(gritoDeCura);
    print('Estratégias salvas.');

    print('\n[PASSO 3/4] Executando estratégia de DANO...');
    final habilidadeDeDano = await habilidadeRepo.getById(ataquePoderoso.id);
    assert(habilidadeDeDano != null, "ERRO: Habilidade de dano não encontrada no banco!");

    habilidadeDeDano!.execute(autor: autor, alvo: alvo);
    print('Vida do alvo após dano: ${alvo.vidaAtual}');
    assert(alvo.vidaAtual < vidaInicialAlvo, 'ERRO: O dano não foi aplicado.');
    final vidaAposDano = alvo.vidaAtual;

    print('\n[PASSO 4/4] Executando estratégia de CURA...');
    final habilidadeDeCura = await habilidadeRepo.getById(gritoDeCura.id);
    assert(habilidadeDeCura != null, "ERRO: Habilidade de cura não encontrada no banco!");

    habilidadeDeCura!.execute(autor: autor, alvo: alvo);
    print('Vida do alvo após cura: ${alvo.vidaAtual}');
    assert(alvo.vidaAtual > vidaAposDano, 'ERRO: A cura não foi aplicada.');

    print('\n--- TESTE DO PADRÃO STRATEGY FINALIZADO COM SUCESSO ---');
  }

  Future<void> testarComposite() async {
    print('--- INICIANDO TESTE DO PADRÃO COMPOSITE ---');

    // 1. Criar pré-requisitos
    print('\n[PASSO 1/3] Criando pré-requisitos para o teste...');
    final racaElfo = Raca(
      id: uuid.v4(),
      nome: 'Elfo da Floresta',
      modificadoresDeAtributo: {'destreza': 2},
    );
    final classeArqueiro = ClassePersonagem(
      id: uuid.v4(),
      nome: 'Arqueiro',
      proficienciaArmadura: ProficienciaArmadura.Leve,
      proficienciaArma: ProficienciaArma.Marcial,
      habilidadesDisponiveis: [],
    );
    // Salva a raça e classe pois o construtor do Personagem precisa delas.
    await racaRepo.save(racaElfo);
    await classeRepo.save(classeArqueiro);

    final autor = Personagem(
      id: uuid.v4(),
      nome: 'Legolas',
      nivel: 10,
      vidaMax: 80,
      classeArmadura: 16,
      raca: racaElfo,
      classe: classeArqueiro,
      atributosBase: AtributosBase(
        forca: 12,
        destreza: 20,
        constituicao: 12,
        inteligencia: 14,
        sabedoria: 16,
        carisma: 10,
      ),
      habilidadesConhecidas: [],
      habilidadesPreparadas: [],
      equipamentos: {},
    );

    final inimigo1 = Inimigo(
      id: uuid.v4(),
      nome: 'Goblin Batedor',
      nivel: 1,
      vidaMax: 10,
      classeArmadura: 12,
      tipo: 'Humanoide',
      atributosBase: AtributosBase(
        forca: 10,
        destreza: 14,
        constituicao: 10,
        inteligencia: 8,
        sabedoria: 8,
        carisma: 8,
      ),
      habilidadesPreparadas: [],
    );

    final inimigo2 = Inimigo(
      id: uuid.v4(),
      nome: 'Goblin Arqueiro',
      nivel: 1,
      vidaMax: 12,
      classeArmadura: 13,
      tipo: 'Humanoide',
      atributosBase: AtributosBase(
        forca: 8,
        destreza: 16,
        constituicao: 10,
        inteligencia: 8,
        sabedoria: 9,
        carisma: 8,
      ),
      habilidadesPreparadas: [],
    );

    final grupoDeInimigos = Grupo<Inimigo>(
      id: uuid.v4(),
      nome: 'Patrulha Goblin',
      membros: [inimigo1, inimigo2],
    );

    final chuvaDeFlechas = HabilidadeDeDanoModel(
      id: uuid.v4(),
      nome: 'Chuva de Flechas',
      descricao: 'Atira uma saraivada de flechas em uma área.',
      custo: 20,
      nivelExigido: 5,
      danoBase: 15,
    );

    print(
      'Vida inicial: ${inimigo1.nome}: ${inimigo1.vidaAtual}, ${inimigo2.nome}: ${inimigo2.vidaAtual}',
    );

    // 2. Executa a mesma habilidade em alvos diferentes
    print('\n[PASSO 2/3] Atacando alvo INDIVIDUAL...');
    chuvaDeFlechas.execute(autor: autor, alvo: inimigo1);
    assert(
      inimigo1.vidaAtual < inimigo1.vidaMax,
      'ERRO: Dano individual não funcionou',
    );
    assert(
      inimigo2.vidaAtual == inimigo2.vidaMax,
      'ERRO: Alvo errado foi atingido',
    );
    print(
      'Estado após ataque individual -> ${inimigo1.nome}: ${inimigo1.vidaAtual}, ${inimigo2.nome}: ${inimigo2.vidaAtual}',
    );

    // Reseta a vida para o próximo teste
    inimigo1.vidaAtual = inimigo1.vidaMax;
    print('\nVida resetada para o próximo teste.');

    print('\n[PASSO 3/3] Atacando alvo em GRUPO...');
    chuvaDeFlechas.execute(autor: autor, alvo: grupoDeInimigos);
    assert(
      inimigo1.vidaAtual < inimigo1.vidaMax,
      'ERRO: Dano em grupo não funcionou para membro 1',
    );
    assert(
      inimigo2.vidaAtual < inimigo2.vidaMax,
      'ERRO: Dano em grupo não funcionou para membro 2',
    );
    print(
      'Estado após ataque em grupo -> ${inimigo1.nome}: ${inimigo1.vidaAtual}, ${inimigo2.nome}: ${inimigo2.vidaAtual}',
    );

    print('\n--- TESTE DO PADRÃO COMPOSITE FINALIZADO COM SUCESSO ---');
  }

  Future<void> testarPrototypeInimigo() async {
    print('--- INICIANDO TESTE DO PADRÃO PROTOTYPE ---');

    // 1. Criar um inimigo original (o protótipo)
    print('\n[PASSO 1/3] Criando o inimigo protótipo...');
    final inimigoOriginal = Inimigo(
      id: uuid.v4(),
      nome: 'Lobo das Cavernas',
      nivel: 3,
      vidaMax: 25,
      classeArmadura: 13,
      tipo: 'Besta',
      atributosBase: AtributosBase(
        forca: 14,
        destreza: 16,
        constituicao: 14,
        inteligencia: 3,
        sabedoria: 12,
        carisma: 6,
      ),
      habilidadesPreparadas: [],
    );
    print(
      'Protótipo criado: "${inimigoOriginal.nome}" (ID: ${inimigoOriginal.id})',
    );

    // 2. Usar o método clone para criar uma réplica
    print('\n[PASSO 2/3] Clonando o protótipo...');
    final inimigoClonado = inimigoOriginal.clone();
    print('Clone criado: "${inimigoClonado.nome}" (ID: ${inimigoClonado.id})');

    // 3. Validar o clone
    print('\n[PASSO 3/3] Validando as propriedades do clone...');
    assert(inimigoClonado != null, 'ERRO: O clone não foi criado.');
    assert(
      inimigoClonado.id != inimigoOriginal.id,
      'ERRO: O clone tem o mesmo ID do original!',
    );
    assert(
      inimigoClonado.nome == inimigoOriginal.nome,
      'ERRO: O nome do clone é diferente.',
    );
    assert(
      inimigoClonado.vidaAtual == inimigoOriginal.vidaAtual,
      'ERRO: A vida atual do clone é diferente.',
    );

    // Testa se a modificação em um não afeta o outro
    inimigoClonado.receberDano(5);
    print('Aplicando 5 de dano ao clone...');
    assert(
      inimigoClonado.vidaAtual < inimigoOriginal.vidaAtual,
      'ERRO: O dano no clone afetou o original!',
    );
    print(
      'Vida Original: ${inimigoOriginal.vidaAtual} | Vida Clone: ${inimigoClonado.vidaAtual}',
    );

    print('Validação bem-sucedida!');
    print('\n--- TESTE DO PADRÃO PROTOTYPE FINALIZADO COM SUCESSO ---');
  }
}