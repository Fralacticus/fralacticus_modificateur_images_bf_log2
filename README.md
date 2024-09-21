# Fralacticus - Modificateur d'images des jeux GBA Buu's Fury et Legacy of Goku 2

![image-20240921160109612](assets_README/image-20240921160109612.png)

## Description

Ce logiciel est un outil automatisé permettant de réinsérer des fichiers .bmp modifiés des jeux GBA Buu's Fury et Legacy of Goku 2 après extraction via le logiciel https://github.com/Fralacticus/fralacticus-chercheur-image. 

## Utilisation

> ℹ️ **Note** : Les étapes 1 à 4 ne sont nécessaires qu'une seule fois lors de la première configuration.

1. **Extraction des images** : Utilisez le logiciel [fralacticus-chercheur-image](https://github.com/Fralacticus/fralacticus-chercheur-image) pour extraire les fichiers `.bmp` et générer le fichier `infos.json`. 

2. **Téléchargement du logiciel** : Clonez ou télécharger ce dépôt sur votre ordinateur.

3. **Placement de la rom `.gba`** : Placer la rom `.gba`  originale (nommez-la à votre guise) dans le dossier **source_rom**. 

4. **Placement du fichier `.json`** : Copiez le fichier `infos.json` généré dans le dossier **source_infos**.

5. **Modification des images `.bmp`** : Les fichiers `.bmp` extraits peuvent être modifiés avec un logiciel d'édition d'images tel que **Photoshop**. Il est important de **conserver le mode indexé** et de **respecter les couleurs de la palette originale**. N'apportez aucune modification au nom des fichiers .bmp.

6. **Placement des images `.bmp` modifiées** : Placez les fichiers `.bmp` modifiés, sans les renommer, dans le dossier **source_images**.

7. **Exécution** : Lancez `fralacticus_modificateur_images_bf_log2.exe` pour réinsérer automatiquement les fichiers `.bmp` modifiés.

   Le logiciel génère une copie modifiée de la rom dans le dossier **export\generated_**, en ajoutant un horodatage au dossier et au nom du fichier
