/*
 * Droits d'auteur 2024 Fralacticus fralacticus@gmail.com
 * Licence zlib, voir le fichier LICENSE
 */

import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "OutilsGeneriques.dart";

class ImageRom{
  int adresse = 0;
  List<int> pointeurs = [];
  ImageRom({required this.adresse});

  Map toJson() => {
    'adresse' : adresse,
    'pointeurs': pointeurs,
  };
  ImageRom.fromJson(Map<String, dynamic> json)
      : adresse = json["adresse"],
        pointeurs = List<int>.from(json["pointeurs"]);

  @override
  String toString() {
    String adresseHex = '0x${adresse.toRadixString(16).toUpperCase()}';
    String pointeursHex = pointeurs
        .map((pointeur) => '0x${pointeur.toRadixString(16).toUpperCase()}')
        .join(', ');

    return '{adresse: $adresse ($adresseHex), pointeurs: $pointeurs ($pointeursHex)}';
  }
}

class Size{
  int width;
  int height;
  Size(this.width, this.height);
  @override
  String toString() {
    return "${width}Lx${height}H";
  }
  List<int> toJson() =>  [width, height];
  Size.fromJson(List<dynamic> size)
      : width = size[0],
      height = size[1];
}

class MapSize{
  int dim;
  List<Size> sizes;
  List<ImageRom> imagesRom = [];
  List<int> enteteRom = [];
  List<int> enteteJcalg1 = [];
  String typeTuile;
  MapSize(this.typeTuile, this.dim, this.sizes){
    enteteRom = [0x01, 0x00, 0x00, 0x00] +  dim.toOctets(4, Endian.little);
    enteteJcalg1 = [0x4A, 0x43] +   dim.toOctets(4, Endian.little) + [0x00, 0x00, 0x00, 0x00];
  }

  @override
  String toString() {
    String texte = "";
    texte += "---------------------------------------------\n";
    texte += "- TypeTuile : $typeTuile\n";
    texte += "- Dimension : $dim\n";
    texte += "- Sizes : $sizes\n";
    texte += "- En-tête Rom : ${toHexList(enteteRom)}\n";
    texte += "- En-tête Jcalg1 : ${toHexList(enteteJcalg1)}\n";
    texte += "- Images Rom :\n";
    for(ImageRom img in imagesRom){
      texte += "Adresse : ${img.adresse.toRadixString(16)} => Pointeurs : ${toHexList(img.pointeurs)}\n";
    }
    texte += "---------------------------------------------\n";
    return texte;
  }

  Map toJson() => {
    'typeTuile' : typeTuile,
    'dim': dim,
    'enteteRom' : enteteRom,
    'enteteJcalg1' : enteteJcalg1,
    'sizes': sizes,
    'imagesRom' : imagesRom
  };

  MapSize.fromJson(Map<String, dynamic> json)
      : typeTuile = json['typeTuile'],
        dim = json['dim'],
        enteteRom = List<int>.from(json['enteteRom']),
        enteteJcalg1 = List<int>.from(json['enteteJcalg1']),
        sizes = List<Size>.from(json["sizes"].map((size)=> Size.fromJson(size))),
        imagesRom = List<ImageRom>.from(json["imagesRom"].map((img)=> ImageRom.fromJson(img)));
}

class Global{

  static List<int> romOctets = [];
  /*
  Available sprite pixel sizes
  +--------------+-------+--------+-------+-------+
  | shape / size | small | normal |  big  | huge  |
  +--------------+-------+--------+-------+-------+
  | square       | 8x8   | 16x16  | 32x32 | 64x64 |
  | wide         | 16x8  | 32x8   | 32x16 | 64x32 |
  | tall         | 8x16  | 8x32   | 16x32 | 32x64 |
  +--------------+-------+--------+-------+-------+
  */
  /*
  Available background pixel sizes
  +-------------+---------+---------+---------+-----------+
  | shape /size |  small  | normal  |   big   |   huge    |
  +-------------+---------+---------+---------+-----------+
  | square      | 128x128 | 256x256 | 512x512 | 1024x1024 |
  | wide        |         |         | 512x256 |           |
  | tall        |         |         | 256x512 |           |
  +-------------+---------+---------+---------+-----------+
  */

