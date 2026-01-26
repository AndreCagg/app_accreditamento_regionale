import 'package:accreditamento/model/accreditamento.dart';
import 'package:accreditamento/model/pratica.dart';
import 'package:accreditamento/model/ragione_sociale.dart';
import 'package:accreditamento/model/rappresentante_legale.dart';
import 'package:accreditamento/model/sede.dart';

class EnteDetails {
  const EnteDetails({
    required this.piva,
    required this.ragioniSociali,
    required this.rappresentantiLegali,
    required this.sedi,
    required this.pratiche,
    required this.accreditamenti,
  });

  final String piva;
  final List<RagioneSociale> ragioniSociali;
  final List<RappresentanteLegale> rappresentantiLegali;
  final List<Sede>? sedi;
  final List<Pratica>? pratiche;
  final List<Accreditamento>? accreditamenti;
}
