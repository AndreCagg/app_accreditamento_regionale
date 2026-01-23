import 'dart:convert';

import 'package:accreditamento/model/contatto.dart';
import 'package:accreditamento/model/ente.dart';
import 'package:accreditamento/model/indirizzo.dart';
import 'package:accreditamento/model/ragione_sociale.dart';
import 'package:accreditamento/model/rappresentante_legale.dart';
import 'package:accreditamento/model/sede.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class DettagliEnte extends StatefulWidget {
  const DettagliEnte({super.key, required this.piva});

  final String piva;

  @override
  State<DettagliEnte> createState() {
    return _DettagliEnteState();
  }
}

class _DettagliEnteState extends State<DettagliEnte> {
  late Future<Ente?> _ente;
  late Future<List<Sede>?> _sedi;
  String _nomeEnte = "";

  Future<Ente?> getEnteRagSocRapp(String piva) async {
    http.Response response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/ente/${piva}"),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> m = jsonDecode(response.body);
      List<dynamic> dRagSoc = m["ragioniSociali"];
      List<dynamic> dRappLegale = m["rappresentantiLegali"];

      List<RagioneSociale> rs = [];
      List<RappresentanteLegale> rl = [];
      dRagSoc.forEach((elem) {
        rs.add(
          RagioneSociale(
            id: elem["id"] as int,
            ragioneSociale: elem["ragioneSociale"] as String,
            dal: DateTime.parse(elem["dal"] as String),
            finoAl: elem["finoAl"] as DateTime?,
          ),
        );
      });

      dRappLegale.forEach((elem) {
        rl.add(
          RappresentanteLegale(
            codFisc: elem["codFisc"] as String,
            cognome: elem["cognome"] as String,
            nome: elem["nome"] as String,
            dal: DateTime.parse(elem["dal"] as String),
            finoAl: elem["finoAl"] as DateTime?,
          ),
        );
      });

      setState(() {
        _nomeEnte = rs.first.ragioneSociale;
      });

      return Ente(piva: piva, ragioniSociali: rs, rappresentantiLegali: rl);
    }

    return null;
  }

  Future<List<Sede>?> getSediByEnte(String piva) async {
    http.Response response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/ente/${piva}/sede"),
    );

    List<Sede> sedi = [];
    if (response.statusCode == 200) {
      List<dynamic> items = jsonDecode(response.body);

      items.forEach((item) {
        Map<String, dynamic> m = item;
        Contatto? c;
        if (m["contatto"] != null) {
          c = Contatto(
            contatto: m["contatto"]["contatto"],
            idContatto: m["contatto"]["idContatto"],
          );
        }

        // indirizzo è una LISTA
        Indirizzo? i;
        if (m["indirizzo"] != null && m["indirizzo"].isNotEmpty) {
          final indirizzo = m["indirizzo"][0];
          i = Indirizzo(
            dal: DateTime.parse(indirizzo["dal"] as String),
            finoAl: indirizzo["finoAl"] as DateTime?,
            indirizzo: indirizzo["indirizzo"],
          );
        }

        sedi.add(Sede(idSede: m["idSede"], contatto: c, indirizzo: i));
      });

      return sedi;
    }

    return null;
  }

  /*Future<Ente?> getEnteInfo(String piva) async {
    Future<Ente?> e = getEnteRagSocRapp(piva);
    return e;
  }*/

  @override
  void initState() {
    super.initState();
    _ente = getEnteRagSocRapp(widget.piva);
    _sedi = getSediByEnte(widget.piva);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_nomeEnte)),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            Text("Partita IVA ${widget.piva}"),
            FutureBuilder(
              future: _ente,
              builder: (ctx, snapshot) {
                List<Widget> child = [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  child.add(CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    List<ListTile> rsTile = [];
                    List<ListTile> rlTile = [];

                    snapshot.data!.ragioniSociali.forEach((rs) {
                      rsTile.add(
                        ListTile(
                          title: Text(rs.ragioneSociale),
                          subtitle: Text(
                            "${rs.dal} - ${rs.finoAl ?? "ancora valido"}",
                          ),
                        ),
                      );
                    });

                    snapshot.data!.rappresentantiLegali.forEach((rl) {
                      rlTile.add(
                        ListTile(
                          title: Text(
                            "${rl.cognome} ${rl.nome} - ${rl.codFisc}",
                          ),
                          subtitle: Text(
                            "${rl.dal} - ${rl.finoAl ?? "ancora valido"}",
                          ),
                        ),
                      );
                    });

                    child.add(
                      ExpansionTile(
                        title: Text("Ragioni Sociali"),
                        children: rsTile,
                      ),
                    );

                    child.add(
                      ExpansionTile(
                        title: Text("Rappresentanti Legali"),
                        children: rlTile,
                      ),
                    );
                  } else {
                    child.add(Text("nessun ente"));
                  }
                }

                return Center(child: Column(children: child));
              },
            ),

            FutureBuilder(
              future: _sedi,
              builder: (ctx, snapshot) {
                List<Widget> children = [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  children.add(CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    List<Sede>? sediFuture = snapshot.data;
                    List<ListTile> sedi = [];

                    if (sediFuture != null) {
                      sediFuture.forEach((sede) {
                        if (sede.indirizzo != null) {
                          sedi.add(
                            ListTile(
                              title: Text(sede.indirizzo!.indirizzo),
                              subtitle: Text(
                                "${sede.indirizzo!.dal} - ${sede.indirizzo!.finoAl ?? "ancora valido"}",
                              ),
                            ),
                          );
                        }
                      });

                      children.add(
                        ExpansionTile(title: Text("Sedi"), children: sedi),
                      );
                    }
                  }
                }

                return Center(child: Column(children: children));
              },
            ),
          ],
        ),
      ),
    );
  }
}
