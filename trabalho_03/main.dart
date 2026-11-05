import 'package:flutter/material.dart';

import 'dart:async';

// here we create our home screen as a MaterialApp object so we can edit its properties easily, like color and design
void main() => runApp(const MaterialApp(home: TelaTarefas()));

class Tarefa {
  String texto;
  bool concluded = false;
  bool excluindo = false;

  Tarefa(this.texto);
}

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final List<Tarefa> tarefas = [];
  final TextEditingController controlador = TextEditingController();
  final Map<String, Timer> temporizadores =
      {}; // we need this to cancel the right timer

  void incluirTarefa() {
    final texto = controlador.text.trim();
    if (texto.isEmpty) return;
    if (tarefas.any((t) => t.texto == texto)) return;
    setState(() {
      //       new tasks go to the end of the list of the unconcluded tasks, unfinished tasks always come first, so the number of unfinished tasks is exactly the position where that group ends
      final taskPosition = tarefas.where((t) => !t.concluded).length;
      tarefas.insert(taskPosition, Tarefa(texto));
    });
    controlador.clear();
  }

  void alternarConclusao(Tarefa tarefa) {
    setState(() {
      tarefa.concluded = !tarefa.concluded;
      //       we remove the task
      tarefas.remove(tarefa);
      //       we insert the concluded task in the proper position
      final concludedPosition = tarefas.where((t) => !t.concluded).length;
      tarefas.insert(concludedPosition, tarefa);
    });
  }

  void marcarExclusao(Tarefa tarefa) {
    //    if the tarefa is already being excluded we don't allow it to create another timer
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
    });
  }

  void desfazerExclusao(Tarefa tarefa) {
    setState(() {
      temporizadores[tarefa.texto]?.cancel();
      temporizadores.remove(tarefa.texto);
      tarefa.excluindo = false;
    });
  }

  //   we cancel the temporizadores that are still on and free our controlador
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
      appBar: AppBar(title: const Text('Lista de Tarefas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Here we put our box to include a new task and the button  side by side, that's why they are children of the Row
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
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

            // We create some space between our list insertion part and our list items
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

                      confirmDismiss:
                          (direcao) async //always return false so the item stays on screen; deletion waits for the timer and completion only moves the item
                          {
                            if (direcao == DismissDirection.endToStart) {
                              marcarExclusao(tarefa);
                            } else {
                              if (!tarefa.concluded) {
                                alternarConclusao(tarefa);
                              }
                            }
                            return false;
                          },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20),
                          // the excluindo state has priority over the indigo and purple colors
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