package bonfire.flame;

import bonfire.flame.Literal;

interface Stmt {}

class FuncDecStmt implements Stmt {
    var symbol: SymbolLiteral;
    var args: Array<SymbolLiteral>;
    var body: Stmt;

    public function new(symbol: SymbolLiteral, args: Array<SymbolLiteral>, body: Stmt) {
        this.symbol = symbol;
        this.args = args;
        this.body = body;
    }
}

class VarDecStmt implements Stmt {
    var symbol: SymbolLiteral;
    var value: Expr;

    public function new(symbol: SymbolLiteral, value: Expr) {
        this.symbol = symbol;
        this.value = value;
    }
}

class WhileStmt implements Stmt {
    public var condition: Expr;
    public var stmt: Stmt;

    public function new(condition: Expr, stmt: Stmt) {
        this.condition = condition;
        this.stmt = stmt;
    }
}

class IfStmt implements Stmt {
    public var condition: Expr;
    public var stmt: Stmt;
    public var elseStmt: Null<Stmt>;

    public function new(condition: Expr, stmt: Stmt, elseStmt: Stmt=null) {
        this.condition = condition;
        this.stmt = stmt;
        this.elseStmt = elseStmt;
    }
}

class ExprStmt implements Stmt {
    public var expr: Expr;

    public function new(expr: Expr) {
        this.expr = expr;
    }
}

class CompoundStmt implements Stmt {
    public var stmts: Array<Stmt>;

    public function new(stmts: Array<Stmt>) {
        this.stmts = stmts;
    }
}