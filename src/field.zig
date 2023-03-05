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
