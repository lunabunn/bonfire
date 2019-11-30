package bonfire.flame;

interface Expr {}

class BinaryExpression implements Expr {
    public var op: Token;
    public var left: Expr;
    public var right: Expr;

    public function new(op: Token, left: Expr, right: Expr) {
        this.op = op;
        this.left = left;
        this.right = right;
    }
}

class UnaryExpression implements Expr {
    public var op: Token;
    public var operand: Expr;

    public function new(op: Token, operand: Expr) {
        this.op = op;
        this.operand = operand;
    }
}

class FuncCallExpr implements Expr {
    public var func: Expr;
    public var args: Array<Expr>;

    public function new(func: Expr, args: Array<Expr>=null) {
        this.func = func;
        this.args = args;
    }
}