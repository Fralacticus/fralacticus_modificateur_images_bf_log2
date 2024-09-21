/*
 * Droits d'auteur 2024 Fralacticus fralacticus@gmail.com
 * Licence zlib, voir le fichier LICENSE
 */

enum GenrePix{
  avecChunks,
  sansLignes;
}

class Metadonnees {
  // variables privées
  late final int _largeur;
  late final int _hauteur;
  late final int _adresse;
  late final GenrePix _genrePix;

  Metadonnees(String nom_fichier) {
    // ex : sprite-i_00-adr_073bb4-dim_128(8x16)-sansLignes.bmp
    // Expression régulière pour extraire les dimensions, l'adresse ROM et le genre
    final RegExp regExp = RegExp(r'adr_([a-fA-F0-9]+)-dim_\d+\((\d+)x(\d+)\)-([a-zA-Z]+)\.bmp');

    // Exécuter l'expression régulière sur la chaîne
    final match = regExp.firstMatch(nom_fichier);

    if (match != null) {
      // Récupérer les dimensions (largeur, hauteur), l'adresse ROM, et la dernière partie pour le genre
      _adresse = int.parse(match.group(1)!, radix: 16);
      _largeur = int.parse(match.group(2)!);
      _hauteur = int.parse(match.group(3)!);
      _genrePix = GenrePix.values.firstWhere(
            (e) => e.toString().split('.').last == match.group(4)!,
        orElse: () => throw ArgumentError('Genre inconnu: ${match.group(4)!}'),
      );
    }



  }

  @override
  String toString() {
    return 'Metadonnees{genrePix: $_genrePix, largeur: $_largeur, hauteur: $_hauteur, adresse: 0x${_adresse.toRadixString(16)}}';
  }

  GenrePix get genrePix => _genrePix;

  int get adresse => _adresse;

  int get hauteur => _hauteur;

  int get largeur => _largeur;
}