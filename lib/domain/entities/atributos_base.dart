class AtributosBase {
  int forca;
  int destreza;
  int constituicao;
  int inteligencia;
  int sabedoria;
  int carisma;

  AtributosBase({
    required this.forca,
    required this.destreza,
    required this.constituicao,
    required this.inteligencia,
    required this.sabedoria,
    required this.carisma,
  });

  /// ADICIONADO: Método para calcular o modificador de um atributo.
  /// A fórmula (valor - 10) / 2 é padrão em sistemas D&D.
  /// Usamos a divisão inteira '~/' para garantir que o resultado seja um int.
  int getModificador(String atributo) {
    switch (atributo.toLowerCase()) {
      case 'forca':
        return (forca - 10) ~/ 2;
      case 'destreza':
        return (destreza - 10) ~/ 2;
      case 'constituicao':
        return (constituicao - 10) ~/ 2;
      case 'inteligencia':
        return (inteligencia - 10) ~/ 2;
      case 'sabedoria':
        return (sabedoria - 10) ~/ 2;
      case 'carisma':
        return (carisma - 10) ~/ 2;
      default:
        return 0;
    }
  }
}