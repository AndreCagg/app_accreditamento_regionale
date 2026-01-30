import 'package:accreditamento/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final api = ApiClient(baseUrl: "http://10.0.2.2:8080/api/v1.0");

class CreaRappLegale extends StatefulWidget {
  const CreaRappLegale({super.key});

  @override
  State<CreaRappLegale> createState() {
    return _CreaRappLegaleState();
  }
}

class _CreaRappLegaleState extends State<CreaRappLegale> {
  String codfisc = "";
  String nome = "";
  String cognome = "";
  var formkey = GlobalKey<FormState>();

  void salva() async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();

      http.Response response = await api.post("/rapplegale", {
        "codFisc": codfisc,
        "nome": nome,
        "cognome": cognome,
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rappresentante legale inserito")),
        );
      } else {
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Impossibile inserire il rappresentante legale, http ${response.statusCode}",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rappresentante legale")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  if (newValue != null) {
                    codfisc = newValue;
                  }
                },
                validator: (value) {
                  if (value != null && value != "") {
                    return "Il codice fiscale non puo essere vuoto";
                  }
                },
                decoration: InputDecoration(label: Text("Codice fiscale")),
              ),
              TextFormField(
                onSaved: (newValue) {
                  if (newValue != null) {
                    nome = newValue;
                  }
                },
                validator: (value) {
                  if (value != null && value != "") {
                    return "Il nome non puo essere vuoto";
                  }
                },
                decoration: InputDecoration(label: Text("Nome")),
              ),
              TextFormField(
                onSaved: (newValue) {
                  if (newValue != null) {
                    cognome = newValue;
                  }
                },
                validator: (value) {
                  if (value != null && value != "") {
                    return "Il cognome non puo essere vuoto";
                  }
                },
                decoration: InputDecoration(label: Text("Cognome")),
              ),
              FilledButton(onPressed: () {}, child: Text("Salva")),
            ],
          ),
        ),
      ),
    );
  }
}
