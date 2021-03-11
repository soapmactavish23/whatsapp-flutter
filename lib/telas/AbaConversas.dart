import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> _listaConversa = List();

  @override
  void initState() {
    super.initState();

    Conversa conversa = new Conversa();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá, tudo bem?";
    conversa.caminhoFoto =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=bbefd076-ee5a-47f1-96ff-861fcf2a98af";

    _listaConversa.add(conversa);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _listaConversa.length,
        itemBuilder: (context, indice) {
          Conversa conversa = _listaConversa[indice];

          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(conversa.caminhoFoto),
            ),
            title: Text(
              conversa.nome,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              conversa.mensagem,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        });
  }
}
