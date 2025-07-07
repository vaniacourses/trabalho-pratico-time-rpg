import 'package:flutter/material.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/data/models/grupo_model.dart'; 

class SimuladorBatalhaPage extends StatelessWidget {
  final GrupoModel<Personagem> grupoPersonagens;
  final GrupoModel<Inimigo> grupoInimigos;

  const SimuladorBatalhaPage({
    super.key,
    required this.grupoPersonagens,
    required this.grupoInimigos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Simulador de Batalha'),
            Text(
              '${grupoPersonagens.nome} vs ${grupoInimigos.nome}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Personagens',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: grupoPersonagens.membros.length,
                            itemBuilder: (context, index) {
                              final personagem = grupoPersonagens.membros[index];
                              return ListTile(
                                title: Text(personagem.nome),
                                subtitle: Text('HP: ${personagem.vidaAtual}/${personagem.vidaMax}'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Log da Batalha',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            reverse: true,
                            children: const [
                              Text('aaaaaaaaaaaaaa'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lado Direito: Inimigos
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Inimigos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: grupoInimigos.membros.length,
                            itemBuilder: (context, index) {
                              final inimigo = grupoInimigos.membros[index];
                              return ListTile(
                                title: Text(inimigo.nome),
                                subtitle: Text('HP: ${inimigo.vidaAtual}/${inimigo.vidaMax}'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Atacar', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Habilidade', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}