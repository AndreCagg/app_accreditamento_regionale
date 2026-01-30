import 'dart:convert';

import 'package:accreditamento/api/api_client.dart';
import 'package:accreditamento/model/pratica.dart';
import 'package:accreditamento/screen/pratica_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final api = ApiClient(baseUrl: "http://10.0.2.2:8080/api/v1.0");

class PraticheDisponibili extends StatefulWidget {
  const PraticheDisponibili({super.key});

  @override
  State<PraticheDisponibili> createState() {
    return _PraticheDisponibiliState();
  }
}

class _PraticheDisponibiliState extends State<PraticheDisponibili> {
  late Future<List<Pratica>?> pratiche;
  Future<List<Pratica>?> getPratiche() async {
    /*http.Response response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/pratica"),
    );*/

    http.Response response = await api.get("/pratica");

    if (response.statusCode == 200) {
      List<dynamic> decoded = jsonDecode(response.body);
      List<Pratica> pratiche = [];

      decoded.forEach((d) {
        pratiche.add(
          Pratica(
            id: d["id"],
            descrizione: d["descrizione"],
            formazione: d["formazione"],
            idSede: d["idSede"],
            indirizzoSede: d["indirizzoSede"],
            stato: d["stato"],
            tipoPratica: d["tipoPratica"],
          ),
        );
      });

      return pratiche;
    }

    return null;
  }

  void openDetails(int id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return PraticaDetails(id: id);
        },
      ),
    );
  }

  @override
  void initState() {
    pratiche = getPratiche();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pratiche disponibili")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Center(
          child: FutureBuilder(
            future: pratiche,
            builder: (ctx, snp) {
              late Widget child;
              if (snp.connectionState == ConnectionState.waiting) {
                child = CircularProgressIndicator();
              } else {
                if (snp.hasData) {
                  List<Pratica> praticheData = snp.data!;

                  child = ListView.builder(
                    itemCount: praticheData.length,
                    itemBuilder: (ctx, idx) {
                      return ListTile(
                        onTap: () {
                          openDetails(praticheData[idx].id);
                        },
                        leading: Icon(Icons.document_scanner_outlined),
                        title: Text(praticheData[idx].formazione),
                        subtitle: Text(
                          "prot: ${praticheData[idx].id}\n${praticheData[idx].tipoPratica} - ${praticheData[idx].stato}\nSede: ${praticheData[idx].indirizzoSede}\nNote: ${praticheData[idx].descrizione}",
                        ),
                      );
                    },
                  );
                } else {
                  child = Text("Nessuna pratica disponibile");
                }
              }

              return child;
            },
          ),
        ),
      ),
    );
  }
}
