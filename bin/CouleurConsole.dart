/*
 * Droits d'auteur 2024 Fralacticus fralacticus@gmail.com
 * Licence zlib, voir le fichier LICENSE
 */

import 'package:ansicolor/ansicolor.dart';

AnsiPen bleu = AnsiPen()..blue(bold: true);
AnsiPen rouge = AnsiPen()..red(bold: true);
AnsiPen magenta = AnsiPen()..magenta(bold: true);
AnsiPen jaune = AnsiPen()..yellow(bold: true);
AnsiPen vert = AnsiPen()..green(bold: true);
AnsiPen turquoise = AnsiPen()..xterm(110);
AnsiPen orange = AnsiPen()..xterm(202);
AnsiPen dbz = AnsiPen()..blue(bold: true)..xterm(202, bg:true);
AnsiPen dbz_blanc = AnsiPen()..white(bold: true)..xterm(202, bg:true);
AnsiPen cyan = AnsiPen()..cyan(bold: true);

