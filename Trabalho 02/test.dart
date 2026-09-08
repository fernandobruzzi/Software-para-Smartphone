void main(){

  final num = 10;
  var divisores = <int>[];

  for(int i = 1; i < num; i++ ){
    if(num%i==0){
      divisores.add(i);
    }
  }
  print(divisores);
  return ;
}