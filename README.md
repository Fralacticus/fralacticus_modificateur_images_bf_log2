# Fralacticus - Modificateur d'images des jeux GBA Buu's Fury et Legacy of Goku 2

![image-20240921160109612](assets_README/image-20240921160109612.png)

## Description

Ce logiciel est un outil automatisé permettant de réinsérer des fichiers .bmp modifiés des jeux GBA Buu's Fury et Legacy of Goku 2 après extraction via le logiciel https://github.com/Fralacticus/fralacticus-chercheur-image. 

## Utilisation

1. **Extraction des images** : Utilisez le logiciel [fralacticus-chercheur-image](https://github.com/Fralacticus/fralacticus-chercheur-image) pour extraire les fichiers `.bmp` et générer le fichier `infos.json`. 

2. **Téléchargement du logiciel** : Clonez ou télécharger ce dépôt sur votre ordinateur.

3. **Placement de la rom `.gba`** : Placer la rom .gba originale dans le dossier **source_rom** (nommez-le à votre guise).

4. **Placement du fichier `.json`** : Copiez le fichier `infos.json` généré dans le dossier **source_infos**.

5. **Exécution** : Lancez le programme pour réinsérer automatiquement les fichiers `.bmp` modifiés.

   Le logiciel génère une copie modifiée de la rom dans le dossier **export\generated_**, en ajoutant un horodatage au dossier et au nom du fichier
