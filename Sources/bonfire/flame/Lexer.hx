package bonfire.flame;

import bonfire.flame.Literal;
import bonfire.flame.Token;
import bonfire.flame.utils.Iterators.PeekableStringIterator;
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
                    tokens.push(new Token(TokenType.L_PAREN, str, index));
                    continue;
                case ")":
                    tokens.push(new Token(TokenType.R_PAREN, str, index));
                    continue;
                case "{":
                    tokens.push(new Token(TokenType.L_CURLY, str, index));
                    continue;
                case "}":
                    tokens.push(new Token(TokenType.R_CURLY, str, index));
                    continue;
                
                case "+":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.PLUS_SET, str, index));
                    else
                        tokens.push(new Token(TokenType.PLUS, str, index));
                    continue;
                case "-":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.MINUS_SET, str, index));
                    else
                        tokens.push(new Token(TokenType.MINUS, str, index));
                    continue;
                case "*":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.MULT_SET, str, index));
                    else
                        tokens.push(new Token(TokenType.MULT, str, index));
                    continue;
                case "/":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.DIV_SET, str, index));
                    else
                        tokens.push(new Token(TokenType.DIV, str, index));
                    continue;
                case ".":
                    if (numberRegex.match(siter.string.substr(siter.index - 1))) {
                        tokens.push(new Token(TokenType.NUMBER, new NumberLiteral(Std.parseFloat(numberRegex.matched(0))), str, index));
                        siter.index += numberRegex.matchedPos().len - 1;
                    } else
                        tokens.push(new Token(TokenType.DOT, str, index));
                    continue;
                
                case "&":
                    if (siter.eatIf("&")) {
                        tokens.push(new Token(TokenType.AND, str, index));
                        continue;
                    }
                case "|":
                    if (siter.eatIf("|")) {
                        tokens.push(new Token(TokenType.OR, str, index));
                        continue;
                    }
                case ">":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.GREATER_EQL, str, index));
                    else
                        tokens.push(new Token(TokenType.GREATER, str, index));
                    continue;
                case "<":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.LESS_EQL, str, index));
                    else
                        tokens.push(new Token(TokenType.LESS, str, index));
                    continue;
                case "=":
                    if (siter.eatIf("="))
                        tokens.push(new Token(TokenType.EQL_EQL, str, index));
                    else
                        tokens.push(new Token(TokenType.SET, str, index));
                    continue;
                
                case "!":
                    tokens.push(new Token(TokenType.BANG, str, index));
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
                    tokens.push(new Token(TokenType.STRING, new StringLiteral(value), str, index));
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
                    tokens.push(new Token(TokenType.STRING, new StringLiteral(value), str, index));
                    continue;
                
                case ",":
                    tokens.push(new Token(TokenType.COMMA, str, index));
                    continue;
            }

            if (numberRegex.match(siter.string.substr(siter.index - 1))) {
                tokens.push(new Token(TokenType.NUMBER, new NumberLiteral(Std.parseFloat(numberRegex.matched(0))), str, index));
                siter.index += numberRegex.matchedPos().len - 1;
                continue;
            }
            
            if (symbolRegex.match(siter.string.substr(siter.index - 1))) {
                switch (symbolRegex.matched(0)) {
                    case "fun":
                        tokens.push(new Token(TokenType.FUN, str, index));
                    case "var":
                        tokens.push(new Token(TokenType.VAR, str, index));
                    case "if":
                        tokens.push(new Token(TokenType.IF, str, index));
                    case "else":
                        tokens.push(new Token(TokenType.ELSE, str, index));
                    case "while":
                        tokens.push(new Token(TokenType.WHILE, str, index));
                    default:
                        tokens.push(new Token(TokenType.SYMBOL, new SymbolLiteral(symbolRegex.matched(0)), str, index));
                }
                siter.index += symbolRegex.matchedPos().len - 1;
                continue;
            }

            Printer.trace('${str.charAt(index)} is not a valid token.', str, index);
        }
        tokens.push(new Token(TokenType.EOF, str, siter.index));
        return tokens;
    }
}