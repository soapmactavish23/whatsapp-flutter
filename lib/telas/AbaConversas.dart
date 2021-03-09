import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  List<Conversa> listaConversa = [
    Conversa(
      "Ana Clara",
      "Olá tudo bem?",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=bbefd076-ee5a-47f1-96ff-861fcf2a98af"
    ),
    Conversa(
      "Pedro Silva",
      "Me manda o nome daquela série que falamos!",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=3111ffe9-2594-474e-84f5-a8bebdb234ef"
    ),
    Conversa(
      "Marcela Almeida",
      "Oi bb",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=b2566270-7ac8-4588-8768-e3c15025dc34"
    ),
    Conversa(
      "José Renato",
      "Não vai acreditar no que tenho que te contar...",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=12157353-1776-49a9-b9ff-13ca38f60efe"
    ),
    Conversa(
      "Jamilton Damasceno",
      "Curso Novo!! Depois dá uma olhada!!!",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-flutter-57a34.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=22e59f60-3cdb-40a2-a300-14a1bc9dffd2"
    )
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listaConversa.length,
        itemBuilder: (context, indice){
          Conversa conversa = listaConversa[indice];

          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(conversa.caminhoFoto),
            ),
            title: Text(
              conversa.nome,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            subtitle: Text(
              conversa.mensagem,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14
              ),
            ),
          );

        }
    );
  }
}
