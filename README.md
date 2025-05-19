# RPG Battle Manager

**RPG Battle Manager** é um projeto de software voltado para a criação, gerenciamento e simulação de batalhas em jogos de interpretação de papéis (RPG). O sistema foi desenvolvido como parte de uma disciplina universitária, com foco em práticas de análise e modelagem de sistemas.

## 🎯 Objetivo

Desenvolver um aplicativo multiplataforma que permita ao usuário:
- Criar fichas detalhadas de personagens e inimigos com alta customização;
- Organizar personagens e inimigos em grupos;
- Configurar cenários e iniciar batalhas simuladas;
- Gerenciar o combate com regras próprias de turno, vida, mana, e habilidades;
- Armazenar e recuperar dados localmente de forma persistente.

## 🗂️ Escopo do Sistema

O sistema permite:
- Criação de fichas de personagens e inimigos;
- Organização de grupos de combate;
- Configuração de batalhas com cenários;
- Gerenciamento do combate por turnos;
- Registro do histórico de ações;
- Armazenamento de fichas, grupos e batalhas em banco de dados local.

## 🧩 Funcionalidades Principais

- Criação e edição de fichas de personagens;
- Criação e edição de fichas de inimigos;
- Formação de grupos de até 4 personagens;
- Inclusão de múltiplos inimigos por grupo;
- Seleção de cenário para batalhas;
- Gerenciamento completo do combate (turnos, efeitos, ações);
- Persistência local dos dados entre sessões.

## 📝 Modelagem do Sistema

### ✅ Diagrama de Casos de Uso

Representa as interações do usuário com o sistema, incluindo:
- Criação de fichas;
- Gerenciamento de grupos;
- Configuração e gerenciamento de batalhas.

### ✅ Diagrama de Classes

Modelo estrutural que define as principais entidades do sistema, como:
- `Combatente` (abstrato)
- `Personagem` e `Inimigo`
- `Grupo`, `Jogo`, `Cenário`
- `Item`, `Habilidade`, `Arma` (com uso de interface `Ação`)
- `Configurações`, `Menu`, entre outros.

### ✅ Diagrama de Sequência (exemplo)

Foi modelado o fluxo de **Gerenciamento de Grupo de Personagens**, descrevendo a interação entre o usuário, os personagens e o banco de dados durante as operações de edição, exclusão e salvamento.

## 🛠️ Tecnologias Planejadas

O sistema será implementado com foco em compatibilidade multiplataforma. As decisões de implementação incluem:
- Interface amigável e responsiva;
- Armazenamento local com banco de dados leve;
- Navegação intuitiva entre funcionalidades;
- Futuras extensões para multiplayer, nuvem e exportação de dados (fora do escopo atual).


## 👥 Equipe

- **Alunos:** Gabriel Gomes, Ramon Pedro, Pedro Umpierre, Lucas Vitorino, Frederico Antunes, Willian Benevides
- **Disciplina:** Projeto de Software
- **Professor(a):** Vania de Oliveira Neves
- **Instituição:** Universidade Federal Fluminense