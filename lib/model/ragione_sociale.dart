class RagioneSociale {
  const RagioneSociale({
    required this.id,
    required this.ragioneSociale,
    required this.dal,
    required this.finoAl,
  });

  final int id;
  final String ragioneSociale;
  final DateTime dal;
  final DateTime? finoAl;
}
