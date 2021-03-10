import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/telas/AbaContatos.dart';
import 'package:whatsapp/telas/AbaConversas.dart';
import 'package:whatsapp/Login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> itensMenu = ["Configurações", "Deslogar"];

  Future _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    _tabController = TabController(length: 2, vsync: this);
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch(itemEscolhido){
      case "Configurações":
        print("Configurações");
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;

    }
  }

  _deslogarUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushReplacementNamed(context, "/login");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsApp"),
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[Tab(text: "Conversas"), Tab(text: "Contatos")],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[AbaConversas(), AbaContatos()],
      ),
    );
  }
}
