const std = @import("std");

const Tokenizer = @import("Tokenizer.zig");
const Parser = @import("Parser.zig");

const Token = enum { Keyword };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var tokens_arena = std.heap.ArenaAllocator.init(allocator);
    defer tokens_arena.deinit();
    // const tokens_allocator = tokens_arena.allocator();

    // var ast_arena = std.heap.ArenaAllocator.init(allocator);
    // defer ast_arena.deinit();
    // const ast_allocator = ast_arena.allocator();

    const source = try std.fs.cwd().readFileAllocOptions(allocator, "test.em", 1024 * 1024, null, @alignOf(u8), 0);
    defer allocator.free(source);

    var tokenizer = Tokenizer.init(source);
    // const tokens = try tokenizer.tokenize(tokens_allocator);
    while (true) {
        const token = tokenizer.next();
        if (token.tag == .eof) {
            break;
        }
        std.debug.print("{s}: {s}\n", .{ @tagName(token.tag), source[token.loc.start..token.loc.end] });
    }

    // var parser = Parser.init(ast_allocator, source, tokens);
    // const rootnode = try parser.parse();
    // rootnode.dump(0);
}
