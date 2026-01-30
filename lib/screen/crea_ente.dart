import 'dart:convert';
import 'package:accreditamento/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:accreditamento/model/rappresentante_legale_short.dart';

final api = ApiClient(baseUrl: "http://10.0.2.2:8080/api/v1.0");

class CreaEnte extends StatefulWidget {
  const CreaEnte({super.key});
  @override
  State<CreaEnte> createState() => _CreaEnteState();
}

class _CreaEnteState extends State<CreaEnte> {
  late Future<List<RappresentanteLegaleShort>> rappLegaliFuture;
  List<String?> selectedRappLegali = [];
  String piva = "";
  String ragSoc = "";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    rappLegaliFuture = fetchRappLegali();
    // aggiungo un dropdown iniziale
    selectedRappLegali.add(null);
  }

  Future<List<RappresentanteLegaleShort>> fetchRappLegali() async {
    /*final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/rapplegale"),
    );*/

    http.Response response = await api.get("/rapplegale");

    if (response.statusCode != 200) return [];

    List<dynamic> data = jsonDecode(response.body);
    return data
        .map(
          (r) => RappresentanteLegaleShort(
            codfisc: r["codFiscRappresentante"],
            nome: r["nome"],
            cognome: r["cognome"],
          ),
        )
        .toList();
  }

  Widget buildRappLegaleDropdown(
    int index,
    List<RappresentanteLegaleShort> list,
  ) {
    selectedRappLegali[index] ??= list.first.codfisc;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: selectedRappLegali[index],
        decoration: InputDecoration(
          labelText: "Rappresentante legale ${index + 1}",
          border: OutlineInputBorder(),
        ),
        items: list
            .map(
              (s) => DropdownMenuItem(
                value: s.codfisc,
                child: Text(
                  "${s.cognome.toUpperCase()} ${s.nome.toUpperCase()}",
                ),
              ),
            )
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedRappLegali[index] = val;
          });
        },
        onSaved: (val) {
          selectedRappLegali[index] = val;
        },
      ),
    );
  }

  void salvaEnte() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    List<String?> rappToSend = selectedRappLegali;

    /*http.Response response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/ente"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "piva": piva,
        "ragioneSociale": ragSoc,
        "rappLegali": selectedRappLegali,
      }),
    );*/

    http.Response response = await api.post("/ente", {
      "piva": piva,
      "ragioneSociale": ragSoc,
      "rappLegali": selectedRappLegali,
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ente inserito")));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossibile inserire l'ente, http: ${response.statusCode}",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crea nuovo ente")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: FutureBuilder<List<RappresentanteLegaleShort>>(
            future: rappLegaliFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              final list = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Partita IVA",
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) => piva = v ?? "",
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Campo obbligatorio"
                          : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Ragione sociale",
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) => ragSoc = v ?? "",
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Campo obbligatorio"
                          : null,
                    ),
                    SizedBox(height: 16),

                    ...List.generate(
                      selectedRappLegali.length,
                      (i) => buildRappLegaleDropdown(i, list),
                    ),

                    SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          selectedRappLegali.add(null);
                        });
                      },
                      child: Text("Aggiungi rappresentante legale"),
                    ),
                    SizedBox(height: 20),
                    FilledButton(onPressed: salvaEnte, child: Text("Crea")),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
