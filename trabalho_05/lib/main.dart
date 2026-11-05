import 'package:flutter/material.dart';

import 'dart:async';

import 'package:http/http.dart' as http;

import 'dart:convert';

const enderecoApi = String.fromEnvironment("API");

// O app começa pelo login; a lista só abre depois de um token válido.
void main() => runApp(const MaterialApp(home: TelaLogin()));

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController controladorEmail = TextEditingController();
  final TextEditingController controladorSenha = TextEditingController();
  String? mensagemErro;

  Future<void> fazerLogin() async {
    if (controladorEmail.text.trim() == "" || controladorSenha.text == "") {
      setState(() {
        mensagemErro = "Você precisa digitar um email e uma senha";
      });
      return;
    }
    final endereco = Uri.parse("$enderecoApi/rpc/fazer_login");
    final response = await http.post(
      endereco,
      body: jsonEncode({
        "email": controladorEmail.text.trim(),
        "senha": controladorSenha.text,
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (!mounted) return;

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody["token"];
      final email = responseBody["email"];
      setState(() {
        mensagemErro = null;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TelaTarefas(token: token, email: email),
        ),
      );
    } else if (response.statusCode == 401) {
      final message = jsonDecode(response.body)["message"];
      setState(() {
        mensagemErro = message;
        if (message == "Usuário não encontrado!") {
          mensagemErro = "$mensagemErro Cadastre-se abaixo!";
        }
      });
    } else {
      setState(() {
        mensagemErro = "Erro no login: ${response.statusCode}";
      });
    }
  }

  // Descarta os controladores quando a tela sai de vez, para liberar a memória.
  @override
  void dispose() {
    controladorEmail.dispose();
    controladorSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controladorEmail,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: controladorSenha,
              decoration: InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            if (mensagemErro != null)
              Text(mensagemErro!, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: fazerLogin, child: const Text("Entrar")),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelaCadastro()),
              ),
              child: const Text("Não tem conta? Cadastre-se!"),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController controladorNome = TextEditingController();
  final TextEditingController controladorEmail = TextEditingController();
  final TextEditingController controladorCelular = TextEditingController();
  final TextEditingController controladorSenha = TextEditingController();
  final TextEditingController controladorConfirmarSenha =
      TextEditingController();
  String? mensagemErro;

  Future<void> fazerCadastro() async {
    if (controladorNome.text.trim() == "" ||
        controladorEmail.text.trim() == "" ||
        controladorSenha.text == "" ||
        controladorConfirmarSenha.text == "") {
      setState(() {
        mensagemErro = "Você precisa digitar os campos Nome, Email, Senha, Por favor confirme a senha";
      });
      return;
    }

    if (controladorConfirmarSenha.text != controladorSenha.text) {
      setState(() {
        mensagemErro = "Digite as mesmas senhas nos campos Senha e Por favor confirme a senha";
      });
      return;
    }
    if (controladorNome.text.trim().length < 3) {
      setState(() {
        mensagemErro = "O nome precisa ter ao menos tres caracteres!";
      });
      return;
    }
    if (!controladorEmail.text.contains("@")) {
      setState(() {
        mensagemErro = "Email está no formato errado!";
      });
      return;
    }

    if (!RegExp(r'^[0-9 ()+\-.]+$').hasMatch(controladorCelular.text.trim()) &&
        controladorCelular.text.trim() != "") {
      setState(() {
        mensagemErro = "Celular está no formato errado!";
      });
      return;
    }

    setState(() {
      mensagemErro = null;
    });
    final endereco = Uri.parse("$enderecoApi/rpc/registra_usuario");
    final response = await http.post(
      endereco,
      body: jsonEncode({
        "nome": controladorNome.text.trim(),
        "email": controladorEmail.text.trim(),
        "senha": controladorSenha.text,
        if (controladorCelular.text.trim() != "")
          "celular": controladorCelular.text.trim(),
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cadastro realizado! Você pode fazer o login agora."),
        ),
      );
      Navigator.pop(context);
    } else if (response.statusCode == 400) {
      setState(() {
        mensagemErro = jsonDecode(response.body)["message"];
      });
    } else {
      setState(() {
        mensagemErro = "Erro no cadastro! Código: ${response.statusCode}";
      });
    }
  }

  // Descarta os controladores quando a tela sai de vez, para liberar a memória.
  @override
  void dispose() {
    controladorNome.dispose();
    controladorEmail.dispose();
    controladorCelular.dispose();
    controladorSenha.dispose();
    controladorConfirmarSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controladorNome,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: controladorEmail,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: controladorCelular,
              decoration: InputDecoration(labelText: "Celular"),
            ),
            TextField(
              controller: controladorSenha,
              decoration: InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            TextField(
              controller: controladorConfirmarSenha,
              decoration: InputDecoration(
                labelText: "Por favor confirme a senha",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: fazerCadastro,
              child: const Text("Cadastrar"),
            ),
            if (mensagemErro != null)
              Text(mensagemErro!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class Tarefa {
  String texto;
  bool concluded = false;
  bool excluindo = false;

  Tarefa(this.texto);

  Map<String, dynamic> paraJson() {
    return {"texto": texto, "concluded": concluded};
  }
}

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key, required this.token, required this.email});
  final String token;
  final String email;
  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final List<Tarefa> tarefas = [];
  final TextEditingController controlador = TextEditingController();
  // a chave é o texto da tarefa, para o desfazer cancelar o temporizador certo
  final Map<String, Timer> temporizadores = {};
  // Decide entre POST (criar a linha) e PATCH (alterar a linha). Começa false porque, se estiver errado, o POST dá 409 e o erro aparece; um PATCH sem linha daria 204 sem salvar nada.
  bool listaExisteNoServidor = false;

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  void incluirTarefa() {
    final texto = controlador.text.trim();
    if (texto.isEmpty) return;
    if (tarefas.any((t) => t.texto == texto)) return;
    setState(() {
      // As novas entram no fim das pendentes; como as pendentes vêm sempre primeiro, a quantidade delas é a posição onde esse grupo termina.
      final taskPosition = tarefas.where((t) => !t.concluded).length;
      tarefas.insert(taskPosition, Tarefa(texto));
    });
    salvarTarefas();
    controlador.clear();
  }

  void alternarConclusao(Tarefa tarefa) {
    setState(() {
      tarefa.concluded = !tarefa.concluded;
      tarefas.remove(tarefa);
      // Reinsere na fronteira entre pendentes e concluídas; a mesma conta serve para concluir e para desconcluir.
      final concludedPosition = tarefas.where((t) => !t.concluded).length;
      tarefas.insert(concludedPosition, tarefa);
    });
    salvarTarefas();
  }

  void marcarExclusao(Tarefa tarefa) {
    // Se a tarefa já está em exclusão, não cria um segundo temporizador.
    if (tarefa.excluindo) {
      return;
    }

    setState(() {
      tarefa.excluindo = true;
    });

    temporizadores[tarefa.texto] = Timer(const Duration(seconds: 3), () {
      setState(() {
        tarefas.removeWhere((t) => t.texto == tarefa.texto);
        temporizadores.remove(tarefa.texto);
      });
      // Salva só quando a tarefa sai de verdade; no clique ela ainda está na lista e pode ser desfeita.
      salvarTarefas();
    });
  }

  void desfazerExclusao(Tarefa tarefa) {
    setState(() {
      temporizadores[tarefa.texto]?.cancel();
      temporizadores.remove(tarefa.texto);
      tarefa.excluindo = false;
    });
  }

  Future<void> carregarTarefas() async {
    final endereco = Uri.parse("$enderecoApi/tarefas");
    final response = await http.get(
      endereco,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );
    if (!mounted) return;
    if (response.statusCode == 401) {
      voltarAoLogin();
      return;
    }
    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      // A resposta é uma lista de linhas da tabela; vazia quer dizer que a lista ainda não foi criada no servidor.
      if (responseBody.isNotEmpty) {
        List<dynamic> tarefasServidor = responseBody[0]["valor"];
        setState(() {
          for (final item in tarefasServidor) {
            Tarefa t = Tarefa(item["texto"]);
            t.concluded = item["concluded"];
            tarefas.add(t);
          }
          listaExisteNoServidor = true;
        });
      }
    }
  }

  Future<void> salvarTarefas() async {
    final listaDeTarefas = tarefas.map((t) => t.paraJson()).toList();
    if (!listaExisteNoServidor) {
      final endereco = Uri.parse("$enderecoApi/tarefas");
      final response = await http.post(
        endereco,
        body: jsonEncode({
          "email": widget.email.trim(),
          "valor": listaDeTarefas,
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );
      if (!mounted) return;
      if (response.statusCode == 401) {
        voltarAoLogin();
        return;
      }
      // Só marca depois da confirmação do servidor; se o POST falhar, o próximo salvamento tenta criar de novo.
      if (response.statusCode == 201) {
        listaExisteNoServidor = true;
      }
    } else {
      final endereco = Uri.parse(
        "$enderecoApi/tarefas?email=eq.${widget.email}",
      );
      final response = await http.patch(
        endereco,
        body: jsonEncode({"valor": listaDeTarefas}),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );
      if (!mounted) return;
      if (response.statusCode == 401) {
        voltarAoLogin();
        return;
      }
    }
  }

  // Token vencido: pushReplacement tira esta tela da pilha (o dispose cancela os temporizadores) e não deixa seta para voltar.
  void voltarAoLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "A sua sessão foi expirada! É necessário fazer login novamente para conseguir realizar alterações na lista de tarefas!",
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
    );
  }

  // Cancela os temporizadores pendentes para nenhum disparar depois que a tela sair.
  @override
  void dispose() {
    for (final t in temporizadores.values) {
      t.cancel();
    }
    temporizadores.clear();
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas | usuário: ${widget.email}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo e botão lado a lado; o Expanded faz o campo ocupar o espaço que sobra.
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: TextField(
                      controller: controlador,
                      onSubmitted: (_) => incluirTarefa(),
                      decoration: const InputDecoration(
                        hintText: "Digite uma tarefa!",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: incluirTarefa,
                  child: const Text("Incluir"),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.cyan.shade100,
                ),
                child: ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];
                    return Dismissible(
                      key: ValueKey(tarefa.texto),
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),

                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green,
                        ),
                        child: const Icon(Icons.beenhere),
                      ),
                      secondaryBackground: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),

                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red,
                        ),
                        child: const Icon(Icons.backspace),
                      ),
                      // Sempre devolve false para o item continuar na tela: a exclusão espera o temporizador e a conclusão só muda a posição.
                      confirmDismiss: (direcao) async {
                        if (direcao == DismissDirection.endToStart) {
                          marcarExclusao(tarefa);
                        } else if (!tarefa.concluded) {
                          alternarConclusao(tarefa);
                        }

                        return false;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20),
                          // O vermelho da exclusão tem prioridade sobre as cores alternadas.
                          color: tarefa.excluindo
                              ? Colors.red.shade400
                              : index % 2 == 0
                              ? Colors.indigo.shade100
                              : Colors.purpleAccent.shade100,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),

                        child: ListTile(
                          title: Text(
                            tarefa.texto,
                            style: TextStyle(
                              decoration: tarefa.concluded
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          leading: Checkbox(
                            value: tarefa.concluded,
                            onChanged: (_) => alternarConclusao(tarefa),
                          ),
                          trailing: tarefa.excluindo
                              ? IconButton(
                                  icon: Icon(Icons.undo),
                                  onPressed: () => desfazerExclusao(tarefa),
                                )
                              : IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => marcarExclusao(tarefa),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
