const std = @import("std");
const Loc = @import("Tokenizer.zig").Loc;

pub const Identifier = struct {
    loc: Loc,

    pub fn dump(self: *Identifier, comptime level: i32) void {
        const indent = "\t" ** level;
        std.debug.print("{s}Identifier: [{d}..{d}]\n", .{ indent, self.loc.start, self.loc.end });
    }
};

pub const IntLiteral = struct {
    value: i32,

    pub fn dump(self: *IntLiteral, comptime level: i32) void {
        const indent = "\t" ** level;
        std.debug.print("{s}IntLiteral: {d}\n", .{ indent, self.value });
    }
};

pub const BinaryOperator = enum {
    add,
};

pub const Expression = union(enum) {
    number: *IntLiteral,
    binary: struct {
        operator: BinaryOperator,
        lhs: *Expression,
        rhs: *Expression,
    },
};

pub const ReturnStmt = struct {
    expr: *Expression,

    pub fn dump(self: *ReturnStmt, comptime level: i32) void {
        const indent = "\t" ** level;
        std.debug.print("{s}ReturnStmt\n", .{indent});
        self.expr.dump(level + 1);
    }
};

pub const Block = struct {
    statements: []const *ReturnStmt,

    pub fn dump(self: *Block, comptime level: i32) void {
        const indent = "\t" ** level;
        std.debug.print("{s}Block:\n", .{indent});

        for (self.statements) |statement| {
            statement.dump(level + 1);
        }
    }
};

pub const FunctionDecl = struct {
    name: *Identifier,
    return_type: *Identifier,
    body: *Block,

    pub fn dump(self: *FunctionDecl, comptime level: i32) void {
        const indent = "\t" ** level;
        std.debug.print("{s}FunctionDecl:\n", .{indent});

        self.name.dump(level + 1);
        self.return_type.dump(level + 1);
        self.body.dump(level + 1);
    }
};

pub const RootNode = FunctionDecl;
