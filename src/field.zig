const std = @import("std");
const testing = std.testing;

const Error = error{
    InvalidPrime,
};

const FieldElement = struct {
    num: u32,
    prime: u32,

    fn repl(self: *const FieldElement, buf: []u8) std.fmt.BufPrintError![]u8 {
        return try std.fmt.bufPrint(buf, "FieldElement_{d}({d})", .{ self.prime, self.num });
    }

    fn eql(self: *const FieldElement, other: *const FieldElement) bool {
        return self.num == other.num and self.prime == other.prime;
    }

    fn add(self: *const FieldElement, other: *const FieldElement) anyerror!FieldElement {
        if (self.prime != other.prime) {
            return Error.InvalidPrime;
        }
        return FieldElement{
            .num = (self.num + other.num) % self.prime,
            .prime = self.prime,
        };
    }

    fn sub(self: *const FieldElement, other: *const FieldElement) anyerror!FieldElement {
        if (self.prime != other.prime) {
            return Error.InvalidPrime;
        }
        return FieldElement{
            .num = (self.num + self.prime - other.num) % self.prime,
            .prime = self.prime,
        };
    }
};

test "repl" {
    const e = FieldElement{ .prime = 1, .num = 2 };
    var buf = try testing.allocator.alloc(u8, 1024);
    defer testing.allocator.free(buf);
    try testing.expectEqualStrings("FieldElement_1(2)", try e.repl(buf));
}

test "eql" {
    try testing.expect((FieldElement{ .prime = 7, .num = 2 }).eql(&FieldElement{ .prime = 7, .num = 2 }));
    try testing.expect(!(FieldElement{ .prime = 7, .num = 2 }).eql(&FieldElement{ .prime = 8, .num = 2 }));
    try testing.expect(!(FieldElement{ .prime = 7, .num = 2 }).eql(&FieldElement{ .prime = 7, .num = 1 }));
}

test "add" {
    const lhs = FieldElement{ .prime = 7, .num = 2 };
    const rhs = FieldElement{ .prime = 7, .num = 6 };
    const expected = FieldElement{ .prime = 7, .num = 1 };
    const actual = try lhs.add(&rhs);
    try testing.expect(actual.eql(&expected));
}

test "sub" {
    const lhs = FieldElement{ .prime = 7, .num = 3 };
    const rhs = FieldElement{ .prime = 7, .num = 4 };
    const actual = try lhs.sub(&rhs);
    const expected = FieldElement{ .prime = 7, .num = 6 };
    try testing.expect(actual.eql(&expected));
}
