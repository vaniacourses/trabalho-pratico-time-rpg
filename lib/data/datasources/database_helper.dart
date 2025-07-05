import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rpg_database.db');
    
    return await openDatabase(
      path,
      version: 5, // <-- VERSÃO ATUALIZADA PARA 5
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // onCreate cria o esquema completo para novas instalações (já na v5)
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createV1Tables(batch);
    _addV2SchemaChanges(batch);
    _addV3SchemaChanges(batch);
    _addV4SchemaChanges(batch);
    _addV5SchemaChanges(batch); // Adiciona as mudanças da v5
    await batch.commit(noResult: true);
  }

  // onUpgrade aplica as mudanças de forma incremental.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final batch = db.batch();
    
    if (oldVersion < 2) {
      _addV2SchemaChanges(batch);
    }
    if (oldVersion < 3) {
      _addV3SchemaChanges(batch);
    }
    if (oldVersion < 4) {
      // Na migração real, renomearíamos e migraríamos os dados.
      // Para o nosso teste, apenas criamos as novas e deletamos as antigas.
      _addV4SchemaChanges(batch);
      batch.execute('DROP TABLE IF EXISTS personagem_habilidades');
      batch.execute('DROP TABLE IF EXISTS personagem_equipamentos');
    }
    if (oldVersion < 5) {
      // Aplica as mudanças da v5
      _addV5SchemaChanges(batch);
    }

    await batch.commit(noResult: true);
  }

  // --- MÉTODOS AUXILIARES PARA ORGANIZAÇÃO ---

  void _createV1Tables(Batch batch) {
    batch.execute(
      '''CREATE TABLE racas (id TEXT PRIMARY KEY, nome TEXT NOT NULL, modificadoresDeAtributo TEXT NOT NULL)''',
    );
    batch.execute(
      '''CREATE TABLE classes_personagem (id TEXT PRIMARY KEY, nome TEXT NOT NULL, proficienciaArmadura INTEGER NOT NULL, proficienciaArma INTEGER NOT NULL)''',
    );
    batch.execute(
      '''CREATE TABLE armas (id TEXT PRIMARY KEY, nome TEXT NOT NULL, danoBase INTEGER NOT NULL)''',
    );
    batch.execute(
      '''CREATE TABLE personagens (id TEXT PRIMARY KEY, nome TEXT NOT NULL, nivel INTEGER NOT NULL, vidaMax INTEGER NOT NULL, classeArmadura INTEGER NOT NULL, forca INTEGER NOT NULL, destreza INTEGER NOT NULL, constituicao INTEGER NOT NULL, inteligencia INTEGER NOT NULL, sabedoria INTEGER NOT NULL, carisma INTEGER NOT NULL, racaId TEXT NOT NULL REFERENCES racas(id), classeId TEXT NOT NULL REFERENCES classes_personagem(id))''',
    );
  }
  
  void _addV2SchemaChanges(Batch batch) {
    batch.execute(
      'ALTER TABLE personagens ADD COLUMN armaId TEXT NULL REFERENCES armas(id)',
    );
    batch.execute(
      'ALTER TABLE personagens ADD COLUMN armaduraId TEXT NULL REFERENCES armas(id)',
    );
    batch.execute('''
      CREATE TABLE habilidades (
        id TEXT PRIMARY KEY, nome TEXT NOT NULL, descricao TEXT NOT NULL,
        custo INTEGER NOT NULL, nivelExigido INTEGER NOT NULL
      )
    ''');
    // Tabelas de junção com nomes antigos, que serão refatoradas/removidas na v4
    batch.execute(
      '''CREATE TABLE IF NOT EXISTS personagem_habilidades (personagemId TEXT NOT NULL, habilidadeId TEXT NOT NULL, tipo TEXT NOT NULL, PRIMARY KEY (personagemId, habilidadeId, tipo))''',
    );
    batch.execute(
      '''CREATE TABLE IF NOT EXISTS personagem_equipamentos (personagemId TEXT NOT NULL, armaId TEXT NOT NULL, slot TEXT NOT NULL, PRIMARY KEY (personagemId, slot))''',
    );
  }

  void _addV3SchemaChanges(Batch batch) {
    batch.execute(
      '''CREATE TABLE inimigos (id TEXT PRIMARY KEY, nome TEXT NOT NULL, nivel INTEGER NOT NULL, vidaMax INTEGER NOT NULL, classeArmadura INTEGER NOT NULL, tipo TEXT NOT NULL, forca INTEGER NOT NULL, destreza INTEGER NOT NULL, constituicao INTEGER NOT NULL, inteligencia INTEGER NOT NULL, sabedoria INTEGER NOT NULL, carisma INTEGER NOT NULL, armaId TEXT NULL REFERENCES armas(id), armaduraId TEXT NULL REFERENCES armas(id))''',
    );
  }
  
  void _addV4SchemaChanges(Batch batch) {
    batch.execute(
      '''CREATE TABLE grupos (id TEXT PRIMARY KEY, nome TEXT NOT NULL, tipo TEXT NOT NULL)''',
    );
    batch.execute(
      '''CREATE TABLE grupo_membros (grupoId TEXT NOT NULL, combatenteId TEXT NOT NULL, PRIMARY KEY (grupoId, combatenteId), FOREIGN KEY (grupoId) REFERENCES grupos(id) ON DELETE CASCADE)''',
    );
    batch.execute(
      '''CREATE TABLE combatente_habilidades (combatenteId TEXT NOT NULL, habilidadeId TEXT NOT NULL, tipo TEXT NOT NULL, PRIMARY KEY (combatenteId, habilidadeId, tipo))''',
    );
    batch.execute(
      '''CREATE TABLE combatente_equipamentos (combatenteId TEXT NOT NULL, armaId TEXT NOT NULL, slot TEXT NOT NULL, PRIMARY KEY (combatenteId, slot))''',
    );
  }

  void _addV5SchemaChanges(Batch batch) {
    // Adiciona as colunas para suportar o padrão Strategy na tabela de habilidades
    batch.execute('ALTER TABLE habilidades ADD COLUMN categoria TEXT');
    batch.execute('ALTER TABLE habilidades ADD COLUMN danoBase INTEGER');
    batch.execute('ALTER TABLE habilidades ADD COLUMN curaBase INTEGER');
  }
}