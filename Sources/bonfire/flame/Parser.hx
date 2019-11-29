package bonfire.flame;

import bonfire.flame.Literal;
import bonfire.flame.Stmt;
import bonfire.flame.Expr;
import bonfire.flame.Token;
import bonfire.flame.utils.Printer.trace in err;
import bonfire.flame.utils.Iterators.PeekableTokenIterator in PTI;

class Parser {
    static var hadError: Bool;

    public static function parse(tokens: Array<Token>): Array<Stmt> {
        var titer = new PTI(tokens);
        hadError = false;
        var stmts = new Array<Stmt>(), stmt: Stmt;
        while (true) {
            if ((stmt = statement(titer)) != null) {
                stmts.push(stmt);
            } else if (titer.eatIf(TokenType.EOF)) {
                break;
            } else {
                err('Expected start of statement, got ${titer.peek().type}', titer.next());
            }
        }
        return stmts;
    }

    static inline function statement(titer: PTI): Stmt {
        switch (titer.peek().type) {
            case TokenType.FUN:
                return funcDecStmt(titer);
            case TokenType.VAR:
                return varDecStmt(titer);
            case TokenType.WHILE:
                return whileStmt(titer);
            case TokenType.IF:
                return ifStmt(titer);
            case TokenType.SYMBOL:
                return exprStmt(titer);
            case TokenType.L_CURLY:
                return compoundStmt(titer);
            default:
                return null;
        }
    }

    static function funcDecStmt(titer: PTI): Stmt {
        titer.index++;
        var symbol: SymbolLiteral = null;
        if (titer.peekIf(TokenType.SYMBOL)) {
            symbol = cast titer.next().value;
        }
        var args: Array<SymbolLiteral> = null, arg: SymbolLiteral;
        if (titer.eatIf(TokenType.L_PAREN)) {
            args = new Array<SymbolLiteral>();
            arg = titer.peekIf(TokenType.SYMBOL)? cast titer.next().value:null;
            if (arg == null) {
                titer.eatIf(R_PAREN);
            } else {
                args.push(arg);
                while (titer.eatIf(TokenType.COMMA)) {
                    arg = titer.peekIf(TokenType.SYMBOL)? cast titer.next().value:null;
                    args.push(arg);
                }
                titer.eatIf(R_PAREN);
            }
        }
        var body = statement(titer);
        return new FuncDecStmt(symbol, args, body);
    }

    static function varDecStmt(titer: PTI): Stmt {
        titer.index++;
        var symbol: SymbolLiteral = null;
        if (titer.peekIf(TokenType.SYMBOL)) {
            symbol = cast titer.next().value;
        }
        titer.eatIf(TokenType.SET);
        var value = expression(titer);
        return new VarDecStmt(symbol, value);
    }

    static function whileStmt(titer: PTI): Stmt {
        titer.index++;
        titer.eatIf(TokenType.L_PAREN);
        var condition = setExpr(titer);
        titer.eatIf(TokenType.R_PAREN);
        var stmt = statement(titer);
        return new WhileStmt(condition, stmt);
    }

    static function ifStmt(titer: PTI): Stmt {
        titer.index++;
        titer.eatIf(TokenType.L_PAREN);
        var condition = setExpr(titer);
        titer.eatIf(TokenType.R_PAREN);
        var stmt = statement(titer);
        if (titer.eatIf(TokenType.ELSE)) {
            return new IfStmt(condition, stmt, statement(titer));    
        }
        return new IfStmt(condition, stmt);
    }

    static function exprStmt(titer: PTI): Stmt {
        var token = titer.peek();
        var expr = dotFuncCallExpr(titer);
        if (!Std.is(expr, FuncCallExpr)) {
            if (titer.peekIf(TokenType.SET) || titer.peekIf(TokenType.PLUS_SET) || titer.peekIf(TokenType.MINUS_SET) || titer.peekIf(TokenType.MULT_SET) || titer.peekIf(TokenType.DIV_SET)) {
                expr = new BinaryExpression(titer.next(), expr, setExpr(titer));
            } else {
                err("Expected a statement, got an expression", token);
            }
        }
        return new ExprStmt(expr);
    }

    static function compoundStmt(titer: PTI): Stmt {
        titer.index++;
        var stmts = new Array<Stmt>(), stmt: Stmt;
        while ((stmt = statement(titer)) != null) {
            stmts.push(stmt);
        }
        titer.eatIf(TokenType.R_CURLY);
        return new CompoundStmt(stmts);
    }

