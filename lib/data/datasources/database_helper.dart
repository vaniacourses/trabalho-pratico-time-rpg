// CORREÇÃO: O import correto usa ':' e não '.'
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Instância privada do Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Instância única do banco de dados
  static Database? _database;

  // Getter para o banco de dados. Se não existir, inicializa.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Método de inicialização do banco de dados
  Future<Database> _initDatabase() async {
    // Pega o caminho do diretório onde o banco de dados será salvo
    String path = join(await getDatabasesPath(), 'rpg_database.db');
    
    // Abre o banco de dados. Se não existir, o onCreate será chamado.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Método chamado na criação do banco de dados para criar as tabelas iniciais
  Future<void> _onCreate(Database db, int version) async {
    // Usamos Batch para executar múltiplos comandos SQL de uma vez
    final batch = db.batch();

    // Tabela para Raças
    batch.execute('''
      CREATE TABLE racas (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        modificadoresDeAtributo TEXT NOT NULL -- Armazenado como uma string JSON
      )
    ''');
    
    // Tabela para Classes de Personagem
    batch.execute('''
      CREATE TABLE classes_personagem (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        proficienciaArmadura INTEGER NOT NULL,
        proficienciaArma INTEGER NOT NULL
      )
    ''');

    // Tabela para Armas
    batch.execute('''
      CREATE TABLE armas (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        danoBase INTEGER NOT NULL
      )
    ''');

    // Tabela principal de Personagens
    batch.execute('''
      CREATE TABLE personagens (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        nivel INTEGER NOT NULL,
        vidaMax INTEGER NOT NULL,
        classeArmadura INTEGER NOT NULL,
        
        -- Chaves estrangeiras que se relacionam com outras tabelas
        racaId TEXT NOT NULL,
        classeId TEXT NOT NULL,
        
        -- Atributos base (desnormalizados para performance)
        forca INTEGER NOT NULL,
        destreza INTEGER NOT NULL,
        constituicao INTEGER NOT NULL,
        inteligencia INTEGER NOT NULL,
        sabedoria INTEGER NOT NULL,
        carisma INTEGER NOT NULL,
        
        FOREIGN KEY (racaId) REFERENCES racas (id),
        FOREIGN KEY (classeId) REFERENCES classes_personagem (id)
      )
    ''');
    
    // Commita (executa) todas as operações do batch
    await batch.commit(noResult: true);
  }
}