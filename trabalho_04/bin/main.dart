import 'dart:io';
import 'dart:convert';

// Mantemos as credenciais fora do Github 
Future<Map<String, String>> lerDados(String path) async {
  final Map<String, dynamic> data = jsonDecode(await File(path).readAsString());
  final enderecoApi = data["API"] as String;
  final nome = data["nome"] as String;
  final email = data["email"] as String;
  final senha = data["senha"] as String;
  final dados = {
    "enderecoApi": enderecoApi,
    "nome": nome,
    "email": email,
    "senha": senha,
  };
  return dados;
}

// o token é opcional já que cadastro e login ainda não precisam dele
Future<HttpClientResponse> requisicaoRespostaPost(
  Uri endereco,
  String conteudo,
  HttpClient client, {
  String? token,
}) async {
  final requisicao = await client.postUrl(endereco);
  // cabeçalhos precisam vir antes do body
  requisicao.headers.contentType = ContentType.json;
  if (token != null) {
    requisicao.headers.set("Authorization", "Bearer $token");
  }
  requisicao.write(conteudo);

  final resposta = await requisicao.close();
  // o Stream só pode ser lido uma vez por isso deixamos a cargo da função que chama a requisição de lê-lo
  return resposta;
}

Future<HttpClientResponse> requisicaoRespostaGet(
  Uri endereco,
  String token,
  HttpClient client,
) async {
  final requisicao = await client.getUrl(endereco);
  requisicao.headers.set("Authorization", "Bearer $token");
  final resposta = await requisicao.close();
  // o Stream só pode ser lido uma vez por isso deixamos a cargo da função que chama a requisição de lê-lo
  return resposta;
}

Future<HttpClientResponse> requisicaoRespostaPatch(
  Uri endereco,
  String conteudo,
  String token,
  HttpClient client,
) async {
  final requisicao = await client.patchUrl(endereco);
  // cabeçalhos precisam vir antes do body
  requisicao.headers.contentType = ContentType.json;
  requisicao.headers.set("Authorization", "Bearer $token");
  requisicao.write(conteudo);
  final resposta = await requisicao.close();
  // o Stream só pode ser lido uma vez por isso deixamos a cargo da função que chama a requisição de lê-lo
  return resposta;
}

Future<void> cadastrar(
  String enderecoApi,
  String nome,
  String email,
  String senha,
  HttpClient client,
) async {
  final uriCadastro = Uri.parse("$enderecoApi/rpc/registra_usuario");
  final conteudo = jsonEncode({"nome": nome, "email": email, "senha": senha});
  final resposta = await requisicaoRespostaPost(uriCadastro, conteudo, client);
  final respostaBody = await resposta.transform(utf8.decoder).join();
  // vamos checar se o cadastro foi realizado com sucesso, já existia 
  //ou se ocorreu um erro
  if (resposta.statusCode == 200) {
    stderr.writeln("Usuário cadastrado com sucesso!");
  }
  // algumas vezes pode ser que dê o erro 400 e não seja um erro(email em uso)
  else if (resposta.statusCode == 400 &&
      jsonDecode(respostaBody)["message"] == "O email já está em uso") {
    stderr.writeln("Usuário já cadastrado!");
  } else {
    stderr.writeln("Erro no cadastro: ${resposta.statusCode} $respostaBody");
    exit(1);
  }
}

// o token vale por 5 minutos por isso precisamos obtê-lo a cada execução
Future<String> login(
  String enderecoApi,
  String email,
  String senha,
  HttpClient client,
) async {
  final uriLogin = Uri.parse("$enderecoApi/rpc/fazer_login");
  final conteudo = jsonEncode({"email": email, "senha": senha});
  final resposta = await requisicaoRespostaPost(uriLogin, conteudo, client);
  final respostaBody = await resposta.transform(utf8.decoder).join();
  if (resposta.statusCode == 200) {
    stderr.writeln("Login efetuado com sucesso!");
    return jsonDecode(respostaBody)["token"] as String;
  } else {
    stderr.writeln("Erro no login: ${resposta.statusCode} $respostaBody");
    exit(1);
  }
}

Future<void> criarOuEsvaziarListaTarefas(
  String enderecoApi,
  String email,
  String token,
  HttpClient client,
) async {
  final urlTarefas = Uri.parse("$enderecoApi/tarefas");
  final resposta = await requisicaoRespostaGet(urlTarefas, token, client);
  final respostaBody = await resposta.transform(utf8.decoder).join();
  if (resposta.statusCode == 200) {
    stderr.writeln("Consulta a lista de tarefas feita com sucesso!");
  } else {
    stderr.writeln(
      "Erro na consulta a lista de tarefas: ${resposta.statusCode} $respostaBody",
    );
    exit(1);
  }
  // só decodificamos depois de confirmar o 200 porque um corpo de erro
  // pode não ser uma lista
  final List<dynamic> lista = jsonDecode(respostaBody);
  // devemos checar o que a nossa consulta retorna para evitar um segundo POST desnecessário
  if (lista.isEmpty) {
    // devemos criar a lista de tarefas!
    final conteudo = jsonEncode({"email": email, "valor": []});
    final respostaTarefas = await requisicaoRespostaPost(
      urlTarefas,
      conteudo,
      client,
      token: token,
    );
    final respostaTarefasBody = await respostaTarefas
        .transform(utf8.decoder)
        .join();
    // podemos ter múltiplos códigos que não indicam erro e todos são da forma 2XX
    if (respostaTarefas.statusCode >= 200 && respostaTarefas.statusCode < 300) {
      stderr.writeln("Lista de tarefas não existia e portanto foi criada!");
    } else {
      stderr.writeln(
        "Erro na criação da lista de tarefas: ${respostaTarefas.statusCode} $respostaTarefasBody",
      );
      exit(1);
    }
  } else {
    final conteudo = jsonEncode({"valor": []});
    final urlTarefasPatch = Uri.parse("$urlTarefas?email=eq.$email");
    final respostaTarefas = await requisicaoRespostaPatch(
      urlTarefasPatch,
      conteudo,
      token,
      client,
    );
    final respostaTarefasBody = await respostaTarefas
        .transform(utf8.decoder)
        .join();
    // podemos ter múltiplos códigos que não indicam erro e todos são da forma 2XX
    if (respostaTarefas.statusCode >= 200 && respostaTarefas.statusCode < 300) {
      stderr.writeln("Lista de tarefas já existia e portanto foi atualizada!");
    } else {
      stderr.writeln(
        "Erro na atualização da lista de tarefas: ${respostaTarefas.statusCode} $respostaTarefasBody",
      );
      exit(1);
    }
  }
}

// iremos utilizar mensagens escritas em stderr.writeln() para apontar o que ocorre em
// cada etapa do código e não queremos que isso seja visto pelo Juiz(que avalia)
Future<void> main() async {
  // primeiro nos precisamos obter os nossos dados de login e o endereço da API
  final path = "dados.json";
  final dadosBase = await lerDados(path);

  // podemos reaproveitar o mesmo cliente para várias requisições
  final client = HttpClient();
  await cadastrar(
    dadosBase["enderecoApi"]!,
    dadosBase["nome"]!,
    dadosBase["email"]!,
    dadosBase["senha"]!,
    client,
  );

  final token = await login(
    dadosBase["enderecoApi"]!,
    dadosBase["email"]!,
    dadosBase["senha"]!,
    client,
  );

  await criarOuEsvaziarListaTarefas(
    dadosBase["enderecoApi"]!,
    dadosBase["email"]!,
    token,
    client,
  );

  print(token);

  // devemos fechar a conexão ao final
  client.close();
}
