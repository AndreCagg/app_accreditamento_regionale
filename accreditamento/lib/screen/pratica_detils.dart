import 'dart:convert';

import 'package:accreditamento/model/requisiti_accreditamento.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class PraticaDetails extends StatefulWidget {
  const PraticaDetails({super.key, required this.id});
  final int id;

  @override
  State<PraticaDetails> createState() {
    return _PraticaDetailsState();
  }
}

class _PraticaDetailsState extends State<PraticaDetails> {
  late Future<List<RequisitiAccreditamento>?> reqs;

  Future<List<RequisitiAccreditamento>?> getRequisiti(int id) async {
    List<RequisitiAccreditamento> requisiti = [];

    http.Response response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/pratica/${id}/requisiti"),
    );

    if (response.statusCode == 200) {
      List<dynamic> map = jsonDecode(response.body);

      map.forEach((req) {
        requisiti.add(
          RequisitiAccreditamento(
            id: req["id"] as int,
            descrizione: req["descrizione"] as String,
            valido: req["valido"] as bool,
          ),
        );
      });

      return requisiti;
    }

    return null;
  }

  @override
  void initState() {
    reqs = getRequisiti(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id.toString())),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: FutureBuilder(
          future: reqs,
          builder: (ctx, snapshot) {
            late Widget child;
            List<Widget> listViewer = [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              child = CircularProgressIndicator();
            } else {
              if (snapshot.hasData) {
                List<RequisitiAccreditamento> requisiti = snapshot.data!;

                requisiti.forEach((r) {
                  listViewer.add(
                    ListTile(
                      leading: Icon(r.valido ? Icons.done : Icons.cancel),
                      title: Text("${r.descrizione}"),
                    ),
                  );
                });

                child = ListView.builder(
                  itemCount: listViewer.length,
                  itemBuilder: (ctx, idx) {
                    return listViewer[idx];
                  },
                );
              }
            }

            return child;
          },
        ),
      ),
    );
  }
}
