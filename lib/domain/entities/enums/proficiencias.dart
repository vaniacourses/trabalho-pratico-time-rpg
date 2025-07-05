/// Define os níveis hierárquicos de proficiência com armaduras.
/// A ordem aqui é importante (do menor para o maior), pois permite
/// fazer verificações como: "proficiência do personagem >= proficiência da armadura".
enum ProficienciaArmadura {
  Nenhuma,
  Leve,
  Media,
  Pesada,
}

/// Define os tipos de proficiência com armas.
enum ProficienciaArma {
  Simples,
  Marcial,
}