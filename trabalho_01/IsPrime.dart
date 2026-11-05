import 'dart:io';

void main() {
  final input = stdin.readLineSync();

  if (input == null || input.isEmpty) {
    print("Entrada vazia!");
    return;
  }

  final num = int.tryParse(input);

  if (num != null) {
    final resultado = isPrime(num);
    print(resultado);
  } else if (double.tryParse(input) != null) {
    print("Não é inteiro!");
  } else if (input.contains(',')) {
    print("Formato numérico inválido!");
  } else {
    print("Não é um número!");
  }

  return;
}

String isPrime(int num) {
  if (num < 0) return ("Número negativo!");
  if (num <= 1) return ("Não é primo!");

  for (int i = 2; i < num; i++) {
    if (num % i == 0) {
      return ("Não é primo!");
    }
  }
  return ("É primo!");
}