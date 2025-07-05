/// Define uma interface para objetos que podem ser clonados.
/// O tipo genérico T garante que o método clone retorne um objeto do mesmo tipo.
abstract class IPrototype<T> {
  T clone();
}