const std = @import("std");

pub const NodeTag = enum {
    function_decl,
    return_stmt,
    int_literal,
    block,
    identifier,
};

pub const Identifier = struct {
    name: []const u8,
};

pub const IntLiteral = struct {
    value: i32,
};

pub const ReturnStmt = struct {
    expr: *IntLiteral,
};

pub const Block = struct {
    statements: []const *ReturnStmt,
};

pub const FunctionDecl = struct {
    name: *Identifier,
    return_type: *Identifier,
    body: *Block,
};

pub const RootNode = FunctionDecl;
