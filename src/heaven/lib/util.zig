pub fn range(start: i32, stop: i32, step: i32) []i32 {
    var arr: []i32 = &[]{};
    var i = start;
    while (i < stop) : (i += step) arr = arr ++ [i];
    return arr;
}

pub fn factorial(n: i32) i32 {
    var res = 1;
    for (range(1, n+1, 1)) |v| res *= v;
    return res;
}
