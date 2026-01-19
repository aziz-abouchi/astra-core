#!/usr/bin/env python3
import sys
import pandas as pd

if len(sys.argv) < 3:
    print("usage: csv_to_parquet.py <input.csv> <output.parquet>")
    sys.exit(1)

inp, out = sys.argv[1], sys.argv[2]
df = pd.read_csv(inp)
df.to_parquet(out, engine="pyarrow", index=False)
print(f"[ok] wrote {out}")
