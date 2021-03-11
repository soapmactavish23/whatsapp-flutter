import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model/Conversa.dart';
import 'model/Mensagem.dart';
import 'model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  ImagePicker _picker = ImagePicker();
  bool _subindoImagem = false;

  _enviarMensagem() {
    String textoMensagem = __controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      //SALVAR CONVERSA
      _salvarConversa(mensagem);

    }
  }

  _salvarConversa(Mensagem msg){

    //Salvar conversa remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    //Salvar conversa destinatario
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();

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

  _enviarFoto() async {
    File imagemSelecionada;
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    imagemSelecionada = File(pickedFile.path);

    setState(() {
      _subindoImagem = true;
    });

    String nomeImagem = DateTime.now().microsecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child("${nomeImagem}.jpg");

    UploadTask task = arquivo.putFile(imagemSelecionada);

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (snapshot.state.index == 1) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (snapshot.state.index == 2) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    task.then((TaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";

    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    setState(() {
      _idUsuarioLogado = usuarioLogado.uid;
      _idUsuarioDestinatario = widget.contato.idUsuario;
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
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
                    prefixIcon: _subindoImagem
                        ? CircularProgressIndicator()
                        : IconButton(
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

    var stream = StreamBuilder(
      stream: db
          .collection("mensagens")
          .doc(_idUsuarioLogado)
          .collection(_idUsuarioDestinatario)
          .orderBy("dtUpdate", descending: false)
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
            if (snapshot.hasError) {
              return Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              return Expanded(
                child: ListView.builder(
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (context, indice) {
                      //recupera mensagem
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.docs.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);
                      if (_idUsuarioLogado != item["idUsuario"]) {
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
                            child: item["tipo"] == "texto"
                                ? Text(
                                    item["mensagem"],
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }
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
