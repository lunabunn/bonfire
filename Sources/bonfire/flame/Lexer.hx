package bonfire.flame;

import bonfire.flame.Literal.SymbolLiteral;
import bonfire.flame.Literal.NumberLiteral;
import bonfire.flame.Literal.StringLiteral;
import bonfire.flame.utils.Iterators.PeekableStringIterator;
import bonfire.flame.Token;
import bonfire.flame.Token.TokenType;
import bonfire.flame.utils.Printer;

class Lexer {
    static var numberRegex = ~/^([0-9]*\.)?[0-9]+/g;
    static var symbolRegex = ~/^[a-zA-Z_][a-zA-Z_0-9]*/g;

    public static function lex(str: String): Array<Token> {
        var tokens = new Array<Token>();
        var siter = new PeekableStringIterator(str);
        var index: Int;
        for (char in siter) {
            index = siter.index - 1;
            switch (char) {
                case "#":
                    while (siter.hasNext() && siter.peek() != "\n") {
                        siter.index++;
                    }
                case " ":
                    continue;
                case "\n":
                    continue;

                case "(":
                    tokens.push(new Token(TokenType.L_PAREN, index));
                    continue;
                case ")":
                    tokens.push(new Token(TokenType.R_PAREN, index));
                    continue;
                case "{":
                    tokens.push(new Token(TokenType.L_CURLY, index));
                    continue;
                case "}":
                    tokens.push(new Token(TokenType.R_CURLY, index));
                    continue;
                
                case "+":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.PLUS_SET, index));
                    else
                        tokens.push(new Token(TokenType.PLUS, index));
                    continue;
                case "-":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.MINUS_SET, index));
                    else
                        tokens.push(new Token(TokenType.MINUS, index));
                    continue;
                case "*":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.MULT_SET, index));
                    else
                        tokens.push(new Token(TokenType.MULT, index));
                    continue;
                case "/":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.DIV_SET, index));
                    else
                        tokens.push(new Token(TokenType.DIV, index));
                    continue;
                case ".":
                    if (numberRegex.match(siter.string.substr(siter.index - 1))) {
                        tokens.push(new Token(TokenType.NUMBER, new NumberLiteral(Std.parseFloat(numberRegex.matched(0))), index));
                        siter.index += numberRegex.matchedPos().len - 1;
                    } else
                        tokens.push(new Token(TokenType.DOT, index));
                    continue;
                
                case "&":
                    if (siter.eatIf("&")) {
                        tokens.push(new Token(TokenType.AND, index));
                        continue;
                    }
                case "|":
                    if (siter.eatIf("|")) {
                        tokens.push(new Token(TokenType.OR, index));
                        continue;
                    }
                case ">":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.GREATER_EQL, index));
                    else
                        tokens.push(new Token(TokenType.GREATER, index));
                    continue;
                case "<":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.LESS_EQL, index));
                    else
                        tokens.push(new Token(TokenType.LESS, index));
                    continue;
                case "=":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.EQL_EQL, index));
                    else
                        tokens.push(new Token(TokenType.SET, index));
                    continue;
                
                case "!":
                    tokens.push(new Token(TokenType.BANG, index));
                    continue;

                case "\"":
                    var value = "";
                    for (char in siter) {
                        if (char == "\"")
                            break;
                        if (char == "\\") {
                            var nextChar = siter.next();
                            switch (nextChar) {
                                case "t":
                                    value += "\t";
                                case "n":
                                    value += "\n";
                                default:
                                    value += nextChar;
                            }
                        } else {
                            value += char;
                        }
                    }
                    tokens.push(new Token(TokenType.STRING, new StringLiteral(value), index));
                    continue;
                case "\'":
                    var value = "";
                    for (char in siter) {
                        if (char == "\'")
                            break;
                        if (char == "\\") {
                            var nextChar = siter.next();
                            switch (nextChar) {
                                case "t":
                                    value += "\t";
                                case "n":
                                    value += "\n";
                                default:
                                    value += nextChar;
                            }
                        } else {
                            value += char;
                        }
                    }
                    tokens.push(new Token(TokenType.STRING, new StringLiteral(value), index));
                    continue;
                
                case ",":
                    tokens.push(new Token(TokenType.COMMA, index));
                    continue;
                case ";":
                    tokens.push(new Token(TokenType.SEMICOLON, index));
                    continue;
            }

            if (numberRegex.match(siter.string.substr(siter.index - 1))) {
                tokens.push(new Token(TokenType.NUMBER, new NumberLiteral(Std.parseFloat(numberRegex.matched(0))), index));
                siter.index += numberRegex.matchedPos().len - 1;
                continue;
            }
            
            if (symbolRegex.match(siter.string.substr(siter.index - 1))) {
                switch (symbolRegex.matched(0)) {
                    case "fun":
                        tokens.push(new Token(TokenType.FUN, index));
                    case "var":
                        tokens.push(new Token(TokenType.VAR, index));
                    default:
                        tokens.push(new Token(TokenType.SYMBOL, new SymbolLiteral(symbolRegex.matched(0)), index));
                }
                continue;
            }

            Printer.trace('${str.charAt(index)} is not a valid token.', str, index);
        }
        tokens.push(new Token(TokenType.EOF, siter.index));
        return tokens;
    }
}