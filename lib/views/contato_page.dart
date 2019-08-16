import 'package:flutter/material.dart';
import 'package:agenda_contos/helpers/contato_helper.dart';
import 'dart:io';

class ContatoPage extends StatefulWidget {
  final Contato contato;
  ContatoPage({this.contato});
  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  final _nomeFocus = FocusNode();
  final _telefoneFocus = FocusNode();

  bool _registroAlterado = false;
  Contato _contatoEdicao;

  @override
  void initState() {
    super.initState();

    if (widget.contato == null) {
      _contatoEdicao = new Contato();
    } else {
      _contatoEdicao = Contato.fromMap(widget.contato.toMap());

      _nomeController.text = _contatoEdicao.nome;
      _emailController.text = _contatoEdicao.email;
      _telefoneController.text = _contatoEdicao.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
            title: Text(_contatoEdicao.nome ?? "Novo Contato"),
            centerTitle: true,
            backgroundColor: Colors.red),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('Clicou no Action Button');
            var tudoPreenchido = true;

            if (_contatoEdicao.nome == null || _contatoEdicao.nome.isEmpty) {
              tudoPreenchido = false;
              FocusScope.of(context).requestFocus(_nomeFocus);
            } else if (_contatoEdicao.telefone == null ||
                _contatoEdicao.telefone.isEmpty) {
              tudoPreenchido = false;
              FocusScope.of(context).requestFocus(_telefoneFocus);
            }

            if (tudoPreenchido) {
              Navigator.pop(context, _contatoEdicao);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _retornaFoto(_contatoEdicao.foto)),
                    )),
                onTap: () {
                  print('Clicou na foto');
                },
              ),
              TextField(
                controller: _nomeController,
                focusNode: _nomeFocus,
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (text) {
                  _registroAlterado = true;
                  setState(() {
                    _contatoEdicao.nome = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (text) {
                  _registroAlterado = true;
                  _contatoEdicao.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _telefoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                onChanged: (text) {
                  _registroAlterado = true;
                  _contatoEdicao.telefone = text;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    );
  }

  dynamic _retornaFoto(String caminho) {
    return AssetImage('images/no_photo.png');
    /*
    if (caminho == null) {
      return AssetImage('images/no_photo.png');
    } else {
      try {
        return FileImage(File(caminho));
      } catch (ex) {
        print(ex);
        return AssetImage('images/no_photo.png');
      }
    }*/
  }

  Future<bool> _requestPop() {
    if (_registroAlterado) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Deseja realmente sair da tela?'),
              content:
                  Text('Se sair da tela todas as alterações serão perdidas'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Não'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
