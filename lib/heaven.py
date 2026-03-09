def smul(s, v):
    return [s * x for x in v]

def vadd(u, v):
    return [x + y for x, y in zip(u, v)]
