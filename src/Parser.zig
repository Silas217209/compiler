const std = @import("std");
const Tokenizer = @import("Tokenizer.zig");
const AST = @import("Ast.zig");

const Token = Tokenizer.Token;

source: [:0]const u8,
tokens: std.MultiArrayList(Token),
pos: u32,
allocator: std.mem.Allocator,

const Self = @This();

pub fn init(allocator: std.mem.Allocator, source: [:0]const u8, tokens: std.MultiArrayList(Token)) Self {
    return .{
        .source = source,
        .allocator = allocator,
        .tokens = tokens,
        .pos = 0,
    };
}

fn peek(self: *Self) ?Token.Tag {
    if (self.pos < self.tokens.len) {
        return self.tokens.items(.tag)[self.pos];
    } else {
        return null;
    }
}

fn advance(self: *Self) Token {
    const tok = self.tokens.get(self.pos);
    self.pos += 1;
    return tok;
}

fn expect(self: *Self, expected: Token.Tag) !Token {
    const tag = self.peek() orelse return error.UnecpectedEOF;
    if (tag != expected) {
        return error.UnexpectedToken;
    }
    return self.advance();
}

pub fn parse(self: *Self) !*AST.RootNode {
    return try self.parseFunction();
}

pub fn parseFunction(self: *Self) !*AST.FunctionDecl {
    _ = try self.expect(.keyword_fn);
    const fn_name = try self.parseIdentifier();
    _ = try self.expect(.l_paren);
    _ = try self.expect(.r_paren);
    const type_name = try self.parseIdentifier();
    const block = try self.parseBlock();

    const node = try self.allocator.create(AST.FunctionDecl);
    node.* = .{
        .body = block,
        .name = fn_name,
        .return_type = type_name,
    };

    return node;
}

fn parseBlock(self: *Self) !*AST.Block {
    _ = try self.expect(.l_brace);
    const statement = try self.parseStatement();
    _ = try self.expect(.r_brace);

    const stmts = try self.allocator.alloc(*AST.ReturnStmt, 1);
    stmts[0] = statement;

    const node = try self.allocator.create(AST.Block);
    node.* = .{
        .statements = stmts,
    };

    return node;
}

pub fn parseStatement(self: *Self) !*AST.ReturnStmt {
    _ = try self.expect(.keyword_return);
    const expression = try self.parseExpression();
    _ = try self.expect(.semicolon);

    const node = try self.allocator.create(AST.ReturnStmt);
    node.* = .{
        .expr = expression,
    };

    return node;
}

pub fn parseIntLiteral(self: *Self) !*AST.IntLiteral {
    const number = try self.expect(.number_literal);
    const integer = try std.fmt.parseInt(i32, self.source[number.loc.start..number.loc.end], 10);

    const node = try self.allocator.create(AST.IntLiteral);
    node.* = .{ .value = integer };

    return node;
}

fn parseIdentifier(self: *Self) !*AST.Identifier {
    const identifier = try self.expect(.identifier);

    const node = try self.allocator.create(AST.Identifier);
    node.* = .{
        .loc = identifier.loc,
    };

    return node;
}
