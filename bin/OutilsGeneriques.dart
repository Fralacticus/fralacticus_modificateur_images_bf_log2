/*
 * Droits d'auteur 2024 Fralacticus fralacticus@gmail.com
 * Licence zlib, voir le fichier LICENSE
 */

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

extension MonInt on int{
  List<int> toOctets(int pad, Endian endian){
    pad = max((bitLength/8).ceil(), pad);
    List<int> listeOctets = [];
    for(int i =0 ; i < pad ; i++){
      listeOctets.add((this >> (i*8)) & 0xff);
    }
    if(endian == Endian.big){
      return listeOctets.reversed.toList();
    }
    else {
      return listeOctets;
    }
  }
}

// Big endian
int octetsToInt(List<int> octets) {
  int res = 0;
  List<int> reverse = octets.reversed.toList();
  for(int i = 0; i < reverse.length ; i++){
    res = res | reverse[i] << i * 8;
  }
  return res;
}

List<String> toHexList(List<int> entree, {int nbPad = 2}) => entree.map((e) => e.toRadixString(16).padLeft(nbPad,'0').toUpperCase()).toList();

bool egaliteListes(List<List<int>> listes){
  // Verifier longueurs
  bool egaliteLongueurs = listes.map((liste) => liste.length).toSet().length == 1;
  if(!egaliteLongueurs && listes.isEmpty){
    print("Longueur Différente");
    return false;
  }
  // Verifier valeurs
  for(int i = 0; i < listes.first.length; i++){
    List<int> vals = [];
    for (List<int> liste in listes) {
      vals.add(liste[i]);
    }
    if(vals.toSet().length > 1){
      print(i);
      return false;
    }
  }
  return true;
}

bool egaliteDeuxListes(List<int> liste_1, List<int> liste_2) {
  if(liste_1.length!=liste_2.length) {
    return false;
  }
  for(int i=0 ; i < liste_1.length ; i++) {
    if(liste_1[i] != liste_2[i]) {
      return false;
    }
  }
  return true;
}


int extractLittleEndianInt(List<int> data, int startPosition) {
  // Extraire les 4 octets à partir de la position donnée
  int byte0 = data[startPosition];
  int byte1 = data[startPosition + 1];
  int byte2 = data[startPosition + 2];
  int byte3 = data[startPosition + 3];

  // Combiner les octets (little-endian) en un entier
  int result = (byte3 << 24) | (byte2 << 16) | (byte1 << 8) | byte0;

  return result;
}

String generer_horodatage() {
  DateTime now = DateTime.now();

  String year = now.year.toString();
  String month = now.month.toString().padLeft(2, '0'); // Ajoute un 0 si nécessaire
  String day = now.day.toString().padLeft(2, '0');

  String hour = now.hour.toString().padLeft(2, '0');
  String minute = now.minute.toString().padLeft(2, '0');
  String second = now.second.toString().padLeft(2, '0');

  return '$year$month$day-$hour$minute$second';
}

void creerDossier(String cheminDossier) {
  // Créer un objet Directory avec ce chemin
  Directory dossier = Directory(cheminDossier);

  // Vérifier si le dossier existe, sinon le créer
  if (!dossier.existsSync()) {
    dossier.createSync(recursive: true);
    print('Le dossier $cheminDossier a été créé.');
  } else {
    print('Le dossier $cheminDossier existe déjà.');
  }
}