/*
 * Droits d'auteur 2024 Fralacticus fralacticus@gmail.com
 * Licence zlib, voir le fichier LICENSE
 */

import "dart:io";
import "Metadonnees.dart";

class Convertisseur {

  static List<int> convertir(final List<int> bitmap_indexes, final Metadonnees metadonnees) {
    List<int> image_decomp = [];
    switch(metadonnees.genrePix){
      case GenrePix.sansLignes :
        image_decomp = decoder_sansLignes(bitmap_indexes, metadonnees.largeur, metadonnees.hauteur);
        break;
      case GenrePix.avecChunks:
        image_decomp = decoder_avecChunks(bitmap_indexes, metadonnees.largeur, metadonnees.hauteur);
        break;
    }

    return image_decomp;
  }

  static int calculerPixelArraySize(int rowSize, int hauteur){
    int sizeofPixelArray = rowSize * hauteur.abs();
    return sizeofPixelArray;
  }

  static List<int> decoder_sansLignes(List<int> bitmap_indexes, int largeur, int hauteur) {
    int rowSize = (8*largeur/32).ceil() * 4;
    int sizeOfPixelArray = calculerPixelArraySize(rowSize, hauteur);
    //print("sizeofPixelArray: $sizeOfPixelArray, bitmap_indexes.length: ${bitmap_indexes.length}");
    if(sizeOfPixelArray < bitmap_indexes.length) {
      bitmap_indexes = bitmap_indexes.sublist(0, sizeOfPixelArray);
    }
    else if(sizeOfPixelArray > bitmap_indexes.length) {
      print("ATRAITER");
      exit(-1);
    }

    // Diviser le PixelArray en lignes (incluant les paddings)
    List<List<int>> lignes = [];
    for (int i = 0; i < bitmap_indexes.length; i += rowSize) {
      lignes.add(bitmap_indexes.sublist(i, i + rowSize));
    }

    // Supprimer le padding sur chaque ligne
    List<List<int>> lignesSansPadding = lignes.map((ligne) {
      return ligne.sublist(0, largeur); // Retirer les octets de padding
    }).toList();

    // Réinverser les lignes pour revenir à l'ordre original
    lignesSansPadding = lignesSansPadding.reversed.toList();

    // Fusionner les lignes sans padding pour reformer la liste d'octets
    List<int> octets = [];
    for (List<int> ligne in lignesSansPadding) {
      octets.addAll(ligne);
    }

    return octets;
  }

  static List<int> decoder_avecChunks(List<int> bitmap_indexes, int largeur, int hauteur) {
    int rowSize = (8*largeur/32).ceil() * 4;
    int sizeOfPixelArray = calculerPixelArraySize(rowSize, hauteur);
    //print("sizeofPixelArray: $sizeOfPixelArray, bitmap_indexes.length: ${bitmap_indexes.length}");
    if(sizeOfPixelArray < bitmap_indexes.length) {
      bitmap_indexes = bitmap_indexes.sublist(0, sizeOfPixelArray);
    }
    else if(sizeOfPixelArray > bitmap_indexes.length) {
      print("ATRAITER");
      exit(-1);
    }

    // Diviser bitmap_indexes en lignes
    List<List<int>> lignes = _decoder_avecLignes(bitmap_indexes, largeur);

    // Préparer une liste pour stocker les blocs de tuiles
    List<int> octets = [];

    // Chaque bloc est un ensemble de tuiles
    for (int i = 0; i < lignes.length; i += 8) {
      // Réorganiser les tuiles
      for (int j = 0; j < largeur; j += 8) {
        for (int k = 0; k < 8; k++) {
          octets.addAll(lignes[i + k].sublist(j, j + 8));
        }
      }
    }

    // Retourner la liste d'octets d'origine
    return octets;

  }

  static List<List<int>> _decoder_avecLignes(List<int> bitmap_indexes, int largeur) {
    int rowSize = (8*largeur/32).ceil() * 4;
    // Diviser le PixelArray en lignes (chaque ligne fait rowSize octets)
    List<List<int>> lignes = [];
    for (int i = 0; i < bitmap_indexes.length; i += rowSize) {
      lignes.add(bitmap_indexes.sublist(i, i + rowSize));
    }

    // Supprimer le padding de chaque ligne (conserver seulement 'largeur' octets)
    List<List<int>> lignesSansPadding = lignes.map((ligne) {
      return ligne.sublist(0, largeur);  // Retirer les octets de padding
    }).toList();

    // Réinverser les lignes pour revenir à l'ordre original
    return lignesSansPadding.reversed.toList();
  }


}