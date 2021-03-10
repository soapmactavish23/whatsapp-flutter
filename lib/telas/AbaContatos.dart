import 'package:flutter/material.dart';
import 'package:whatsapp/model/Contato.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  List<Contato> listaContato = [
    Contato("Ana Clara",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=bbefd076-ee5a-47f1-96ff-861fcf2a98af"),
    Contato("Pedro Silva",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=3111ffe9-2594-474e-84f5-a8bebdb234ef"),
    Contato("Marcela Almeida",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=b2566270-7ac8-4588-8768-e3c15025dc34"),
    Contato("José Renato",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=12157353-1776-49a9-b9ff-13ca38f60efe"),
    Contato("Jamilton Damasceno",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=22e59f60-3cdb-40a2-a300-14a1bc9dffd2")
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listaContato.length,
        itemBuilder: (context, indice) {
          Contato contato = listaContato[indice];
          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(contato.caminhoFoto),
            ),
            title: Text(
              contato.nome,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        });
  }
}
