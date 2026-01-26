class Accreditamento {
  const Accreditamento({
    required this.id,
    required this.dataInizio,
    required this.dataScadenza,
    required this.idPratica,
  });

  final int id;
  final DateTime dataInizio;
  final DateTime dataScadenza;
  final int idPratica;
}
