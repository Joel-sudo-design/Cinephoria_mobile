class Commande {
  final String film;
  final String image;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String cinema;
  final int salle;
  final List<dynamic> siegesReserves;
  final String qrCode;

  Commande({
    required this.film,
    required this.image,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.cinema,
    required this.salle,
    required this.siegesReserves,
    required this.qrCode,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      film: json['film'] ?? '',
      image: json['image'] ?? '',
      date: json['date'] ?? '',
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      cinema: json['cinema'] ?? '',
      salle: json['salle'] ?? 0,
      siegesReserves: json['sieges_reserves'] ?? [],
      qrCode: json['qrCode'] ?? '',
    );
  }
}
