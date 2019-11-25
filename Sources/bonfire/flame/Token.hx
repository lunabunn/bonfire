package bonfire.flame;

enum TokenType {
    // Brackets
    L_PAREN; // (
    R_PAREN; // )
    L_CURLY; // {
    R_CURLY; // }

    // Binary Operators
    PLUS; // +
    MINUS; // -
    MULT; // *
    DIV; // /
    DOT; // .

    AND; // &&
    OR; // ||
    GREATER; // >
    LESS; // <
    GREATER_EQL; // >=
    LESS_EQL; // <=
    EQL_EQL; // ==

    SET; // =
    PLUS_SET; // +=
    MINUS_SET; // -=
    MULT_SET; // *=
    DIV_SET; // /=

    // Unary Operators
    BANG; // !(x)

    // Literals
    STRING; // "Hello, World!"
    SYMBOL; // foobar
    NUMBER; // 3.14

    // Keywords
    FUN;
    VAR;

    // Misc.
    COMMA; // ,
    SEMICOLON; // ;
    EOF; // Appeneded automatically at end of file
}

class Token {
    public var type: TokenType;
    public var value: Null<Literal>;
    public var position: Int;

    public function new<T>(type: TokenType, ?value: Literal, position: Int) {
        this.type = type;
        this.value = value;
        this.position = position;
    }
}