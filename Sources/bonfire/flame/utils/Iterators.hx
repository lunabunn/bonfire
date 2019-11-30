package bonfire.flame.utils;

class PeekableStringIterator {
    public var string: String;
    public var index: Int;

    public inline function new(string: String) {
        this.string = string;
        index = 0;
    }

    public inline function hasNext() {
        return index < string.length;
    }

    public inline function next() {
        return string.charAt(index++);
    }

    public inline function peek(n: Int=0) {
        return string.charAt(index + n);
    }

    public inline function eatIf(char: String) {
        if (peek() == char) {
            index++;
            return true;
        }
        return false;
    }

    public inline function peekIf(char: String, n: Int=0) {
        return peek(n) == char;
    }
}

class PeekableTokenIterator {
    public var tokens: Array<Token>;
    public var index: Int;

    public inline function new(tokens: Array<Token>) {
        this.tokens = tokens;
        index = 0;
    }

    public inline function hasNext() {
        return index < tokens.length;
    }

    public inline function next() {
        return tokens[index++];
    }

    public inline function peek(n: Int=0) {
        return tokens[index + n];
    }

    public inline function eatIf(type: Token.TokenType) {
        if (peek().type == type) {
            index++;
            return true;
        }
        return false;
    }

    public inline function peekIf(type: Token.TokenType, n: Int=0) {
        return peek(n).type == type;
    }

    public inline function consume(type: Token.TokenType, message: String) {
        if (peek().type == type) {
            return next();
        }
        throw new ParseError(peek(), message);
    }
}