    static inline function expression(titer: PTI): Expr {
        return setExpr(titer);
    }

    static function setExpr(titer: PTI): Expr {
        var expr = orExpr(titer);
        if ((Std.is(expr, Literal) || (Std.is(expr, BinaryExpression) && cast(expr, BinaryExpression).op.type == TokenType.DOT))
            && (titer.peekIf(TokenType.SET) || titer.peekIf(TokenType.PLUS_SET) || titer.peekIf(TokenType.MINUS_SET) || titer.peekIf(TokenType.MULT_SET) || titer.peekIf(TokenType.DIV_SET))) {
            return new BinaryExpression(titer.next(), expr, setExpr(titer));
        }
        return expr;
    }

    static function orExpr(titer: PTI): Expr {
        var expr = andExpr(titer);
        while (titer.peekIf(TokenType.OR)) {
            expr = new BinaryExpression(titer.next(), expr, andExpr(titer));
        }
        return expr;
    }

    static function andExpr(titer: PTI): Expr {
        var expr = comparisonExpr(titer);
        while (titer.peekIf(TokenType.AND)) {
            expr = new BinaryExpression(titer.next(), expr, comparisonExpr(titer));
        }
        return expr;
    }
    
    static function comparisonExpr(titer: PTI): Expr {
        var expr = plusMinusExpr(titer);
        while (titer.peekIf(TokenType.EQL_EQL) || titer.peekIf(TokenType.LESS) || titer.peekIf(TokenType.LESS_EQL) || titer.peekIf(TokenType.GREATER) || titer.peekIf(TokenType.GREATER_EQL)) {
            expr = new BinaryExpression(titer.next(), expr, plusMinusExpr(titer));
        }
        return expr;
    }
    
    static function plusMinusExpr(titer: PTI): Expr {
        var expr = multDivExpr(titer);
        while (titer.peekIf(TokenType.PLUS) || titer.peekIf(TokenType.MINUS)) {
            expr = new BinaryExpression(titer.next(), expr, multDivExpr(titer));
        }
        return expr;
    }

    static function multDivExpr(titer: PTI): Expr {
        var expr = unaryExpr(titer);
        while (titer.peekIf(TokenType.MULT) || titer.peekIf(TokenType.DIV)) {
            expr = new BinaryExpression(titer.next(), expr, unaryExpr(titer));
        }
        return expr;
    }

    static function unaryExpr(titer: PTI): Expr {
        if (titer.peekIf(TokenType.BANG) || titer.peekIf(TokenType.MINUS)) {
            return new UnaryExpression(titer.next(), unaryExpr(titer));
        }
        return dotFuncCallExpr(titer);
    }

    static function dotFuncCallExpr(titer: PTI): Expr {
        var expr = primary(titer);
        var args: Array<Expr>, arg: Expr;
        while (titer.eatIf(TokenType.L_PAREN)) {
            args = new Array<Expr>();
            arg = expression(titer);
            if (arg == null) {
                titer.eatIf(R_PAREN);
                expr = new FuncCallExpr(expr, args);
            } else {
                args.push(arg);
                while (titer.eatIf(TokenType.COMMA)) {
                    arg = expression(titer);
                    args.push(arg);
                }
                titer.eatIf(R_PAREN);
                expr = new FuncCallExpr(expr, args);
            }
        }
        while (titer.peekIf(TokenType.DOT)) {
            expr = new BinaryExpression(titer.next(), expr, primary(titer));
            while (titer.eatIf(TokenType.L_PAREN)) {
                args = new Array<Expr>();
                arg = expression(titer);
                if (arg == null) {
                    titer.eatIf(R_PAREN);
                    expr = new FuncCallExpr(expr, args);
                } else {
                    args.push(arg);
                    while (titer.eatIf(TokenType.COMMA)) {
                        arg = expression(titer);
                        args.push(arg);
                    }
                    titer.eatIf(R_PAREN);
                    expr = new FuncCallExpr(expr, args);
                }
            }
        }
        return expr;
    }

    static function primary(titer: PTI): Expr {
        if (titer.peekIf(TokenType.STRING)) {
            return titer.next().value;
        } else if (titer.peekIf(TokenType.NUMBER)) {
            return titer.next().value;
        } else if (titer.peekIf(TokenType.SYMBOL)) {
            return titer.next().value;
        } else if (titer.eatIf(TokenType.L_PAREN)) {
            var curr = expression(titer);
            titer.eatIf(TokenType.R_PAREN);
            return curr;
        }
        return null;
    }
}