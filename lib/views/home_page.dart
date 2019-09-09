import 'package:flutter/material.dart';
import 'package:agenda_contos/helpers/contato_helper.dart';
import 'package:agenda_contos/views/contato_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io';

enum Oerdenacao { Az, Za }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContatoHelper helper = new ContatoHelper();
  var contatos = new List<Contato>();

  @override
  void initState() {
    super.initState();

    _listarTodosContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Oerdenacao>(
            itemBuilder: (context) => <PopupMenuEntry<Oerdenacao>>[
              const PopupMenuItem<Oerdenacao>(
                child: Text('Ordenar de A-z'),
                value: Oerdenacao.Az,
              ),
              const PopupMenuItem<Oerdenacao>(
                child: Text('Ordenar de Z-a'),
                value: Oerdenacao.Za,
              )
            ],
            onSelected: _aoDefinirOrdenacao,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Clicou no floatbutton');
          _chamaTelaContatoPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contatos.length,
        itemBuilder: (context, index) {
          return _contatoCard(context, index);
        },
      ),
    );
  }

  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _retornaFoto(contatos[index].foto)),
                  )),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contatos[index].nome ?? '',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contatos[index].email ?? '',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      contatos[index].telefone ?? '',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        debugPrint('Clicou no onTap');
        _mostrarOpcoes(context, index);
      },
    );
  }

  dynamic _retornaFoto(String caminho) {
    //return AssetImage('images/no_photo.png');
    if (caminho == null) {
      return AssetImage('images/no_photo.png');
    } else {
      try {
        return FileImage(File(caminho));
      } catch (ex) {
        print(ex);
        return AssetImage('images/no_photo.png');
      }
    }
  }

  void _listarTodosContatos() {
    helper.selecionarTodos().then((onValue) {
      setState(() {
        contatos = onValue;
      });
    });
  }

  void _chamaTelaContatoPage({Contato contato}) async {
    final contatoMovimentado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new ContatoPage(
                  contato: contato,
                )));

    if (contatoMovimentado != null) {
      if (contato != null) {
        await helper.alterar(contatoMovimentado);
      } else {
        await helper.incluir(contatoMovimentado);
      }
      _listarTodosContatos();
    }
  }

  void _mostrarOpcoes(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {
              print('Ação ao fechar');
            },
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          'Ligar',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          print('Vc clicou no botão Ligar');
                          launch('tel:${contatos[index].telefone}');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          'Editar',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          print('Vc clicou no botão Editar');
                          Navigator.pop(context);
                          _chamaTelaContatoPage(contato: contatos[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          print('Vc clicou no botão Excluir');
                          helper.excluir(contatos[index].id);
                          setState(() {
                            contatos.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  void _aoDefinirOrdenacao(Oerdenacao result){
    switch (result) {
      case Oerdenacao.Az:
        contatos.sort((a,b){
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case Oerdenacao.Za:
        contatos.sort((a,b){
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
      default:
    }
    setState(() {
      
    });
  }
}
