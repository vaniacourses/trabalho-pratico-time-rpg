import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/repositories/classe_personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/raca_repository_impl.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:uuid/uuid.dart';

// A função main agora é assíncrona para podermos usar 'await'.
void main() async {
  // Necessário para garantir que o Flutter esteja inicializado antes de qualquer operação.
  WidgetsFlutterBinding.ensureInitialized();
  // 1) Inicializa o FFI (desktop):
  sqfliteFfiInit();
  // 2) Sobrescreve o factory global para usar a versão FFI:
  databaseFactory = databaseFactoryFfi;
  
  print('--- INICIANDO TESTE DE CRUD COMPLETO ---');
  
  // --- 1. INICIALIZAÇÃO (Injeção de Dependência Manual) ---
  final dbHelper = DatabaseHelper.instance;
  final racaRepo = RacaRepositoryImpl(dbHelper: dbHelper);
  final classeRepo = ClassePersonagemRepositoryImpl(dbHelper: dbHelper);
  final personagemRepo = PersonagemRepositoryImpl(dbHelper: dbHelper);
  const uuid = Uuid();

  // --- 2. DADOS DE PRÉ-REQUISITO ---
  print('\n[PASSO 1/5] Criando dados de pré-requisito (Raça e Classe)...');

  final racaHumano = Raca(
    id: uuid.v4(),
    nome: 'Humano',
    modificadoresDeAtributo: {'carisma': 1, 'inteligencia': 1},
  );

  final classeGuerreiro = ClassePersonagem(
    id: uuid.v4(),
    nome: 'Guerreiro',
    proficienciaArmadura: 5,
    proficienciaArma: 3,
    habilidadesDisponiveis: [], // <--- CORREÇÃO AQUI
  );

  await racaRepo.save(racaHumano);
  await classeRepo.save(classeGuerreiro);
  print('Raça "Humano" e Classe "Guerreiro" salvas no banco.');

  // --- 3. CREATE (CRIAR PERSONAGEM) ---
  print('\n[PASSO 2/5] Criando e salvando um novo personagem...');

  final personagemAragorn = Personagem(
    id: uuid.v4(),
    nome: 'Aragorn',
    nivel: 5,
    vidaMax: 50,
    classeArmadura: 16,
    raca: racaHumano, // Usando a raça que acabamos de criar
    classe: classeGuerreiro, // Usando a classe que acabamos de criar
    atributosBase: AtributosBase(
      forca: 18,
      destreza: 14,
      constituicao: 16,
      inteligencia: 12,
      sabedoria: 14,
      carisma: 16,
    ),
    habilidadesConhecidas: [],
    habilidadesPreparadas: [],
    equipamentos: {},
  );

  await personagemRepo.save(personagemAragorn);
  print('Personagem "${personagemAragorn.nome}" salvo com sucesso!');

  // --- 4. READ (LER PERSONAGENS) ---
  print('\n[PASSO 3/5] Lendo todos os personagens do banco...');

  var todosPersonagens = await personagemRepo.getAll();
  if (todosPersonagens.isNotEmpty) {
    print('Personagens encontrados: ${todosPersonagens.length}');
    for (var p in todosPersonagens) {
      print(
        '- ID: ${p.id}, Nome: ${p.nome}, Nível: ${p.nivel}, Raça: ${p.raca.nome}',
      );
    }
  } else {
    print('ERRO: Nenhum personagem encontrado após salvar!');
  }

  // --- 5. UPDATE (ATUALIZAR PERSONAGEM) ---
  print('\n[PASSO 4/5] Atualizando o personagem (Nível 5 -> 6)...');
  
  personagemAragorn.nivel = 6; // Modificando o nível
  personagemAragorn.nome = 'Aragorn, o Rei'; // Modificando o nome
  
  await personagemRepo.save(
    personagemAragorn,
  ); // O 'save' com o mesmo ID irá atualizar
  print('Personagem atualizado.');

  final personagemAtualizado = await personagemRepo.getById(
    personagemAragorn.id,
  );
  if (personagemAtualizado != null) {
    print('Verificação da atualização:');
    print(
      '- Nome: ${personagemAtualizado.nome}, Nível: ${personagemAtualizado.nivel}',
    );
  } else {
    print('ERRO: Não foi possível encontrar o personagem após a atualização!');
  }

  // --- 6. DELETE (DELETAR PERSONAGEM) ---
  print('\n[PASSO 5/5] Deletando o personagem...');

  await personagemRepo.delete(personagemAragorn.id);
  print('Personagem deletado.');

  todosPersonagens = await personagemRepo.getAll();
  if (todosPersonagens.isEmpty) {
    print('Verificação da deleção: Nenhum personagem no banco. SUCESSO!');
  } else {
    print('ERRO: Personagens ainda existem no banco após a deleção!');
  }
  
  print('\n--- TESTE DE CRUD FINALIZADO ---');

  // runApp(const MyApp()); // A UI não é necessária para este teste
}
