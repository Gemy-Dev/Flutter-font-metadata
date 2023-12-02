

import 'dart:typed_data';

class FontName {
  static Map<dynamic,dynamic>parse(List<int> buff) {
    var bin = _bin;
    var data = Uint8List.fromList(buff);
    var tag = bin.readASCII(data, 0, 4);

    // If the file is a TrueType Collection
    if (tag == "ttcf") {
      var offset = 8;
      var numF = bin.readUint(data, offset);
      offset += 4;
      var fnts = [];
      for (var i = 0; i < numF; i++) {
        var foff = bin.readUint(data, offset);
        offset += 4;
        fnts.add(_readFont(data, foff));
      }
      return fnts.last;
    } else {
      return _readFont(data, 0);
    }
  }

  static Map<dynamic,dynamic> _readFont(List<int> data, int offset) {
    var bin = _bin;

    offset += 4;
    var numTables = bin.readUshort(data, offset);
    offset += 8;

    for (var i = 0; i < numTables; i++) {
      var tag = bin.readASCII(data, offset, 4);
      offset += 8;
      var toffset = bin.readUint(data, offset);
      offset += 8;
      if (tag == "name") {
        return Name.parse(data, toffset) ;
      }
    }

    throw Exception('Failed to parse file');
  }

  static final _bin = _Bin.t();

   

   

   
}
class Name {
    static dynamic parse(List<int> data, int offset) {
      var bin = _Bin.t();
      var obj = {};
      offset += 2;
      var count = bin.readUshort(data, offset);
      offset += 2;
      offset += 2;

      var names = [
      "copyright",
      "fontFamily",
      "fontSubfamily",
      "ID",
      "fullName",
      "version",
      "postScriptName",
      "trademark",
      "manufacturer",
      "designer",
      "description",
      "urlVendor",
      "urlDesigner",
      "licence",
      "licenceURL",
      "---",
      "typoFamilyName",
      "typoSubfamilyName",
      "compatibleFull",
      "sampleText",
      "postScriptCID",
      "wwsFamilyName",
      "wwsSubfamilyName",
      "lightPalette",
      "darkPalette",
      "preferredFamily",
      "preferredSubfamily",
      ];

      var offset0 = offset;

      for (var i = 0; i < count; i++) {
        var platformID = bin.readUshort(data, offset);
        offset += 2;
        var encodingID = bin.readUshort(data, offset);
        offset += 2;
        var languageID = bin.readUshort(data, offset);
        offset += 2;
        var nameID = bin.readUshort(data, offset);
        offset += 2;
        var slen = bin.readUshort(data, offset);
        offset += 2;
        var noffset = bin.readUshort(data, offset);
        offset += 2;
        String cname='';
if(nameID<=25){

       cname = names[nameID];
}
        var soff = offset0 + count * 12 + noffset;
        
        String str;
        if (platformID == 0) {
          str = bin.readUnicode(data, soff, slen ~/ 2);
        } else if (platformID == 3 && encodingID == 0) {
          str = bin.readUnicode(data, soff, slen ~/ 2);
        } else if (encodingID == 0) {
          str = bin.readASCII(data, soff, slen);
        } else if (encodingID == 1) {
          str = bin.readUnicode(data, soff, slen ~/ 2);
        } else if (encodingID == 3) {
          str = bin.readUnicode(data, soff, slen ~/ 2);
        } else if (platformID == 1) {
          str = bin.readASCII(data, soff, slen);
          print("reading unknown MAC encoding $encodingID as ASCII");
        } else {
          throw Exception("unknown encoding $encodingID, platformID: $platformID");
        }

      var tid = "p$platformID,${languageID.toRadixString(16)}";
        obj[tid] ??= {} ;
        obj[tid][cname] = str;
        obj[tid]['_lang'] = languageID;
      }

      for (var p in obj.keys) {
        if (obj[p]['postScriptName'] != null) {
          return obj[p]  ;
        }
      }

      String tname='';
      for (var p in obj.keys) {
        tname = p ;
        break;
      }
      print("Returning name table with languageID ${obj[tname]['_lang']}");
      return obj[tname];
    }
  }
class _Bin {
    late final Uint8List _buff ;

    int readUshort(List<int> buff, int p) {
      return (buff[p] << 8) | buff[p + 1];
    }

    int readUint(List<int> buff, int p) {
      var a = uint8;
      a[3] = buff[p];
      a[2] = buff[p + 1];
      a[1] = buff[p + 2];
      a[0] = buff[p + 3];
      return uint32[0];
    }

    int readUint64(List<int> buff, int p) {
      return (readUint(buff, p) * (0xffffffff + 1) + readUint(buff, p + 4));
    }

    String readASCII(List<int> buff, int p, int l) {
      var s = "";
      for (var i = 0; i < l; i++) {
        s += String.fromCharCode(buff[p + i]);
      }
      return s;
    }

    String readUnicode(List<int> buff, int p, int l) {
      var s = "";
      for (var i = 0; i < l; i++) {
        var c = (buff[p++] << 8) | buff[p++];
        s += String.fromCharCode(c);
      }
      return s;
    }
_Bin.t() : _buff = Uint8List(8);

  Uint8List get buff => _buff;
  Int8List get int8 => Int8List.view(_buff.buffer);
  Uint8List get uint8 => Uint8List.view(_buff.buffer);
  Int16List get int16 => Int16List.view(_buff.buffer);
  Uint16List get uint16 => Uint16List.view(_buff.buffer);
  Int32List get int32 => Int32List.view(_buff.buffer);
  Uint32List get uint32 => Uint32List.view(_buff.buffer);

  }


