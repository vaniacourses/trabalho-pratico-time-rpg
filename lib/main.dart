import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/factories/inimigo_factory_impl.dart';
import 'package:trabalho_rpg/data/factories/personagem_factory_impl.dart';
import 'package:trabalho_rpg/data/repositories/arma_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/classe_personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/grupo_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/habilidade_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/inimigo_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/raca_repository_impl.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_grupo_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:trabalho_rpg/presentation/pages/criar_editar_inimigo_page.dart';
import 'package:trabalho_rpg/presentation/pages/criar_personagem_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_armas_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_classes_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_grupos_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_habilidades_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_inimigos_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_personagens_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_racas_page.dart';
import 'package:trabalho_rpg/presentation/providers/armas_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/classes_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/criar_personagem_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/grupos_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/habilidades_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/inimigos_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/personagens_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/racas_view_model.dart';
import 'package:uuid/uuid.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyAppProviders());
}

class MyAppProviders extends StatelessWidget {
  const MyAppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Uuid>(create: (_) => const Uuid()),
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
        ProxyProvider<DatabaseHelper, IRacaRepository>(
          update: (_, db, __) => RacaRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IGrupoRepository<Personagem>>(
          update: (_, db, __) => GrupoRepositoryImpl<Personagem>(
            dbHelper: db,
            personagemRepository: PersonagemRepositoryImpl(
              dbHelper: db,
              habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
            ),
            inimigoRepository: InimigoRepositoryImpl(
              dbHelper: db,
              habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
            ),
          ),
        ),
        ProxyProvider<DatabaseHelper, IGrupoRepository<Inimigo>>(
          update: (_, db, __) => GrupoRepositoryImpl<Inimigo>(
            dbHelper: db,
            personagemRepository: PersonagemRepositoryImpl(
              dbHelper: db,
              habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
            ),
            inimigoRepository: InimigoRepositoryImpl(
              dbHelper: db,
              habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
            ),
          ),
        ),
        ProxyProvider<DatabaseHelper, IClassePersonagemRepository>(
          update: (_, db, __) => ClassePersonagemRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IArmaRepository>(
          update: (_, db, __) => ArmaRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IHabilidadeRepository>(
          update: (_, db, __) => HabilidadeRepositoryImpl(dbHelper: db),
        ),
        ProxyProvider<DatabaseHelper, IPersonagemRepository>(
          update: (_, db, __) => PersonagemRepositoryImpl(
            dbHelper: db,
            habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
          ),
        ),
        ProxyProvider<DatabaseHelper, IInimigoRepository>(
          update: (_, db, __) => InimigoRepositoryImpl(
            dbHelper: db,
            habilidadeRepository: HabilidadeRepositoryImpl(dbHelper: db),
          ),
        ),
        Provider<PersonagemFactoryImpl>(
          create: (ctx) => PersonagemFactoryImpl(
            racaRepository: ctx.read(),
            classeRepository: ctx.read(),
            armaRepository: ctx.read(),
            habilidadeRepository: ctx.read(),
            uuid: ctx.read(),
          ),
        ),
        Provider<InimigoFactoryImpl>(
          create: (ctx) => InimigoFactoryImpl(
            armaRepository: ctx.read(),
            habilidadeRepository: ctx.read(),
            uuid: ctx.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              RacasViewModel(racaRepository: ctx.read(), uuid: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              ClassesViewModel(classeRepository: ctx.read(), uuid: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              ArmasViewModel(armaRepository: ctx.read(), uuid: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HabilidadesViewModel(
            habilidadeRepository: ctx.read(),
            uuid: ctx.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PersonagensViewModel(personagemRepository: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => InimigosViewModel(
            inimigoRepository: ctx.read(),
            inimigoFactory: ctx.read(),
            armaRepository: ctx.read(),
            habilidadeRepository: ctx.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CriarPersonagemViewModel(
            racaRepository: ctx.read(),
            classeRepository: ctx.read(),
            armaRepository: ctx.read(),
            habilidadeRepository: ctx.read(),
            personagemRepository: ctx.read(),
            fichaFactory: ctx.read<PersonagemFactoryImpl>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GruposViewModel(
            grupoPersonagemRepository: ctx.read<IGrupoRepository<Personagem>>(),
            grupoInimigoRepository: ctx.read<IGrupoRepository<Inimigo>>(),
            uuid: ctx.read<Uuid>(),
          ),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Battle Manager',
      theme: ThemeData(
        // Soft Pastel Color Scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB39DDB), // Muted Lavender (Primary)
          primary: const Color(0xFFB39DDB), // Muted Lavender
          primaryContainer: const Color(0xFFD1C4E9), // Lighter Lavender
          secondary: const Color(0xFF81C784), // Soft Green (Accent)
          secondaryContainer: const Color(0xFFA5D6A7), // Lighter Soft Green
          tertiary: const Color(0xFF90CAF9), // Soft Blue
          surface: const Color(0xFFF5F5F5), // Light Grey (Background for cards/dialogs)
          background: const Color(0xFFEDE7F6), // Very Light Lavender (Overall background)
          error: const Color(0xFFEF9A9A), // Soft Red for errors
          onPrimary: Colors.white,
          onSecondary: Colors.black87, // Black for text on light green
          onSurface: Colors.black87, // Black for text on light grey
          onBackground: Colors.black87, // Black for text on very light lavender
          onError: Colors.white,
        ),
        useMaterial3: true,
        // Card theming for list tiles
        cardTheme: const CardThemeData(
          color: Color(0xFFFFFFFF), // Pure White for cards
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0xFFD1C4E9), width: 1.5), // Soft Lavender border
          ),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: const Color(0xFF81C784), // Soft Green for icons
          textColor: Colors.black87,
          tileColor: Colors.transparent, // Transparent to show card background
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB39DDB), // Muted Lavender app bar
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.white, // White for selected tab text
          unselectedLabelColor: Colors.white70, // Slightly transparent white for unselected
          indicatorColor: const Color(0xFF81C784), // Soft Green indicator
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF81C784), // Soft Green FAB
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFFD1C4E9), width: 2), // Lighter Lavender border
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE0E0E0), // Light Grey for input fields
          labelStyle: const TextStyle(color: Colors.black54), // Muted black for labels
          hintStyle: const TextStyle(color: Colors.black38), // Even more muted for hints
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFC5CAE9)), // Soft border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFC5CAE9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF81C784), width: 2), // Soft Green focus border
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

// MainPage and other pages remain the same in structure, only inheriting new theme

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late final TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPG Battle Manager'),
        bottom: TabBar(
          controller: _mainTabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Characters'),
            Tab(icon: Icon(Icons.castle), text: 'Groups'),
            Tab(icon: Icon(Icons.auto_stories), text: 'Codex'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          FichasTabPage(mainTabController: _mainTabController),
          GerenciarGruposPage(),
          const GerenciamentoGeralPage(),
        ],
      ),
    );
  }
}

class FichasTabPage extends StatefulWidget {
  final TabController mainTabController;
  const FichasTabPage({super.key, required this.mainTabController});

  @override
  State<FichasTabPage> createState() => _FichasTabPageState();
}

class _FichasTabPageState extends State<FichasTabPage>
    with TickerProviderStateMixin {
  late final TabController _fichasTabController;

  @override
  void initState() {
    super.initState();
    _fichasTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _fichasTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: TabBar(
            controller: _fichasTabController,
            tabs: const [
              Tab(text: 'HEROES'),
              Tab(text: 'FOES'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _fichasTabController,
        children: const [GerenciarPersonagensPage(), GerenciarInimigosPage()],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fichas_fab',
        child: const Icon(Icons.add_box),
        onPressed: () {
          if (widget.mainTabController.index == 0) {
            if (_fichasTabController.index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CriarPersonagemPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CriarEditarInimigoPage(),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class GerenciamentoGeralPage extends StatelessWidget {
  const GerenciamentoGeralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Manage Races'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarRacasPage()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_florist),
            title: const Text('Manage Classes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarClassesPage()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Manage Weapons'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarArmasPage()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Manage Abilities'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarHabilidadesPage()),
            ),
          ),
        ),
      ],
    );
  }
}