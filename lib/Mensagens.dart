import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model/Mensagem.dart';
import 'model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController __controllerMensagem = TextEditingController();
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;
  FirebaseFirestore db = FirebaseFirestore.instance;

  _enviarMensagem() {
    String textoMensagem = __controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    __controllerMensagem.clear();
  }

  _enviarFoto() {}

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;

    _idUsuarioDestinatario = widget.contato.idUsuario;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    List<String> listaMensagens = [
      "Olá meu amigo, tudo bem?",
      "Tudo Ótimo!!! e contigo?",
      "Estou muito bem",
      "Que Bom"
    ];

    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: __controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _enviarFoto,
                    )),
              ),
            ),
          ),
          FloatingActionButton(
              backgroundColor: Color(0xff075E54),
              child: Icon(Icons.send, color: Colors.white),
              mini: true,
              onPressed: _enviarMensagem)
        ],
      ),
    );

    var listView = Expanded(
        child: ListView.builder(
            itemCount: listaMensagens.length,
            itemBuilder: (context, indice) {
              double larguraContainer = MediaQuery.of(context).size.width * 0.8;

              Alignment alinhamento = Alignment.centerRight;
              Color cor = Color(0xffd2ffa5);
              if (indice % 2 == 0) {
                alinhamento = Alignment.centerLeft;
                cor = Colors.white;
              }

              return Align(
                alignment: alinhamento,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Container(
                    width: larguraContainer,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: cor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Text(
                      listaMensagens[indice],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            }));

    var stream = StreamBuilder(
      stream: db
          .collection("mensagens")
          .doc(_idUsuarioLogado)
          .collection(_idUsuarioDestinatario)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:

            QuerySnapshot querySnapshot = snapshot.data;
            if (snapshot.hasError) {
              return Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (context, indice) {

                      //recupera mensagem
                      List<DocumentSnapshot> mensagens = querySnapshot.docs.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);
                      if ( _idUsuarioLogado != item["idUsuario"] ) {
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                BorderRadius.all(Radius.circular(8))),
                            child: Text(
                              item["mensagem"],
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }

        /*switch(snapshot.connectionState){
          case ConnectionState.none:
            break;
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
            break;
          case ConnectionState.done:

            QuerySnapshot querySnapshot = snapshot.data;

            if(snapshot.hasError){
              return Expanded(child: Text("Erro ao carregar os dados!"));
            }else{
              return Expanded(child: ListView.builder(
                itemCount: querySnapshot.docs.length,
                  itemBuilder: (context, indice){
                    List<DocumentSnapshot> mensagens = querySnapshot.docs.toList();
                    DocumentSnapshot item = mensagens[indice];

                    double larguraContainer = MediaQuery.of(context).size.width * 0.8;

                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = Color(0xffd2ffa5);
                    if(_idUsuarioLogado != item["idUsuario"]){
                      alinhamento = Alignment.centerLeft;
                      cor = Colors.white;
                    }

                    return Align(
                      alignment: alinhamento,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Container(
                          width: larguraContainer,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cor,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Text(item["mensagem"], style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    );

                  },
                )
              );
            }

            break;
        }*/
      },
    );

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem)
                    : null,
              ),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(widget.contato.nome),
              )
            ],
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("imagens/bg.png"), fit: BoxFit.cover)),
          child: SafeArea(
              child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                stream,
                caixaMensagem,
              ],
            ),
          )),
        ));
  }
}
