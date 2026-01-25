class RappresentanteLegale {
  const RappresentanteLegale({
    required this.codFisc,
    required this.cognome,
    required this.nome,
    required this.dal,
    required this.finoAl,
  });

  final String codFisc;
  final String cognome;
  final String nome;
  final DateTime dal;
  final DateTime? finoAl;
}
