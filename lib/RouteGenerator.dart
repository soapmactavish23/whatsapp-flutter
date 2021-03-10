import 'package:flutter/material.dart';

import 'Cadastro.dart';
import 'Configuracoes.dart';
import 'Home.dart';
import 'Login.dart';

class RouteGenerator{

  static Route<dynamic> generateRoute(RouteSettings settings){

    switch(settings.name){

      case "/":
        return MaterialPageRoute(
            builder: (context) => Login()
        );
        break;
      case "/login":
        return MaterialPageRoute(
            builder: (context) => Login()
        );
        break;
      case "/cadastro":
        return MaterialPageRoute(
            builder: (context) => Cadastro()
        );
        break;
      case "/home":
        return MaterialPageRoute(
            builder: (context) => Home()
        );
        break;
      case "/configuracoes":
        return MaterialPageRoute(
            builder: (context) => Configuracoes()
        );
        break;
      default:
        _erroRota();
    }

  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(builder: (context){
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada"),
        ),
        body: Center(
          child: Text("Tela não encontrada"),
        ),
      );
    });
  }

}