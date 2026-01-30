import 'dart:convert';

import 'package:accreditamento/api/api_client.dart';
import 'package:accreditamento/model/accreditamento.dart';
import 'package:accreditamento/model/contatto.dart';
import 'package:accreditamento/model/ente.dart';
import 'package:accreditamento/model/ente_details.dart';
import 'package:accreditamento/model/indirizzo.dart';
import 'package:accreditamento/model/pratica.dart';
import 'package:accreditamento/model/ragione_sociale.dart';
import 'package:accreditamento/model/rappresentante_legale.dart';
import 'package:accreditamento/model/sede.dart';
import 'package:accreditamento/screen/pratica_details.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';

final api = ApiClient(baseUrl: "http://10.0.2.2:8080/api/v1.0");

class DettagliEnte extends StatefulWidget {
  const DettagliEnte({super.key, required this.piva});

  final String piva;

  @override
  State<DettagliEnte> createState() {
    return _DettagliEnteState();
  }
}

class _DettagliEnteState extends State<DettagliEnte> {
  late Future<EnteDetails?> _ente;
  String _nomeEnte = "";

  Future<EnteDetails?> getEnteDetails() async {
    /*http.Response response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/v1.0/ente/details/${widget.piva}"),
    );*/

    http.Response response = await api.get("/ente/details/${widget.piva}");

    if (response.statusCode == 200) {
      Map<String, dynamic> raw = jsonDecode(response.body);

      List<dynamic> dRagioniSociali = raw["ragioniSociali"];
      List<dynamic> dRappresentantiLegali = raw["rappresentantiLegali"];
      List<dynamic> dSedi = raw["sedi"];
      List<dynamic> dPratiche = raw["pratiche"];
      List<dynamic> dAccreditamenti = raw["accreditamenti"];

      List<RagioneSociale> ragioniSociali = [];
      dRagioniSociali.forEach((r) {
        if (r != null) {
          ragioniSociali.add(
            RagioneSociale(
              id: r["id"] as int,
              ragioneSociale: r["ragioneSociale"] as String,
              dal: DateTime.parse(r["dal"]),
              finoAl: r["finoAl"] != null ? DateTime.parse(r["finoAl"]) : null,
            ),
          );
        }
      });

      List<RappresentanteLegale> rappresentantiLegali = [];
      dRappresentantiLegali.forEach((r) {
        if (r != null) {
          rappresentantiLegali.add(
            RappresentanteLegale(
              codFisc: r["codFisc"] as String,
              cognome: r["cognome"] as String,
              nome: r["nome"] as String,
              dal: DateTime.parse(r["dal"]),
              finoAl: r["finoAl"] != null ? DateTime.parse(r["finoAl"]) : null,
            ),
          );
        }
      });

      List<Sede> sedi = [];
      dSedi.forEach((s) {
        if (s != null) {
          Contatto? c;
          Indirizzo? i;
          if (s["contatto"] != null) {
            c = Contatto(
              contatto: s["contatto"]["contatto"] as String,
              idContatto: s["contatto"]["idContatto"] as int,
            );
          }

          if (s["indirizzo"] != null) {
            i = Indirizzo(
              dal: DateTime.parse(s["indirizzo"]["dal"]),
              finoAl: s["indirizzo"]["finoAl"] != null
                  ? DateTime.parse(s["indirizzo"]["finoAl"])
                  : null,
              indirizzo: s["indirizzo"]["indirizzo"] as String,
            );
          }

          sedi.add(Sede(contatto: c, indirizzo: i, idSede: s["idSede"]));
        }
      });

      List<Pratica> pratiche = [];
      dPratiche.forEach((p) {
        pratiche.add(
          Pratica(
            id: p["id"] as int,
            descrizione: p["descrizione"] as String,
            formazione: p["formazione"] as String,
            idSede: p["idSede"] as int,
            stato: p["stato"] as String,
            indirizzoSede: "",
            tipoPratica: p["tipoPratica"] as String,
          ),
        );
      });

      List<Accreditamento> accreditamenti = [];
      dAccreditamenti.forEach((a) {
        accreditamenti.add(
          Accreditamento(
            id: a["id"] as int,
            dataInizio: DateTime.parse(a["dataInizio"]),
            dataScadenza: DateTime.parse(a["dataScadenza"]),
            idPratica: a["idPratica"] as int,
          ),
        );
      });

      EnteDetails e = EnteDetails(
        piva: widget.piva,
        ragioniSociali: ragioniSociali,
        rappresentantiLegali: rappresentantiLegali,
        sedi: sedi,
        pratiche: pratiche,
        accreditamenti: accreditamenti,
      );
      return e;
    }

    return null;
  }

