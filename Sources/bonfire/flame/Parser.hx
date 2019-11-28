package bonfire.flame;

import bonfire.flame.Expr;
import bonfire.flame.Token;
import bonfire.flame.utils.Iterators.PeekableTokenIterator in PTI;

class Parser {
    static var hadError: Bool;

    public static function parse(tokens: Array<Token>): Expr {
        var titer = new PTI(tokens);
        hadError = false;
        var curr = expression(titer);
        titer.eatIf(TokenType.EOF);
        return curr;
    }

    static inline function expression(titer: PTI): Expr {
        return setExpr(titer);
    }

    static function setExpr(titer: PTI): Expr {
        var expr = orExpr(titer);
        if ((Std.is(expr, Literal) || (Std.is(expr, BinaryExpression) && cast(expr, BinaryExpression).op.type == TokenType.DOT))
            && (titer.peekIf(TokenType.SET) || titer.peekIf(TokenType.PLUS_SET) || titer.peekIf(TokenType.MINUS_SET) || titer.peekIf(TokenType.MULT_SET) || titer.peekIf(TokenType.DIV_SET))) {
            return new BinaryExpression(titer.next(), expr, orExpr(titer));
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
        return dotExpr(titer);
    }

    static function dotExpr(titer: PTI): Expr {
        var expr = primary(titer);
        while (titer.peekIf(TokenType.DOT)) {
            expr = new BinaryExpression(titer.next(), expr, primary(titer));
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