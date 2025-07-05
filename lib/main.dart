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
          create: (ctx) =>
              PersonagensViewModel(personagemRepository: ctx.read()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// MainPage agora é StatefulWidget para gerenciar seu próprio TabController
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
        title: const Text('RPG Manager'),
        bottom: TabBar(
          controller: _mainTabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: 'Fichas'),
            Tab(icon: Icon(Icons.groups), text: 'Grupos'),
            Tab(icon: Icon(Icons.settings), text: 'Gerenciamento'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          // Passamos o TabController da MainPage para a FichasTabPage
          FichasTabPage(mainTabController: _mainTabController),
          GerenciarGruposPage(),
          const GerenciamentoGeralPage(),
        ],
      ),
    );
  }
}

// FichasTabPage agora também é StatefulWidget para ter seu TabController
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
        child: TabBar(
          controller: _fichasTabController,
          tabs: const [
            Tab(text: 'PERSONAGENS'),
            Tab(text: 'INIMIGOS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _fichasTabController,
        children: const [GerenciarPersonagensPage(), GerenciarInimigosPage()],
      ),
      // O FAB agora usa ambos os controllers para decidir o que fazer
      floatingActionButton: FloatingActionButton(
        // CORREÇÃO: heroTag único para evitar conflito se outra tela tiver um FAB
        heroTag: 'fichas_fab',
        child: const Icon(Icons.add),
        onPressed: () {
          // Verifica se a aba principal é "Fichas"
          if (widget.mainTabController.index == 0) {
            // Verifica qual sub-aba ("Personagens" ou "Inimigos") está ativa
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
    // Esta página não precisa de um FAB, pois a criação é feita na outra aba.
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.shield),
          title: const Text('Gerenciar Raças'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GerenciarRacasPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.star),
          title: const Text('Gerenciar Classes'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GerenciarClassesPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.hardware),
          title: const Text('Gerenciar Armas'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GerenciarArmasPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.flash_on),
          title: const Text('Gerenciar Habilidades'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GerenciarHabilidadesPage()),
          ),
        ),
      ],
    );
  }
}
