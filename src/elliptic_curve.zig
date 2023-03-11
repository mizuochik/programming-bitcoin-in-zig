const std = @import("std");
const math = std.math;
const testing = std.testing;

const Error = error{
    NotOnCurve,
};

pub const Point = struct {
    x: i32,
    y: i32,
    a: i32,
    b: i32,

    pub fn new(x: i32, y: i32, a: i32, b: i32) !Point {
        if (math.pow(i32, y, 2) != math.pow(i32, x, 3) + a * x + b) {
            return Error.NotOnCurve;
        }
        return Point{
            .x = x,
            .y = y,
            .a = a,
            .b = b,
        };
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
