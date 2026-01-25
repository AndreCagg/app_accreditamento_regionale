import 'package:accreditamento/model/ente.dart';
import 'package:accreditamento/model/sede.dart';

class EnteComplete {
  const EnteComplete({required this.ente, required this.sedi});

  final Ente? ente;
  final List<Sede>? sedi;
}
