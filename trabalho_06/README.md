# Trabalho 06, Lista de Tarefas com Animações

Aplicativo Flutter que expande a lista de tarefas do Trabalho 05 (login, cadastro e salvamento na API REST do professor) com animações. Ao concluir uma tarefa, ela desliza por cima da lista até a nova posição, inclinando no meio do caminho e chegando alinhada. A lista usa `AnimatedList`, então inclusões e exclusões também abrem e fecham o espaço com animação. Desconcluir move a tarefa para o fim das não concluídas, e a exclusão continua com o desfazer de 3 segundos. Feito para rodar no DartPad (só o `main.dart`).

Rodar de dentro desta pasta com `flutter run -d chrome --dart-define-from-file=dados.json` (precisa do `dados.json` com a chave `API`).

---

# Assignment 06, Animated To-Do List

Flutter app that extends the Assignment 05 to-do list (login, sign-up and storage on the professor's REST API) with animations. When a task is completed, it slides over the list to its new position, tilting halfway and landing level. The list uses `AnimatedList`, so adding and deleting tasks also opens and closes the space with an animation. Unchecking a task moves it to the end of the pending ones, and deletion keeps the 3-second undo. Built to run on DartPad (just `main.dart`).

Run from inside this folder with `flutter run -d chrome --dart-define-from-file=dados.json` (requires `dados.json` with the `API` key).