  void exploraPratica(int id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PraticaDetails(id: id);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ente = getEnteDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_nomeEnte)),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: FutureBuilder(
          future: _ente,
          builder: (context, snapshot) {
            List<Widget> children = [];
            List<Widget> praticheElem = [];
            List<Widget> accreditamentiElem = [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              children.add(CircularProgressIndicator());
            } else {
              if (snapshot.hasData) {
                EnteDetails e = snapshot.data!;

                List<RagioneSociale> ragioniSociali = e.ragioniSociali;
                List<Widget> wRagioniSociali = [];

                ragioniSociali.forEach((rs) {
                  if (rs.ragioneSociale != null) {
                    wRagioniSociali.add(
                      ListTile(
                        leading: Icon(Icons.donut_large_rounded),
                        title: Text(rs.ragioneSociale),
                        subtitle: Text(
                          "${DateFormat("dd/MM/yyyy").format(rs.dal)} - ${rs.finoAl != null ? DateFormat("dd/MM/yyyy").format(rs.finoAl!) : "ancora vigente"}",
                        ),
                      ),
                    );
                  }
                });

                children.add(
                  ExpansionTile(
                    title: Text("Ragioni sociali"),
                    children: wRagioniSociali,
                  ),
                );

                List<RappresentanteLegale> rappresentantiLegali =
                    e.rappresentantiLegali;
                List<Widget> wRappresentantiLegali = [];

                rappresentantiLegali.forEach((rl) {
                  wRappresentantiLegali.add(
                    ListTile(
                      leading: Icon(Icons.donut_large_rounded),
                      title: Text("${rl.codFisc} - ${rl.cognome} ${rl.nome}"),
                      subtitle: Text(
                        "${DateFormat("dd/MM/yyyy").format(rl.dal)} - ${rl.finoAl != null ? DateFormat("dd/MM/yyyy").format(rl.finoAl!) : "ancora vigente"}",
                      ),
                    ),
                  );
                });

                children.add(
                  ExpansionTile(
                    title: Text("Rappresentanti legali"),
                    children: wRappresentantiLegali,
                  ),
                );

                if (e.sedi != null) {
                  List<Sede> sedi = e.sedi!;
                  List<Widget> wSedi = [];

                  sedi.forEach((s) {
                    if (s.indirizzo != null) {
                      if (s.contatto != null) {
                        wSedi.add(
                          ListTile(
                            leading: Icon(Icons.donut_large_rounded),
                            title: Text("${s.indirizzo!.indirizzo}"),
                            subtitle: Text("${s.contatto!.contatto}"),
                          ),
                        );
                      } else {
                        wSedi.add(
                          ListTile(
                            leading: Icon(Icons.donut_large_rounded),
                            title: Text("${s.indirizzo!.indirizzo}"),
                          ),
                        );
                      }
                    }
                  });

                  children.add(
                    ExpansionTile(title: Text("Sedi"), children: wSedi),
                  );
                }

                if (e.pratiche != null) {
                  List<Pratica> pratiche = e.pratiche!;

                  pratiche.forEach((p) {
                    praticheElem.add(
                      ListTile(
                        leading: Icon(Icons.file_copy),
                        title: Text("Prot: ${p.id}"),
                        subtitle: Text(
                          "${p.formazione}\n${p.stato}\n\nNote: ${p.descrizione}",
                        ),
                      ),
                    );
                  });
                }

                if (e.accreditamenti != null) {
                  List<Accreditamento> accreditamenti = e.accreditamenti!;
                  accreditamenti.forEach((acc) {
                    accreditamentiElem.add(
                      ListTile(
                        leading: Icon(Icons.verified),
                        title: Text(
                          "Prot: ${acc.id}\nPratica ${acc.idPratica}",
                        ),
                        subtitle: Text(
                          "${DateFormat("dd/MM/yyyy").format(acc.dataInizio)} - ${DateFormat("dd/MM/yyyy").format(acc.dataScadenza)}",
                        ),
                      ),
                    );
                  });
                }
              }
            }

            return Column(
              children: [
                Text("Partita IVA ${widget.piva}"),
                SizedBox(height: 50),

                ...children,

                SizedBox(height: 50),

                Text("Pratiche"),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: praticheElem.length,
                    itemBuilder: (ctx, idx) {
                      return GestureDetector(
                        onTap: () {
                          exploraPratica(snapshot.data!.pratiche![idx].id);
                        },
                        child: praticheElem[idx],
                      );
                    },
                  ),
                ),

                Text("Accreditamenti"),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: accreditamentiElem.length,
                    itemBuilder: (ctx, idx) {
                      return accreditamentiElem[idx];
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