  static List<MapSize> listeMap = [
    // Sprites
    MapSize("sprite", 64,   [Size(8,8)]),
    MapSize("sprite", 128,  [Size(16,8),  Size(8,16)]),
    MapSize("sprite", 256,  [Size(16,16), Size(32,8), Size(8,32)]),
    MapSize("sprite", 512,  [Size(32,16), Size(16,32)]),
    MapSize("sprite", 1024, [Size(32,32)]),
    MapSize("sprite", 2048, [Size(64,32), Size(32,64)]),
    MapSize("sprite", 4096, [Size(64,64)]),

    // Backgrounds
	MapSize("background", 458,   [Size(128,128)]), // car je le sais
    MapSize("background", 15424,   [Size(128,128)]), // car je le sais
    MapSize("background", 16384,   [Size(128,128)]),
    MapSize("background", 65536,   [Size(256,256)]),
    MapSize("background", 131072,  [Size(256,512), Size(512,256)]),
    MapSize("background", 262144,  [Size(512,512)]),
    MapSize("background", 1048576, [Size(1024,1024)]),
  ];
}

List<int> GenererPointeur(int pointeurInt){
  String pointeur =  pointeurInt.toRadixString(16).padLeft(6, '0');
  pointeur = "08$pointeur";

  RegExp exp = RegExp(r".{2}");
  Iterable<Match> matches = exp.allMatches(pointeur);
  List<int> maListe = (matches.map((m) => int.parse(m[0].toString(), radix: 16))).toList().reversed.toList();
  return maListe;
}

ImageRom chercherAdresse(int adresseRecherchee) {
  for (var mapSize in Global.listeMap) {
    for (var imageRom in mapSize.imagesRom) {
      if (imageRom.adresse == adresseRecherchee) {
        return imageRom;
      }
    }
  }  throw Exception('Adresse non trouvée, mais elle devrait exister !');
}

class Parametres {
  static final String chemin_jcalg1 = r".\lib\jcalg1.exe";
  static final String chemin_dossier_source_rom = r".\source_rom";
  static final String chemin_dossier_source_images = r".\source_images";
  static final String chemin_dossier_infos = r".\source_infos";
  static late final String chemin_generated;
  static late final String chemin_generated_temp;
}

List<int> extraire_table_indexes(List<int> fichier_bitmap) {
  int pos_depart_indexes = extractLittleEndianInt(fichier_bitmap, 0x000A);
  //print("Pos départ indexes: 0x${pos_depart_indexes.toRadixString(16)}");
  List<int> bitmapIndexes = fichier_bitmap.sublist(pos_depart_indexes);

  return bitmapIndexes;
}

String obtenir_fichier_rom(String dossier) {
  return Directory(dossier)
      .listSync()
      .whereType<File>()
      .firstWhere((file) => file.path.endsWith('.gba'))
      .path;
}

String obtenir_fichier_infos(String dossier) {
  return Directory(dossier)
      .listSync()
      .whereType<File>()
      .firstWhere((file) => file.path.endsWith('.json'))
      .path;
}

List<String> lister_fichiers_bitmap(String dossier) {
  return Directory(dossier)
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.bmp'))
      .map((file) => file.path)
      .toList();
}

void mettre_entete_en_webfoot(String chemin_fichier) {
  //  On ouvre et modifie le fichier
  List<int> octets_sortie = File(chemin_fichier).readAsBytesSync();
  List<int> entete_sortie = octets_sortie.sublist(0, 10);
  List<int> entete_fury = [0x01, 0x00, 0x00, 0x00, entete_sortie[2], entete_sortie[3], 0x00, 0x00];

  // 3. On écrase le fichier de sortie
  List<int> octets_fury = entete_fury + octets_sortie.skip(10).toList();
  File(chemin_fichier).writeAsBytesSync(octets_fury);
}

ProcessResult compresserJcalg1(String chemin_jcalg1, String cheminEntree, String cheminSortie){
  ProcessResult result = Process.runSync(chemin_jcalg1, ['c9', cheminEntree, cheminSortie],  runInShell: false, stdoutEncoding:Utf8Codec(), stderrEncoding: Utf8Codec());
  return result;
}