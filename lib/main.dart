import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/factories/personagem_factory_impl.dart';
import 'package:trabalho_rpg/data/repositories/arma_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/classe_personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/habilidade_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/personagem_repository_impl.dart';
import 'package:trabalho_rpg/data/repositories/raca_repository_impl.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:trabalho_rpg/presentation/pages/criar_personagem_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_armas_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_classes_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_habilidades_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_personagens_page.dart';
import 'package:trabalho_rpg/presentation/pages/gerenciar_racas_page.dart';
import 'package:trabalho_rpg/presentation/providers/armas_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/classes_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/criar_personagem_view_model.dart';
import 'package:trabalho_rpg/presentation/providers/habilidades_view_model.dart';
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
        // Adicione todos os seus providers aqui
        Provider<Uuid>(create: (_) => const Uuid()),
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
        ProxyProvider<DatabaseHelper, IRacaRepository>(
          update: (_, db, __) => RacaRepositoryImpl(dbHelper: db),
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
        ProxyProvider4<
          IRacaRepository,
          IClassePersonagemRepository,
          IArmaRepository,
          IHabilidadeRepository,
          IFichaFactory
        >(
          update: (_, racaRepo, classeRepo, armaRepo, habRepo, __) =>
              PersonagemFactoryImpl(
            racaRepository: racaRepo,
            classeRepository: classeRepo,
                armaRepository: armaRepo,
                habilidadeRepository: habRepo,
            uuid: const Uuid(),
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
          create: (ctx) => CriarPersonagemViewModel(
            racaRepository: ctx.read<IRacaRepository>(),
            classeRepository: ctx.read<IClassePersonagemRepository>(),
            armaRepository: ctx.read<IArmaRepository>(),
            habilidadeRepository: ctx.read<IHabilidadeRepository>(),
            personagemRepository: ctx.read<IPersonagemRepository>(),
            fichaFactory: ctx.read<IFichaFactory>(),
          ),
        ),
        // NOVO VIEWMODEL
        ChangeNotifierProvider(
          create: (ctx) => PersonagensViewModel(
            personagemRepository: ctx.read<IPersonagemRepository>(),
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

// MainPage agora usa abas (TabBar) para uma melhor organização
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Teremos 2 abas principais: Fichas e Gerenciamento
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RPG Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Fichas'),
              Tab(icon: Icon(Icons.settings), text: 'Gerenciamento'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Conteúdo da Aba "Fichas"
            GerenciarPersonagensPage(),
            // Conteúdo da Aba "Gerenciamento"
            GerenciamentoGeralPage(),
          ],
        ),
        // O FAB agora fica dentro da aba correta
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CriarPersonagemPage()),
            ).then((_) {
              // Atualiza a lista de personagens quando volta da tela de criação
              Provider.of<PersonagensViewModel>(
                context,
                listen: false,
              ).fetchPersonagens();
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// Novo widget para organizar as páginas de gerenciamento
class GerenciamentoGeralPage extends StatelessWidget {
  const GerenciamentoGeralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.shield),
          title: const Text('Gerenciar Raças'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarRacasPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.star),
          title: const Text('Gerenciar Classes'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarClassesPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.hardware),
          title: const Text('Gerenciar Armas'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarArmasPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.flash_on),
          title: const Text('Gerenciar Habilidades'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GerenciarHabilidadesPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
