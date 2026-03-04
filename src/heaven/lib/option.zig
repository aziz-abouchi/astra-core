pub const Option = union(enum) {
    Some: anytype,
    None: void,
};

pub fn isSome(o: Option) bool {
    return switch(o) { .Some => true, .None => false };
}

pub fn unwrap(o: Option) anytype {
    return switch(o) { .Some => |v| v, .None => unreachable };
}
