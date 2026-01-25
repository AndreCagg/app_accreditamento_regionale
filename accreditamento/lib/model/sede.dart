import 'package:accreditamento/model/contatto.dart';
import 'package:accreditamento/model/indirizzo.dart';

class Sede {
  const Sede({
    required this.idSede,
    required this.contatto,
    required this.indirizzo,
  });

  final int idSede;
  final Contatto? contatto;
  final Indirizzo? indirizzo;
}
