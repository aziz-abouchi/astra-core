# lib/heaven.py
def smul(s, v):
    return [s * x for x in v]

def vadd(u, v):
    return [x + y for x, y in zip(u, v)]

def dot(u, v):
    return sum(x * y for x, y in zip(u, v))

def cross(u, v):
    return [
        u[1] * v[2] - u[2] * v[1],
        u[2] * v[0] - u[0] * v[2],
        u[0] * v[1] - u[1] * v[0]
    ]
