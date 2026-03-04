pub const List = struct {
    data: []anytype,
    
    pub fn append(self: *List, item: anytype) void {
        self.data = self.data ++ [item];
    }

    pub fn map(self: *List, f: fn(anytype) anytype) *List {
        var res = List{ .data = &[]{} };
        for (self.data) |v| res.append(f(v));
        return &res;
    }

    pub fn filter(self: *List, f: fn(anytype) bool) *List {
        var res = List{ .data = &[]{} };
        for (self.data) |v| if (f(v)) res.append(v);
        return &res;
    }
};
