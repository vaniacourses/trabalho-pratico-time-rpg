class Raca {
  final String id;
  final String nome;
  // Conforme o diagrama, um mapa para modificadores de atributo. Ex: {"forca": 2, "destreza": -1}
  final Map<String, int> modificadoresDeAtributo;

  Raca({
    required this.id,
    required this.nome,
    required this.modificadoresDeAtributo,
  });
}