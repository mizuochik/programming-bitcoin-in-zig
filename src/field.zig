const std = @import("std");
const testing = std.testing;

const FieldElement = struct {
    num: f16,
    prime: i16,

    fn repl(self: *const FieldElement, buf: []u8) std.fmt.BufPrintError![]u8 {
        return try std.fmt.bufPrint(buf, "FieldElement_{d}({d})", .{ self.prime, self.num });
    }

    fn eql(self: *const FieldElement, other: *const FieldElement) bool {
        return self.num == other.num and self.prime == other.prime;
    }
};

test "repl" {
    const e = FieldElement{ .prime = 1, .num = 2 };
    var buf = try testing.allocator.alloc(u8, 1024);
    defer testing.allocator.free(buf);
    try testing.expectEqualStrings("FieldElement_1(2)", try e.repl(buf));
}

test "eql" {
    try testing.expect((FieldElement{ .prime = 1, .num = 2 }).eql(&FieldElement{ .prime = 1, .num = 2 }));
    try testing.expect(!(FieldElement{ .prime = 1, .num = 2 }).eql(&FieldElement{ .prime = 2, .num = 2 }));
    try testing.expect(!(FieldElement{ .prime = 1, .num = 2 }).eql(&FieldElement{ .prime = 1, .num = 1 }));
}
