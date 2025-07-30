const std = @import("std");

pub const Loc = struct {
    start: u32,
    end: u32,
};

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Tag = enum {
        invalid,

        keyword_fn,
        keyword_return,

        identifier,
        number_literal,

        operator_plus,

        l_paren,
        r_paren,
        l_brace,
        r_brace,
        semicolon,

        eof,
    };

    const keywords = std.StaticStringMap(Tag).initComptime(.{
        .{ "fn", .keyword_fn },
        .{ "return", .keyword_return },
    });

    pub fn getKeyword(str: []const u8) ?Tag {
        return keywords.get(str);
    }
};

const Tokenizer = @This();

buf: [:0]const u8,
index: u32 = 0,

pub fn init(source: [:0]const u8) Tokenizer {
    return Tokenizer{
        .buf = source,
        .index = 0,
    };
}

pub fn next(self: *Tokenizer) Token {
    const State = enum {
        start,
        invalid,

        identifier,
        number_literal,
    };

    var result = Token{
        .tag = .invalid,
        .loc = .{
            .start = self.index,
            .end = undefined,
        },
    };

    state: switch (State.start) {
        .start => switch (self.buf[self.index]) {
            0 => {
                if (self.buf.len == self.index) {
                    return .{ .tag = .eof, .loc = .{
                        .start = self.index,
                        .end = self.index,
                    } };
                }
                continue :state .invalid;
            },
            ' ', '\n', '\t', '\r' => {
                self.index += 1;
                result.loc.start = self.index;
                continue :state .start;
            },
            '0'...'9' => {
                result.tag = .number_literal;
                continue :state .number_literal;
            },
            'a'...'z', 'A'...'Z' => {
                result.tag = .identifier;
                continue :state .identifier;
            },
            '(' => {
                result.tag = .l_paren;
                self.index += 1;
            },
            ')' => {
                result.tag = .r_paren;
                self.index += 1;
            },
            '{' => {
                result.tag = .l_brace;
                self.index += 1;
            },
            '}' => {
                result.tag = .r_brace;
                self.index += 1;
            },
            ';' => {
                result.tag = .semicolon;
                self.index += 1;
            },
            '+' => {
                result.tag = .operator_plus;
                self.index += 1;
            },
            else => continue :state .invalid,
        },
        .identifier => {
            self.index += 1;
            switch (self.buf[self.index]) {
                'a'...'z', 'A'...'Z', '_', '0'...'9' => continue :state .identifier,
                else => {
                    const text = self.buf[result.loc.start..self.index];
                    if (Token.getKeyword(text)) |tag| {
                        result.tag = tag;
                    }
                },
            }
        },
        .number_literal => {
            self.index += 1;
            switch (self.buf[self.index]) {
                '0'...'9' => continue :state .number_literal,
                else => {},
            }
        },
        .invalid => switch (self.buf[self.index]) {
            ' ', '\n', '\t', '\r' => {
                result.tag = .invalid;
            },
            else => {
                self.index += 1;
                continue :state .invalid;
            },
        },
    }

    result.loc.end = self.index;
    return result;
}

pub fn tokenize(self: *Tokenizer, allocator: std.mem.Allocator) !std.MultiArrayList(Token) {
    var list = std.MultiArrayList(Token){};

    while (true) {
        const token = self.next();
        try list.append(allocator, token);
        if (token.tag == .eof) break;
    }

    return list;
}
