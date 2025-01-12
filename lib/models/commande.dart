class Commande {
  final String film;
  final String date;
  final String salle;
  final String image;
  final String siegesReserves;

  Commande({
    required this.film,
    required this.date,
    required this.salle,
    required this.image,
    required this.siegesReserves,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      film: json['film'] ?? '',
      date: json['date'] ?? '',
      salle: json['salle'] ?? '',
      image: json['image'] ?? '',
      siegesReserves: json['sieges_reserves']?.toString() ?? '',
    );
  }
}
