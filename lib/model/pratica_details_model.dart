import 'package:accreditamento/model/pratica.dart';
import 'package:accreditamento/model/requisiti_accreditamento.dart';
import 'package:accreditamento/model/sede.dart';

class PraticaDetailsModel extends Pratica {
  const PraticaDetailsModel({
    required super.id,
    required super.formazione,
    required super.descrizione,
    required super.idSede,
    required super.indirizzoSede,
    required super.stato,
    required super.tipoPratica,
    required this.sede,
    required this.requisiti,
  });

  final List<RequisitiAccreditamento> requisiti;
  final Sede sede;
}
