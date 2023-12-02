# Flutter-font-metadata


add this file in your project and

use this code to get Map<String,dynamic> metadata font 
you must get Uint8List from font 
Uint8List fontPath= //;

final fonts=FontName.parse(fontPath);

  print(fonts);
