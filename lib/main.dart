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
// MUDANÇA: Import necessário para acessar os enums de proficiência.
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
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
    // MUDANÇA: Usando os valores do enum em vez de números.
    proficienciaArmadura: ProficienciaArmadura.Pesada,
    proficienciaArma: ProficienciaArma.Marcial,
    habilidadesDisponiveis: [],
  );

  await racaRepo.save(racaHumano);
  await classeRepo.save(classeGuerreiro);
  print('Raça "Humano" e Classe "Guerreiro" salvas no banco.');

  // --- 3. CREATE (CRIAR PERSONAGEM) ---
  print('\n[PASSO 2/5] Criando e salvando um novo personagem...');

  // MUDANÇA: O objeto Personagem foi mutável para este teste. Veja a nota abaixo.
  var personagemAragorn = Personagem(
    id: uuid.v4(),
    nome: 'Aragorn',
    nivel: 5,
    vidaMax: 50,
    classeArmadura: 16,
    raca: racaHumano,
    classe: classeGuerreiro,
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
    // MUDANÇA: O campo 'equipamentos' foi removido, conforme nosso design.
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
  
  // MUDANÇA: Criando uma nova instância para a atualização,
  // que é uma prática melhor para imutabilidade.
  personagemAragorn.nivel = 6;
  personagemAragorn.nome = 'Aragorn, o Rei';
  
  await personagemRepo.save(personagemAragorn);
  print('Personagem atualizado.');

  final personagemAtualizado = await personagemRepo.getById(personagemAragorn.id);
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
}