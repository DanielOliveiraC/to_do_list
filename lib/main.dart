import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/splashPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      home: SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
    return MyHomeState();
  }
}

class MyHomeState extends State<MyHomePage> {
  final TextEditingController taskController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _tarefasLista = [];
  int? _editIndex;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Carrega as tarefas armazenadas quando o app for iniciado
  }

  // Função para carregar as tarefas salvas
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tarefasLista = prefs.getStringList('tarefas') ?? []; // Carrega a lista ou uma lista vazia
    });
  }

  // Função para salvar as tarefas
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tarefas', _tarefasLista); // Salva a lista de tarefas
  }

  // Função para editar uma tarefa
  void _editTask(int index) {
    setState(() {
      _editIndex = index;
      taskController.text = _tarefasLista[index];
    });
  }

  // Função para salvar a edição de uma tarefa
  void _saveEditedTask() {
    if (_editIndex != null) {
      setState(() {
        _tarefasLista[_editIndex!] = taskController.text;
        _editIndex = null; // Limpa o índice de edição após salvar
      });
      _saveTasks(); // Salva as tarefas após editar
      taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "To-Do list",
            style: TextStyle(fontSize: 20),
          ),
          
        ),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: taskController,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: _editIndex != null ? 'Editar Tarefa...' : 'Adicionar Tarefa...',
                        hintStyle: TextStyle(fontSize: 15),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Nenhuma tarefa inserida.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_editIndex == null) {
                            // Adiciona nova tarefa
                            setState(() {
                              _tarefasLista.add(taskController.text);
                            });
                          } else {
                            // Salva a edição
                            _saveEditedTask();
                          }
                          _saveTasks(); // Salva a lista após adicionar ou editar
                          taskController.clear();
                        }
                      },
                      child: Text(_editIndex != null ? 'Salvar' : 'Add'),
                    ),
                    
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tarefasLista.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        _tarefasLista[index],
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ícone de editar
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editTask(index); // Edita a tarefa ao clicar
                            },
                          ),
                          // Ícone de deletar
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _tarefasLista.removeAt(index);
                              });
                              _saveTasks(); // Salva a lista após deletar a tarefa
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
