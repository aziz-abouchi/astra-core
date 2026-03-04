pub const Actor = struct {
    id: usize,
    state: State,
    mailbox: Mailbox,
};

pub const State = struct {
    fields: []Field,
};

pub const Field = struct {
    name: []const u8,
    typ: []const u8,
    mutable: bool,
};

pub fn spawn(actor: Actor) void {
    // ajoute l'acteur au scheduler
}

