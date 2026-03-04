pub fn schedule(actors: []Actor) void {
    // Round-Robin TCO tail-call
    for (actors) |actor| {
        execute(actor);
    }
}

fn execute(actor: Actor) void {
    // exécute un step, applique Perform et gestion mailbox
}

