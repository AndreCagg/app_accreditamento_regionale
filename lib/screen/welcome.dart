import 'package:accreditamento/screen/crea_ente.dart';
import 'package:accreditamento/screen/crea_rapp_legale.dart';
import 'package:accreditamento/screen/pratiche_disponibili.dart';
import 'package:flutter/material.dart';
import "package:accreditamento/screen/enti_disponibili.dart";

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  void navigate(Widget w) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return w;
        },
      ),
    );
  }

  void openPage(String page) {
    switch (page) {
      case "visualizza-enti":
        navigate(EntiDisponibili());
      case "crea-ente":
        navigate(CreaEnte());
      case "crea-rapplegale":
        navigate(CreaRappLegale());
      case "leggi-pratiche":
        navigate(PraticheDisponibili());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Benvenuto")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: 40),
          children: [
            ListTile(
              onTap: () {
                openPage("visualizza-enti");
              },
              title: Text("Visualizza enti"),
            ),
            ListTile(
              onTap: () {
                openPage("crea-ente");
              },
              title: Text("Crea ente"),
            ),
            ListTile(
              onTap: () {
                openPage("crea-rapplegale");
              },
              title: Text("Crea rappresentante legale"),
            ),
            ListTile(
              onTap: () {
                openPage("leggi-pratiche");
              },
              title: Text("Pratiche disponibili"),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Text("Utilizza il menù laterale"),
      ),
    );
  }
}
