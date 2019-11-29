package bonfire.flame;

class ParseError {
    public var token: Token;
    public var message: String;

    public function new(token: Token, message: String) {
        this.token = token;
        this.message = message;
    }
}