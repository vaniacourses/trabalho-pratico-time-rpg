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
      version: 7, // <--- VERSÃO ATUALIZADA PARA 7
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createV1Tables(batch);
    _addV2SchemaChanges(batch);
    _addV3SchemaChanges(batch);
    _addV4SchemaChanges(batch);
    _addV5SchemaChanges(batch);
    _addV6SchemaChanges(batch);
    _addV7SchemaChanges(batch); // Adiciona as mudanças da v7
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final batch = db.batch();

    if (oldVersion < 2) {
      _addV2SchemaChanges(batch);
    }
    if (oldVersion < 3) {
      _addV3SchemaChanges(batch);
    }
    if (oldVersion < 4) {
      // Recreating combatente_habilidades and combatente_equipamentos in V4 to fix schema if needed
      batch.execute('DROP TABLE IF EXISTS personagem_habilidades'); // old name
      batch.execute('DROP TABLE IF EXISTS personagem_equipamentos'); // old name
      batch.execute('DROP TABLE IF EXISTS combatente_habilidades'); // Ensure clean slate if V4 applied partially
      batch.execute('DROP TABLE IF EXISTS combatente_equipamentos'); // Ensure clean slate if V4 applied partially
      _addV4SchemaChanges(batch);
    }
    if (oldVersion < 5) {
      _addV5SchemaChanges(batch);
    }
    if (oldVersion < 6) {
      _addV6SchemaChanges(batch);
    }
    if (oldVersion < 7) {
      _addV7SchemaChanges(batch); // Apply V7 changes
    }

    await batch.commit(noResult: true);
  }

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
    // V4 was a bit problematic with 'armaId' vs 'itemId'.
    // We are going to ensure V7 explicitly has 'itemId' and 'slot'.
    // So, this V4 create statement should match what the code expects *before* V7.
    // If you actually ran V4, it created 'armaId'. So we rely on V7 to correct it.
    batch.execute(
      '''CREATE TABLE combatente_equipamentos (combatenteId TEXT NOT NULL, armaId TEXT NOT NULL, slot TEXT NOT NULL, PRIMARY KEY (combatenteId, slot))''',
    );
  }

  void _addV5SchemaChanges(Batch batch) {
    batch.execute('ALTER TABLE habilidades ADD COLUMN categoria TEXT');
    batch.execute('ALTER TABLE habilidades ADD COLUMN danoBase INTEGER');
    batch.execute('ALTER TABLE habilidades ADD COLUMN curaBase INTEGER');
  }

  void _addV6SchemaChanges(Batch batch) {
    batch.execute(
      '''CREATE TABLE armaduras (id TEXT PRIMARY KEY, nome TEXT NOT NULL, danoReduzido INTEGER NOT NULL, proficienciaRequerida INTEGER NOT NULL)''',
    );
  }

  // --- NOVA VERSÃO DO ESQUEMA DO BANCO DE DADOS (V7) ---
  void _addV7SchemaChanges(Batch batch) {
    // Drop the old combatente_equipamentos table first if it exists
    batch.execute('DROP TABLE IF EXISTS combatente_equipamentos');
    // Recreate it with the correct itemId column
    batch.execute(
      '''CREATE TABLE combatente_equipamentos (combatenteId TEXT NOT NULL, itemId TEXT NOT NULL, slot TEXT NOT NULL, PRIMARY KEY (combatenteId, slot))''',
    );
    // You might also want to ensure foreign key constraints are added for itemId
    // to reference either 'armas.id' or 'armaduras.id', depending on the slot.
    // This requires more complex SQL that might vary by SQLite version or specific needs.
    // For simplicity, we'll keep it without direct FKs to two different tables in this single table.
    // The business logic and data integrity will be handled in the repository.
  }
}