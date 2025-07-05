/// Define os níveis hierárquicos de proficiência com armaduras.
/// A ordem é importante para a lógica de verificação (do menor para o maior).
enum ProficienciaArmadura {
  Nenhuma, // index 0
  Leve,    // index 1
  Media,   // index 2
  Pesada,  // index 3
}

/// Define os tipos de proficiência com armas.
enum ProficienciaArma {
  Simples, // index 0
  Marcial, // index 1
}