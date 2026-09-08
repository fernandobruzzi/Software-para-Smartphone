import 'dart:io';

void main(){

  final line = stdin.readLineSync();
  
  if (line == null || line.trim().isEmpty) {
    print("Por favor forneça dois números inteiros positivos.");
    return;
  }

  final parts = line.trim().split(RegExp(r'\s+'));

  if(parts.length < 2){
    print("Por favor forneça dois números inteiros positivos.");
    return;
  }

  int? a = int.tryParse(parts[0]);
  int? b = int.tryParse(parts[1]);

  if (a != null && b != null) {

    // we check if the input is valid eventhough it is integers
    if(a > b){
      print("O primeiro número deve ser menor ou igual ao segundo.");
      return;
    }
    if(a < 0 || b < 0){
      print("Por favor forneça dois números inteiros positivos.");
      return;
    }

    List<int> perfect_numbers = [];
    List<List<int>> perfect_numbers_list = [];
    for(int i = a; i < b; i++){
      var result = perfectNum(i);
      if(result !=null){
        var (pNum, divisorspNum) = result;
        perfect_numbers.add(pNum);
        perfect_numbers_list.add(divisorspNum);
      }
    }
    if(perfect_numbers.isNotEmpty){
      for(int i = 0; i < perfect_numbers.length; i++){
        print("${perfect_numbers[i]} é um número perfeito.");
        print("Fatores: ${perfect_numbers_list[i]}");
      }
    }
    else{
      print("Nenhum número perfeito encontrado na faixa entre $a e $b.");
    }

    

    var abundant_number = abundantNum(a,b);
    if(abundant_number != null){
      final(numabundante, soma, divisores_abun) = abundant_number;
      print("Maior número abundante: $numabundante");
      print("Fatores: $divisores_abun");
      print("Soma dos fatores: $soma");
    }
    else{
      print("Nenhum número abundante encontrado na faixa entre $a e $b.");
    }
    return;
    
    print("Não é vazio!");
  } else if (double.tryParse(parts[0]) != null || double.tryParse(parts[1]) != null ) {
    print("Por favor forneça dois números inteiros positivos.");
  } else if (parts[0].contains(',') || parts[1].contains(',')) {
    print("Formato numérico inválido!");
  } else {
    print("Por favor forneça dois números inteiros positivos.");
  }

  return;
  
}

(int, List<int>)? perfectNum(int num){

  // first we get the numbers that divide our num
  var divisores = divisores_proprios(num);

  // then we check if the divisors sum to num
  int sum = 0;
  for(int i = 0; i < divisores.length; i++){
    sum+=divisores[i];
  }
  
  if(sum==num){
    // print("É número perfeito!");
    return (num, divisores);

  }
  else{
    // print("Não é um número perfeito!");
    return null;
  }
}

(int, int, List<int>)? abundantNum(int a, int b){

  int greatest_num = 0;
  int greatest_sum = 0;
  List<int>? greatest_div;

  for(int i = a; i <= b; i++){
    final divisores = divisores_proprios(i);
    final sum = divisores.fold(0,(x, y) => x + y);
    if(sum>i && sum > greatest_sum){
      greatest_num = i;
      greatest_sum = sum;  
      greatest_div = divisores;    
    }
  }
  if(greatest_div != null){
    return(greatest_num, greatest_sum, greatest_div);
  }
  return null;
}

List<int> divisores_proprios(num){

  List<int> divisores = [];

  // first we get the numbers that divide our num
  for(int i = 1; i<num; i++){
    if(num%i==0){
      divisores.add(i);
    }
  }
  return divisores;
}