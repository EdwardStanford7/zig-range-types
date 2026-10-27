fn in_bounds_or_fail(comptime a: anytype, b: usize.range(0, a.len)) if (b >= a.len) noreturn else bool {
    if (b >= a.len) @trap();
    return true;
}

pub fn main() void {
    const aa: [5]i64 = .{ 1, 2, 3, 6, 3 };
    _ = in_bounds_or_fail(aa, 5);
    @compileError("die!");
}
