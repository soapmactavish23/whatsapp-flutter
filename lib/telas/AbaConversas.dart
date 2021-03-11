import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> _listaConversa = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _idUsuarioLogado;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();

    Conversa conversa = new Conversa();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá, tudo bem?";
    conversa.caminhoFoto =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=bbefd076-ee5a-47f1-96ff-861fcf2a98af";

    _listaConversa.add(conversa);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    setState(() {
      _idUsuarioLogado = usuarioLogado.uid;
    });
    _adicionarListenerConversas();
  }

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .doc(_idUsuarioLogado)
        .collection("ultima_conversa").snapshots();

    stream.listen((dados) {
      setState(() {
        _controller.add(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando conversas..."),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Erro ao carregar os dados!");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.docs.length == 0) {
                return Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              return ListView.builder(
                  itemCount: _listaConversa.length,
                  itemBuilder: (context, indice) {

                    //recupera mensagem
                    List<DocumentSnapshot> conversas =
                    querySnapshot.docs.toList();
                    DocumentSnapshot item = conversas[indice];

                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(item["caminhoFoto"]),
                      ),
                      title: Text(
                        item["nome"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        item["tipoMensagem"] == "texto" ? item["mensagem"]: "Imagem...",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    );
                  });
            }
        }
      },
    );
  }
}
