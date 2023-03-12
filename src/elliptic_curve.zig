const std = @import("std");
const math = std.math;
const testing = std.testing;

const Error = error{
    NotOnCurve,
};

pub const Point = struct {
    x: ?i32,
    y: ?i32,
    a: i32,
    b: i32,

    pub fn new(x: ?i32, y: ?i32, a: i32, b: i32) !Point {
        const p = Point{
            .x = x,
            .y = y,
            .a = a,
            .b = b,
        };
        if (x == null and y == null)
            return p;
        if (math.pow(i32, y.?, 2) != math.pow(i32, x.?, 3) + a * x.? + b)
            return Error.NotOnCurve;
        return p;
    }

    pub fn eql(self: *const Point, other: *const Point) bool {
        std.debug.assert(self.a == other.a and self.b == other.b);
        return self.x == other.x and self.y == other.y;
    }

    pub fn neq(self: *const Point, other: *const Point) bool {
        return !self.eql(other);
    }

    pub fn add(self: *const Point, other: *const Point) Point {
        std.debug.assert(self.a == other.a and self.b == other.b);
        if (self.x == null)
            return other.*;
        if (other.x == null)
            return self.*;
        if (self.x == other.x and self.y != other.y)
            return Point.new(null, null, self.a, self.b) catch unreachable;
        if (self.x != other.x and self.y != other.y) {
            const s = @divExact(other.y.? - self.y.?, other.x.? - self.x.?);
            const x = math.pow(i32, s, 2) - self.x.? - other.x.?;
            const y = s * (self.x.? - x) - self.y.?;
            return Point.new(x, y, self.a, self.b) catch unreachable;
        }
        if (self.x == other.x and self.y == other.y) {
            const s = @divExact(3 * math.pow(i32, other.x.?, 2) + self.a, 2 * self.y.?);
            const x = math.pow(i32, s, 2) - 2 * self.x.?;
            const y = s * (self.x.? - x) - self.y.?;
            return Point.new(x, y, self.a, self.b) catch unreachable;
        }
        unreachable;
    }
};

test "new" {
    {
        const actual = try Point.new(-1, -1, 5, 7);
        try testing.expectEqual(Point{ .x = -1, .y = -1, .a = 5, .b = 7 }, actual);
    }
    {
        const actual = Point.new(-1, -2, 5, 7);
        try testing.expectError(Error.NotOnCurve, actual);
    }
}

test "add" {
    {
        const lhs = try Point.new(null, null, 1, 2);
        const rhs = try Point.new(1, 2, 1, 2);
        try testing.expectEqual(try Point.new(1, 2, 1, 2), lhs.add(&rhs));
    }
    {
        const lhs = try Point.new(1, 2, 1, 2);
        const rhs = try Point.new(null, null, 1, 2);
        try testing.expectEqual(try Point.new(1, 2, 1, 2), lhs.add(&rhs));
    }
    {
        const lhs = try Point.new(1, -2, 1, 2);
        const rhs = try Point.new(1, 2, 1, 2);
        try testing.expectEqual(Point.new(null, null, 1, 2), lhs.add(&rhs));
    }
    {
        const lhs = try Point.new(-1, -1, 5, 7);
        const rhs = try Point.new(-1, -1, 5, 7);
        try testing.expectEqual(Point.new(18, 77, 5, 7), lhs.add(&rhs));
    }
}
