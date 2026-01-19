pub const Transport = interface {
    send([]u8) !void,
    recv() ![]u8,
};
