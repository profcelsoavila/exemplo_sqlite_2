import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo SQLite',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'Exemplo SQLite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //criação do objeto que referencia o banco de dados
  late Future<Database> database;
// criação dos controladores de texto
  final idController = TextEditingController();
  final disciplinaController = TextEditingController();
  final descricaoController = TextEditingController();
  final dataEntregaController = TextEditingController();

  //função para limpar os campos do formulário
  void clear() {
    idController.clear();
    disciplinaController.clear();
    descricaoController.clear();
    dataEntregaController.clear();
  }

  // define o estado inicial do aplicativo.
  //A função initBD é chamada dentro de initState porque initState não pode ser
  //um método assíncrono. Assim, criamos o métodos ass´ncrono fora de initSate
  @override
  void initState()  {
    super.initState();
    initBD();
  }
// função para iniciar o banco de dados
  Future<void> initBD() async{
    //abre o banco de dados no diretório padrão de banco de dados da plataforma
    database = openDatabase(
      join(await getDatabasesPath(), 'minhas_atividades.db'),
      //aso o banco de dados não exista, cria-o especificando a nova versão
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE atividades(id INTEGER PRIMARY KEY, disciplina TEXT, descricao TEXT, dataEntrega TEXT)',
        );
      },
      version: 1,
    );
  }
//função para inserir um novo registro na tabela atividades do banco de dados
  Future<void> insertAtividade(Atividade atividade) async {
    //carrega o banco de dados
    final db = await database;
    //executa o método de inserção
    await db.insert(
      'atividades',
      // a função toMap está implementada no final deste código
      //Sua finalidade é mapear o objeto atividade na estrutura adequada do banco de dados
      atividade.toMap(),
      //evita erros, caso o regsitro seja inserido mais de uma vez
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
//função para listar todas as atividades
  //esta função retorna uma lista de atividades
  Future<List<Atividade>> listAtividades() async {
    final db = await database;
    //cria um objeto para mapear os dados retornados da consulta ao banco de dados em um objeto do tipo List
    final List<Map<String, Object?>> atividadeMaps = await db.query('atividades');
    //percorre a lista atividadeMaps, retornando todos os registros
    return List.generate(atividadeMaps.length, (i) {
      return Atividade(
        id: atividadeMaps[i]['id'] as int,
        disciplina: atividadeMaps[i]['disciplina'] as String,
        descricao: atividadeMaps[i]['descricao'] as String,
        dataEntrega: atividadeMaps[i]['dataEntrega'] as String,
      );
    });
  }
//função para atualizar um registro de Atividade
  Future<void> updateAtividade(Atividade atividade) async {
    //carrega o banco de dados
    final db = await database;
    //executa o método de atualização do registro apontado pelo id, mapeando para o banco de dados
    //
    await db.update(
      'atividades',
      atividade.toMap(),
      where: 'id = ?',
      whereArgs: [atividade.id],
    );
  }
//função para excluir um registro
  Future<void> deleteAtividade(int id) async {
    //carrega o banco de dados
    final db = await database;
    //executa o método de exclusão do registro apontado pelo id
    await db.delete(
      'atividades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //criação do layout da interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'Id'),
            ),
            TextField(
              controller: disciplinaController,
              decoration: InputDecoration(labelText: 'Disciplina'),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: dataEntregaController,
              decoration: InputDecoration(labelText: 'Data de Entrega'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    var atividade = Atividade(
                      id: int.parse(idController.text),
                      disciplina: disciplinaController.text,
                      descricao: descricaoController.text,
                      dataEntrega: dataEntregaController.text,
                    );
                    await insertAtividade(atividade);
                    setState(() {});
                  },
                  child: Text('Inserir'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var atividade = Atividade(
                      id: int.parse(idController.text),
                      disciplina: disciplinaController.text,
                      descricao: descricaoController.text,
                      dataEntrega: dataEntregaController.text,
                    );
                    await updateAtividade(atividade);
                    setState(() {});
                  },
                  child: Text('Atualizar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await deleteAtividade(int.parse(idController.text));
                    setState(() {});
                  },
                  child: Text('Excluir'),
                ),
                ElevatedButton(
                  onPressed: ()  {
                    clear();
                    setState(() {});
                  },
                  child: Text('Limpar'),
                ),
              ],
            ),
            Expanded(
              //cria um widget para conter dados Future. Nesta caso, as atividades cadastradas
              //Um snapshot se refere à lista de atividades retornada pela função definida no parâmetro future
              child: FutureBuilder<List<Atividade>>(
                future: listAtividades(),
                builder: (context, snapshot) {
                  //se o snapshot não conte´m dados
                  if (snapshot.hasError) {
                    return const Center(child: Text('Não existem atividades cadastradas.'));
                  }
                  //se o snapshot contém dados
                  else if (snapshot.hasData) {
                    //retorna um ListView apresentando todas as atividades cadastradas
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        //retorna um bloco de dados na lista
                        return ListTile(
                          title: Text(snapshot.data![index].disciplina),
                          subtitle: Text('Atividade: ${snapshot.data![index].descricao}\nData de Entrega: ${snapshot.data![index].dataEntrega}'),
                          //ao tocar (tap) em um elemento da lista, exibe seus dados nos controladores de texto
                          onTap: () {
                            idController.text = snapshot.data![index].id.toString();
                            disciplinaController.text = snapshot.data![index].disciplina;
                            descricaoController.text = snapshot.data![index].descricao;
                            dataEntregaController.text = snapshot.data![index].dataEntrega;
                          },
                        );
                      },
                    );
                  } else {
                    //apresenta uma animação de 'carregando' enquanto os dados future não são obtidos
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//classe modelo de Atividade
class Atividade {
  final int id;
  final String disciplina;
  final String descricao;
  final String dataEntrega;

//método contrutor da classe modelo
  Atividade({
    required this.id,
    required this.disciplina,
    required this.descricao,
    required this.dataEntrega,
  });

  //função para mapear um objeto da classe Atividade no formato do banco de dados chave: valor (JSON)
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'disciplina': disciplina,
      'descricao': descricao,
      'dataEntrega': dataEntrega,
    };
  }
}
