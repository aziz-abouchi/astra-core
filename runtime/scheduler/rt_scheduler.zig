const std = @import("std");

pub const TaskId = u64;
pub const Time = u64; // nanoseconds

pub const TaskState = enum {
    Ready,
    Running,
    Blocked,
    Finished,
};

pub const Task = struct {
    id: TaskId,
    deadline: Time,
    period: Time,
    priority: u8, // 0 = highest
    state: TaskState,
    entry: fn (*anyopaque) void,
    ctx: *anyopaque,
};

pub const Cpu = struct {
    id: usize,
    current: ?*Task = null,
};

pub const Scheduler = struct {
    allocator: std.mem.Allocator,

    tasks: std.ArrayList(*Task),
    cpus: []Cpu,

    now: Time,

    pub fn init(
        allocator: std.mem.Allocator,
        cpu_count: usize,
        max_tasks: usize,
    ) !Scheduler {
        return Scheduler{
            .allocator = allocator,
            .tasks = try std.ArrayList(*Task).initCapacity(allocator, max_tasks),
            .cpus = try allocator.alloc(Cpu, cpu_count),
            .now = 0,
        };
    }

    pub fn deinit(self: *Scheduler) void {
        self.tasks.deinit(self.allocator);
        self.allocator.free(self.cpus);
    }

    // ---------- RT HARD CORE ----------

    /// Admission control (RT hard)
    pub fn admit(self: *Scheduler, task: *Task) bool {
        // Liu & Layland utilization bound (simplified)
        var u: f64 = 0.0;
        for (self.tasks.items) |t| {
            u += @as(f64, @floatFromInt(t.period)) /
                 @as(f64, @floatFromInt(t.deadline));
        }
        u += @as(f64, @floatFromInt(task.period)) /
             @as(f64, @floatFromInt(task.deadline));

        return u <= 1.0;
    }

    pub fn spawn(self: *Scheduler, task: *Task) !void {
        if (!self.admit(task))
            return error.TaskNotSchedulable;

        try self.tasks.append(task);
        task.state = .Ready;
    }

    /// EDF selection
    fn pickEDF(self: *Scheduler) ?*Task {
        var best: ?*Task = null;
        for (self.tasks.items) |t| {
            if (t.state != .Ready) continue;

            if (best == null or t.deadline < best.?.deadline) {
                best = t;
            }
        }
        return best;
    }

    /// Fixed priority fallback
    fn pickPriority(self: *Scheduler) ?*Task {
        var best: ?*Task = null;
        for (self.tasks.items) |t| {
            if (t.state != .Ready) continue;

            if (best == null or t.priority < best.?.priority) {
                best = t;
            }
        }
        return best;
    }

    /// One RT tick (deterministic)
    pub fn tick(self: *Scheduler, delta: Time) void {
        self.now += delta;

        for (self.cpus) |*cpu| {
            if (cpu.current == null or cpu.current.?.state != .Running) {
                if (self.pickEDF()) |t| {
                    cpu.current = t;
                    t.state = .Running;
                } else if (self.pickPriority()) |t| {
                    cpu.current = t;
                    t.state = .Running;
                }
            }
        }

        for (self.cpus) |*cpu| {
            if (cpu.current) |t| {
                t.entry(t.ctx);

                // deadline check
                if (self.now > t.deadline) {
                    std.debug.panic("RT HARD VIOLATION task={}", .{t.id});
                }

                // periodic reschedule
                t.deadline += t.period;
                t.state = .Ready;
                cpu.current = null;
            }
        }
    }
};
