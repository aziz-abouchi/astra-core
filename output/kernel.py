# --- Astra Python Runtime ---
def vadd(u, v): return [a + b for a, b in zip(u, v)]
def fdot(u, v): return sum(a * b for a, b in zip(u, v))
def fcross(u, v):
    return [
        u[1]*v[2] - u[2]*v[1],
        u[2]*v[0] - u[0]*v[2],
        u[0]*v[1] - u[1]*v[0]
    ]

result = vadd((1, (2) * [1,0,0]))
print(result)

