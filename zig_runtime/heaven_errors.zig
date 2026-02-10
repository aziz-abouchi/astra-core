pub fn typeError(msg: []const u8) noreturn {
    @panic(msg);
}

