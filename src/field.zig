const std = @import("std");
const testing = std.testing;

pub const FieldElement = struct {
    num: u32,
    prime: u32,

    pub fn format(self: *const FieldElement, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("FieldElement_{d}({d})", .{ self.prime, self.num });
    }

    pub fn eql(self: *const FieldElement, other: *const FieldElement) bool {
        return self.num == other.num and self.prime == other.prime;
    }

    pub fn add(self: *const FieldElement, other: *const FieldElement) FieldElement {
        std.debug.assert(self.prime == other.prime);
        return FieldElement{
            .num = (self.num + other.num) % self.prime,
            .prime = self.prime,
        };
    }

    pub fn sub(self: *const FieldElement, other: *const FieldElement) FieldElement {
        std.debug.assert(self.prime == other.prime);
        return FieldElement{
            .num = (self.num + self.prime - other.num) % self.prime,
            .prime = self.prime,
        };
    }

    pub fn mul(self: *const FieldElement, other: *const FieldElement) FieldElement {
        std.debug.assert(self.prime == other.prime);
        return FieldElement{
            .num = self.num * other.num % self.prime,
            .prime = self.prime,
        };
    }

    pub fn exp(self: *const FieldElement, exponential: u32) FieldElement {
        var a: u32 = 1;
        for (0..exponential) |_| {
            a *= self.num;
            a %= self.prime;
        }
        return FieldElement{
            .prime = self.prime,
            .num = a,
        };
    }

    pub fn div(self: *const FieldElement, other: *const FieldElement) FieldElement {
        std.debug.assert(self.prime == other.prime);
        return self.mul(&other.exp(self.prime - 2));
    }
};

test "format" {
    const actual = try std.fmt.allocPrint(testing.allocator, "{}", .{FieldElement{ .prime = 7, .num = 3 }});
    defer testing.allocator.free(actual);
    try testing.expectEqualStrings("FieldElement_7(3)", actual);
}

test "eql" {
    try testing.expect((FieldElement{ .prime = 7, .num = 2 }).eql(&FieldElement{ .prime = 7, .num = 2 }));
    try testing.expect(!(FieldElement{ .prime = 7, .num = 2 }).eql(&FieldElement{ .prime = 8, .num = 2 }));
    try testing.expect(!(FieldElement{ .prime = 7, .num = 2 }).eql(&FieldElement{ .prime = 7, .num = 1 }));
}

test "add" {
    const lhs = FieldElement{ .prime = 7, .num = 2 };
    const rhs = FieldElement{ .prime = 7, .num = 6 };
    try testing.expect(lhs.add(&rhs).eql(&FieldElement{ .prime = 7, .num = 1 }));
}

test "sub" {
    const lhs = FieldElement{ .prime = 7, .num = 3 };
    const rhs = FieldElement{ .prime = 7, .num = 4 };
    try testing.expect(lhs.sub(&rhs).eql(&FieldElement{ .prime = 7, .num = 6 }));
}

test "mul" {
    const lhs = FieldElement{ .prime = 7, .num = 3 };
    const rhs = FieldElement{ .prime = 7, .num = 4 };
    try testing.expect(lhs.mul(&rhs).eql(&FieldElement{ .prime = 7, .num = 5 }));
}

test "exp" {
    const base = FieldElement{ .prime = 13, .num = 3 };
    try testing.expect(base.exp(3).eql(&FieldElement{ .prime = 13, .num = 1 }));
}

test "div" {
    const lhs = FieldElement{ .prime = 19, .num = 2 };
    const rhs = FieldElement{ .prime = 19, .num = 7 };
    try testing.expect(lhs.div(&rhs).eql(&FieldElement{ .prime = 19, .num = 3 }));
}
