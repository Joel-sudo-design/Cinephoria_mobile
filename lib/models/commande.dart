class Commande {
  final String cinema;
  final String film;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String salle;
  final String image;
  final String siegesReserves;

  Commande({
    required this.cinema,
    required this.film,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.salle,
    required this.image,
    required this.siegesReserves,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      cinema: json['cinema']?.toString() ?? '',
      film: json['film']?.toString() ?? '',
      date: json['date'] ?? '',
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      salle: json['salle']?.toString() ?? '',
      image: json['image'] ?? '',
      siegesReserves: json['sieges_reserves']?.toString() ?? '',
    );
  }
}
