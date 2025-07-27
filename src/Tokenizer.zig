const std = @import("std");

pub const Token = struct {
    tag: Tag,
    lexeme: []const u8,

    pub const Tag = enum {
        invalid,

        keyword_fn,
        keyword_return,

        identifier,
        number_literal,

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

    var start = self.index;

    var result = Token{
        .tag = .invalid,
        .lexeme = undefined,
    };

    state: switch (State.start) {
        .start => switch (self.buf[self.index]) {
            0 => {
                if (self.buf.len == self.index) {
                    return .{
                        .tag = .eof,
                        .lexeme = &.{},
                    };
                }
                continue :state .invalid;
            },
            ' ', '\n', '\t', '\r' => {
                self.index += 1;
                start = self.index;
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
            else => continue :state .invalid,
        },
        .identifier => {
            self.index += 1;
            switch (self.buf[self.index]) {
                'a'...'z', 'A'...'Z', '_', '0'...'9' => continue :state .identifier,
                else => {
                    const text = self.buf[start..self.index];
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

    result.lexeme = self.buf[start..self.index];
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
