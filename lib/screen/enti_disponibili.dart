import "dart:convert";

import "package:accreditamento/api/api_client.dart";
import "package:accreditamento/screen/dettagli_ente.dart";
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "package:accreditamento/model/enti_list.dart";

final api = ApiClient(baseUrl: "http://10.0.2.2:8080/api/v1.0");

class EntiDisponibili extends StatefulWidget {
  const EntiDisponibili({super.key});
  @override
  State<EntiDisponibili> createState() {
    return _EntiDisponibiliState();
  }
}

class _EntiDisponibiliState extends State<EntiDisponibili> {
  late Future<List<EntiList>?> _future;

  Future<List<EntiList>?> getEnti() async {
    /*http.Response r = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/ente"),
    );*/

    http.Response r = await api.get("/ente");

    int statusCode = r.statusCode;
    print("STATUS: ${statusCode}");
    print(r.body);
    List<EntiList> ret = [];

    if (statusCode == 200) {
      List<dynamic> list = jsonDecode(r.body);
      list.forEach((e) {
        ret.add(
          EntiList(
            piva: e["piva"] as String,
            ragioneSociale: e["ragioneSociale"] == null
                ? "N/A"
                : e["ragioneSociale"] as String,
          ),
        );
      });

      return ret;
    }

    return null;
  }

  void openDettagliEnte(String piva) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DettagliEnte(piva: piva);
        },
      ),
    );
  }

  @override
  void initState() {
    _future = getEnti();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enti disponibili")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            List<Widget> children = [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              children = [Center(child: CircularProgressIndicator())];
            } else {
              if (snapshot.hasData) {
                children = snapshot.data!.map((ente) {
                  return ListTile(
                    onTap: () {
                      openDettagliEnte(ente.piva);
                    },
                    leading: Icon(Icons.school),
                    title: Text(ente.ragioneSociale),
                    dense: false,
                  );
                }).toList();
              } else {
                children = [Text("Nessun ente disponibile")];
              }
            }

            return ListView.builder(
              itemCount: children.length,
              itemBuilder: (ctx, idx) {
                return children[idx];
              },
            );
          },
        ),
      ),
    );
  }
}
