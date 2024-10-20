/*
 * Droits d'auteur 2024 Fralacticus fralacticus@gmail.com
 * Licence zlib, voir le fichier LICENSE
 */

import "dart:convert";
import "dart:io";
import 'package:ansicolor/ansicolor.dart';
import "package:path/path.dart" as path;
import 'package:stack_trace/stack_trace.dart' as trace;

import "Metadonnees.dart";
import "Convertisseur.dart";
import "CouleurConsole.dart";
import "OutilsDedies.dart";
import "OutilsGeneriques.dart";

int main() {
  try {
    ansiColorDisabled = false;
    afficher_titre();
    executer();
  }
  catch (e, stacktrace) {
    stderr.writeln(rouge("\n => ERREUR: "));
    stderr.writeln(e);
    stderr.writeln(rouge("\n => TRACE DE L'APPEL DE PILE: "));
    stderr.writeln(trace.Trace.from(stacktrace));

    stderr.writeln(erreur_fin("Appuyez sur Entrée pour fermer la console..."));
    stdin.readLineSync();
    return 255;
  }
  return 0;
}

void executer() {
  ansiColorDisabled = false;

  final String horodatage = generer_horodatage();

  Parametres.chemin_generated = ".\\export\\generated_$horodatage";
  Parametres.chemin_generated_temp = "${Parametres.chemin_generated}\\temp";

  creerDossier(Parametres.chemin_generated);
  creerDossier(Parametres.chemin_generated_temp);

  List<String> liste_chemins_fichier_bitmap = lister_fichiers_bitmap(Parametres.chemin_dossier_source_images);
  print(bleu("- Liste des ${liste_chemins_fichier_bitmap.length} fichiers bitmap dans ${Parametres.chemin_dossier_source_images} qui seront insérés dans la rom : "));
  for (var fichier in liste_chemins_fichier_bitmap) {
    print("   - ${path.basename(fichier)}");
  }

  String chemin_fichier_rom = obtenir_fichier_rom(Parametres.chemin_dossier_source_rom);
  stdout.write(bleu("- Lecture de la rom source $chemin_fichier_rom ... "));
  List<int> rom = List<int>.from(File(chemin_fichier_rom).readAsBytesSync());
  int taille_rom_octets = rom.length;
  int taille_rom_mo = convertOctetsToMo(taille_rom_octets);
  stdout.writeln(vert("OK"));

  String chemin_fichier_infos = obtenir_fichier_infos(Parametres.chemin_dossier_infos);
  stdout.write(bleu("- Lecture et analyse du fichier infos $chemin_fichier_infos ... "));
  String fichier_infos  = File(chemin_fichier_infos).readAsStringSync();
  Map<String, dynamic> json  = jsonDecode(fichier_infos);
  Global.listeMap.clear();
  Global.listeMap = List<MapSize>.from(json["infos"].map((e)=> MapSize.fromJson(e)));
  stdout.writeln(vert("OK"));

  stdout.write(bleu("- Première adresse d'insertion : "));
  int adresse_insertion = calculer_premier_adresse_libre(rom);
  print("0x${adresse_insertion.toRadixString(16)}");

  print(bleu("\n- Traitement des fichiers bitmaps :"));
  int i = 1;
  for(String chemin_fichier_bitmap in liste_chemins_fichier_bitmap) {
    String bitmap_base_name = path.basename(chemin_fichier_bitmap);
    String base_name_sans_extension = path.basenameWithoutExtension(chemin_fichier_bitmap);

    print(magenta("   => ($i/${liste_chemins_fichier_bitmap.length}) $bitmap_base_name"));
    stdout.write("   - Extraction métadonnées du nom du fichier ... ");
    Metadonnees metadonnees = Metadonnees(chemin_fichier_bitmap);
    stdout.writeln(vert("OK"));

    stdout.write("   - Lecture fichier ... ");
    List<int> bitmap = File(chemin_fichier_bitmap).readAsBytesSync();
    stdout.writeln(vert("OK"));

    stdout.write("   - Extraction table des indexes ... ");
    List<int> bitmap_indexes = extraire_table_indexes(bitmap);
    stdout.writeln(vert("OK"));

    stdout.write("   - Conversion au format decompressé gba ... ");
    List<int> image_decomp = Convertisseur.convertir(bitmap_indexes, metadonnees);
    stdout.writeln(vert("OK"));

    stdout.writeln("   - Écriture de l'image dans ${Parametres.chemin_generated_temp} : ");
    String chemin_image_decomp = path.join(Parametres.chemin_generated_temp, "${base_name_sans_extension}_DECOMP.txt");
    stdout.write("       ${path.basename(chemin_image_decomp)} ... ");
    File(chemin_image_decomp).writeAsBytesSync(image_decomp);
    stdout.writeln(vert("OK"));

    stdout.write("   - Compression jcalg1 ... ");
    String chemin_image_comp = path.join(Parametres.chemin_generated_temp, "${base_name_sans_extension}_COMP.txt");
    ProcessResult process_result = compresserJcalg1(Parametres.chemin_jcalg1, chemin_image_decomp, chemin_image_comp);
    if(process_result.exitCode == 0) {
      stdout.writeln(vert("OK"));
    }
    else {
      stdout.writeln(rouge("NOK"));
      stdout.writeln(rouge(process_result.stdout));
      stdout.writeln(rouge(process_result.stderr));
      stdin.readLineSync();
      exit(-1);
    }

    stdout.write("   - Modifie en-tête fichier compressé en mode WebfootTechnologies ... ");
    mettre_entete_en_webfoot(chemin_image_comp);
    stdout.writeln(vert("OK"));


    stdout.writeln("   - Lecture de l'image compressée dans ${Parametres.chemin_generated_temp} : ");
    stdout.write("       ${path.basename(chemin_image_comp)} ... ");
    List<int> image_comp = File(chemin_image_comp).readAsBytesSync();
    stdout.writeln(vert("OK"));


    stdout.writeln("   - Adresse d'insertion dans rom :");
    ImageRom infos_image_originale = chercherAdresse(metadonnees.adresse);
    print("      - Pointeurs: ${toHexList(infos_image_originale.pointeurs)}");
    print("      - Adresse: 0x${infos_image_originale.adresse.toRadixString(16)} -> 0x${adresse_insertion.toRadixString(16)}");


    if(adresse_insertion + image_comp.length > taille_rom_octets) {
      stdout.write(dbz_blanc("   - Tentative d'agrandissement de la rom : $taille_rom_mo "));
      taille_rom_mo *= 2;
      stdout.write("-> $taille_rom_mo Mo ... ");
      if(taille_rom_mo > 32) {
        stdout.write(rouge(" NOK, elle a déjà la taille max de 32Mo"));
        stdin.readLineSync();
        exit(-1);
      }
      taille_rom_octets = convertMoToOctets(taille_rom_mo);
      agrandirListe(rom, taille_rom_octets, 0xFF);
      stdout.writeln(vert("OK"));
    }

    stdout.write("   - Insertion dans la rom de l'image ... ");
    rom.setAll(adresse_insertion, image_comp);
    stdout.writeln(vert("OK"));

    stdout.write("   - Modification dans la rom des pointeurs ... ");
    List<int> contenu_pointeur = GenererPointeur(adresse_insertion);
    for(int pointeur in infos_image_originale.pointeurs) {
      rom.setAll(pointeur, contenu_pointeur);
    }
    stdout.writeln(vert("OK"));

    // Calcul prochaine adresse
    adresse_insertion += image_comp.length;
    if (adresse_insertion % 16 != 0) {
      adresse_insertion = adresse_insertion + 16 - (adresse_insertion % 16);
    }
    i+=1;
  }

  stdout.writeln(bleu("\n- Écriture de la rom modifiée ($taille_rom_mo Mo) dans ${Parametres.chemin_generated} : "));
  String chemin_rom_modifee = path.join(Parametres.chemin_generated, "${path.basenameWithoutExtension(chemin_fichier_rom)}_$horodatage.gba");
  stdout.write("   ${path.basename(chemin_rom_modifee)} ... ");
  File(chemin_rom_modifee).writeAsBytesSync(rom);
  stdout.writeln(vert("OK"));

  print("");
  print(orange('~~~> Le programme est terminé. Appuyez sur Entrée pour fermer la console...'));

  stdin.readLineSync();
}
















