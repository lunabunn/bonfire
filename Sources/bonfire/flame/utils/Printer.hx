package bonfire.flame.utils;

import haxe.Log;

class Printer {
    public static function trace(str: String, token: Token=null, source: String=null, position: Int=null) {
        var sb = "";
        sb += 'FlameScript > $str';
        if (token != null) {
            source = token.source;
            position = token.position;
        }
        if (source != null && position != null) {
            var lines = source.split("\n");
            var charCount = -1;
            var i = 0;
            for (line in lines) {
                charCount += line.length + 1;
                i++;
                if (charCount >= position) {
                    var temp = '              $i | ${line.substr(0, line.length - charCount + position)}';
                    var pointerLeft = "";
                    for (i in 0...temp.length) {
                        if (temp.charAt(i) != "\t")
                            pointerLeft += " ";
                        else
                            pointerLeft += "\t";
                    }
                    sb += '\n\n              $i | $line\n$pointerLeft^-- here';
                    break;
                }
            }
        }
        Log.trace(sb, null);
    }
}