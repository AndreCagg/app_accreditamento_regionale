import 'dart:convert';

import 'package:accreditamento/model/contatto.dart';
import 'package:accreditamento/model/indirizzo.dart';
import 'package:accreditamento/model/pratica_details_model.dart';
import 'package:accreditamento/model/requisiti_accreditamento.dart';
import 'package:accreditamento/model/sede.dart';
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
  late Future<PraticaDetailsModel?> pratica;

  void aggiornaPratica(String action) async {
    http.Response response = await http.patch(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/pratica/${action}/${widget.id}"),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pratica aggiornata")));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore aggiornamento pratica, ${response.statusCode}"),
        ),
      );
    }
  }

  Future<PraticaDetailsModel?> getRequisiti(int id) async {
    List<RequisitiAccreditamento> requisiti = [];

    http.Response response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/pratica/${id}"),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      List<dynamic> requisitiObj = map["requisiti"];

      requisitiObj.forEach((req) {
        requisiti.add(
          RequisitiAccreditamento(
            id: req["id"] as int,
            descrizione: req["descrizione"] as String,
            valido: req["valido"] as bool,
          ),
        );
      });

      PraticaDetailsModel p = PraticaDetailsModel(
        id: map["id"] as int,
        formazione: map["formazione"] as String,
        descrizione: map["descrizione"] as String,
        idSede: map["idSede"] as int,
        sede: Sede(
          idSede: map["idSede"] as int,
          contatto: Contatto(
            contatto: map["sede"]["contatto"]["contatto"] as String,
            idContatto: map["sede"]["contatto"]["idContatto"] as int,
          ),
          indirizzo: Indirizzo(
            dal: DateTime.parse(map["sede"]["indirizzo"]["dal"]),
            finoAl: map["sede"]["indirizzo"]["finoAl"] != null
                ? DateTime.parse(map["sede"]["indirizzo"]["finoAl"])
                : null,
            indirizzo: map["sede"]["indirizzo"]["indirizzo"] as String,
          ),
        ),
        stato: map["stato"] as String,
        tipoPratica: map["tipoPratica"] as String,
        requisiti: requisiti,
      );

      return p;
    }

    return null;
  }

  @override
  void initState() {
    pratica = getRequisiti(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id.toString())),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: FutureBuilder(
          future: pratica,
          builder: (ctx, snapshot) {
            late Widget child;
            List<Widget> listViewer = [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              child = CircularProgressIndicator();
            } else {
              if (snapshot.hasData) {
                PraticaDetailsModel details = snapshot.data!;
                List<RequisitiAccreditamento> requisiti = details.requisiti!;

                requisiti.forEach((r) {
                  listViewer.add(
                    ListTile(
                      leading: Icon(r.valido ? Icons.done : Icons.cancel),
                      title: Text("${r.descrizione}"),
                    ),
                  );
                });

                List<FilledButton> actions = [];

                switch (details.stato) {
                  case "Inviata":
                    actions.add(
                      FilledButton(
                        onPressed: () {
                          aggiornaPratica("istruisci");
                        },
                        child: Text("Avvia istruttoria"),
                      ),
                    );
                  case "In istruttoria":
                    actions.addAll([
                      FilledButton(
                        onPressed: () {
                          aggiornaPratica("approva");
                        },
                        child: Text("Approva"),
                      ),
                      FilledButton(
                        onPressed: () {
                          aggiornaPratica("respingi");
                        },
                        child: Text("Respingi"),
                      ),
                    ]);
                  case "Approvata":
                    actions.add(
                      FilledButton(
                        onPressed: () {
                          aggiornaPratica("revoca");
                        },
                        child: Text("Revoca"),
                      ),
                    );
                  case "Respinta":
                    actions.add(
                      FilledButton(
                        onPressed: () {
                          aggiornaPratica("approva");
                        },
                        child: Text("Approva"),
                      ),
                    );
                  case "Revocata":
                    actions.add(
                      FilledButton(
                        onPressed: () {
                          aggiornaPratica("approva");
                        },
                        child: Text("Approva"),
                      ),
                    );
                }

                child = Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.notes),
                        title: Text(details.descrizione),
                      ),
                      ListTile(
                        leading: Icon(Icons.school),
                        title: Text(details.formazione),
                      ),
                      ListTile(
                        leading: Icon(Icons.stream_outlined),
                        title: Text(details.stato),
                      ),
                      ListTile(
                        leading: Icon(Icons.category),
                        title: Text(details.tipoPratica),
                      ),
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text(
                          "Sede: ${details.sede.indirizzo != null ? details.sede.indirizzo!.indirizzo : details.sede.idSede.toString()}",
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Requisiti"),
                      SizedBox(height: 15),
                      Expanded(
                        child: ListView.builder(
                          itemCount: listViewer.length,
                          itemBuilder: (ctx, idx) {
                            return listViewer[idx];
                          },
                        ),
                      ),
                      ...actions,
                    ],
                  ),
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
