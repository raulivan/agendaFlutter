import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

final String tabela = "contatoTable";
final String idColumn = "idColumn";
final String nomeColumn = "nomeColumn";
final String emailColumn = "emailColumn";
final String telefoneColumn = "telefoneColumn";
final String fotoColumn = "fotoColumn";

class ContatoHelper {
  static final ContatoHelper _instance = new ContatoHelper.internal();

  factory ContatoHelper() => _instance;

  ContatoHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initDb();
    }
    return _db;
  }

  Future<Database> initDb() async {
    final caminhosDb = await getDatabasesPath();
    final path = join(caminhosDb, "contato_app.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $tabela($idColumn INTEGER PRIMARY KEY, $nomeColumn TEXT, $emailColumn TEXT, $telefoneColumn TEXT, $fotoColumn TEXT)");
    });
  }

  Future<Contato> incluir(Contato contato) async {
    var banco = await db;
    contato.id = await banco.insert(tabela, contato.toMap());
    return contato;
  }

  Future<Contato> selecionar(int id) async {
    var banco = await db;
    List<Map> maps = await banco.query(tabela,
        columns: [
          idColumn,
          nomeColumn,
          emailColumn,
          telefoneColumn,
          fotoColumn
        ],
        where: '$idColumn = ?',
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contato.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> excluir(int id) async {
    var banco = await db;
    return await banco.delete(tabela, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> alterar(Contato contato) async {
    var banco = await db;
    return await banco.update(tabela, contato.toMap(),
        where: '$idColumn = ?', whereArgs: [contato.id]);
  }

  Future<List> selecionarTodos() async {
    var banco = await db;
    List<Map> maps = await banco.rawQuery('SELECT * FROM $tabela');
    var retorno = new List<Contato>();

    for (var item in maps) {
      retorno.add(Contato.fromMap(item));
    }

    return retorno;
  }

  Future<int> quantidade() async {
    var banco = await db;
    return Sqflite.firstIntValue(
        await banco.rawQuery('SELECT count($idColumn) FROM $tabela'));
  }

  Future close() async {
    var banco = await db;
    banco.close();
  }
}

class Contato {
  int id;
  String nome;
  String email;
  String telefone;
  String foto;

  Contato({this.id, this.nome, this.email, this.telefone, this.foto});

  Contato.fromMap(Map map) {
    id = map[idColumn];
    nome = map[nomeColumn];
    email = map[emailColumn];
    telefone = map[telefoneColumn];
    foto = map[fotoColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeColumn: nome,
      emailColumn: email,
      telefoneColumn: telefone,
      fotoColumn: foto
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return 'Contato (id: $id, nome: $nome, email: $email telefone: $telefone foto: $foto)';
  }
}
