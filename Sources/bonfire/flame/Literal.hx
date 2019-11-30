package bonfire.flame;

interface Literal extends Expr {}

class StringLiteral implements Literal {
    public var value: String;
    
    public inline function new(value: String) {
        this.value = value;
    }
}

class SymbolLiteral implements Literal {
    public var value: String;
    
    public inline function new(value: String) {
        this.value = value;
    }
}

class NumberLiteral implements Literal {
    public var value: Float;
    
    public inline function new(value: Float) {
        this.value = value;
    }
}