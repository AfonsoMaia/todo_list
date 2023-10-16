import 'package:flutter/material.dart'; //material(android) e cupertino(ios)=todos componentes
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//adiciona abaixo dessa linha a string de conexão com o Firebase, cria se o objeto FirebaseOptions troca chave por parentese
const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyDfkYev8VKiPNt0k6t8Aw6LdJqVMh9duUQ",
    authDomain: "todo-list-65336.firebaseapp.com",
    projectId: "todo-list-65336",
    storageBucket: "todo-list-65336.appspot.com",
    messagingSenderId: "571679944793",
    appId: "1:571679944793:web:4b9b27b071cbdea5390148");

class Task {
  final String title;
  String subtitle;
  String priority;
  bool isCompleted;

  Task(this.title, this.subtitle, this.priority, this.isCompleted);
}

/*List<Task> tasks = [
  Task("Task 1", "Alta prioridade", "Alta", true),
  Task("Task 2", "Média prioridade", "Média",  true),
  Task("Task 3", "Baixa prioridade", "Baixa",  true),
];*/

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      routes: {
        "/lista": (context) => TaskList(),
        "/cadastro": (context) => TaskCreate(),
      },
      initialRoute: "/lista",
    );
  }
}

class TaskList extends StatelessWidget {
  final firestore = FirebaseFirestore.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed("/cadastro"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore
              .collection('tasks')
              .orderBy("priority", descending: false)
              //.where('finished', isEqualTo: false) //se acionar esse comando vai apagar da tela
              .snapshots(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            if (snapshot.hasError) return Text(snapshot.error.toString());

            var docs = snapshot.data!.docs;

            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: docs.length, // Usar o tamanho da coleção Firebase
                itemBuilder: (context, index) {
                  var doc = docs[index];
                  int taskNumber = index + 1; //adiciona um contador antes da tarefa
                  return Card(
                    child: CheckboxListTile(
                      title: Text('$taskNumber. ${doc['name']}'), //mostra o numero na tela das tarefas
                      //subtitle:Text(doc['subtitle']), // Adicione o subtítulo aqui
                      subtitle: Text(
                        doc['priority'] + " prioridade",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: doc['finished'],
                      onChanged: (value) =>
                          doc.reference.update({'finished': value!}),
                    ),
                  );
                });
          }),
    );
  }
}

class TaskCreate extends StatelessWidget {
  final firestore = FirebaseFirestore.instance;
  TextEditingController txtCtrl = new TextEditingController();
  TextEditingController txtCtrl1 = new TextEditingController();
  TextEditingController txtCtrl2 = new TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: txtCtrl,
              decoration: InputDecoration(labelText: "Task"),
            ),
            TextField(
              controller: txtCtrl1,
              decoration: InputDecoration(labelText: "Subtitle"),
            ),
            TextField(
              controller: txtCtrl2,
              decoration: InputDecoration(
                labelText: "Priority",
                labelStyle: TextStyle(color: Colors.red),
              ),
              style: TextStyle(color: Colors.red),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Salvar"),
                onPressed: () {
                  firestore.collection('tasks').add({
                    "name": txtCtrl.text,
                    "subtitle": txtCtrl1.text,
                    "priority": txtCtrl2.text,
                    "finished": false
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(MyApp());
}
