import 'package:accreditamento/model/ragione_sociale.dart';
import 'package:accreditamento/model/rappresentante_legale.dart';

class Ente {
  const Ente({
    required this.piva,
    required this.ragioniSociali,
    required this.rappresentantiLegali,
  });

  final String piva;
  final List<RagioneSociale> ragioniSociali;
  final List<RappresentanteLegale> rappresentantiLegali;
}
