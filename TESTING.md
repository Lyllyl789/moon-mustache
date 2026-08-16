# Testing and benchmark protocol

## Test layers

1. `mustache/mustache_test.mbt` covers the public API and representative
   rendering paths.
2. `mustache/spec_test.mbt` contains the generated Mustache specification
   regression suite.
3. `mustache/options_test.mbt` covers strict partial handling, invalid limits,
   and recursive partial protection.
4. `mustache/production_test.mbt` covers Unicode escaping, stats,
   output/context/node limits,
   analysis, validation, cache eviction, batch mismatch handling, bundles,
   catalogs, source locations, checked plans, and registry rollout behavior.
5. `examples/*` are runnable integration fixtures and provide human-readable
   output for demos.

The local baseline on MoonBit 0.10.7 is 161 passing tests for the WASM-GC
target. The full CI matrix runs all targets supported by the installed
toolchain. The implementation line-count audit excludes `*_test.mbt`, the
generated `pkg.generated.mbti` interface, and unrelated workspace folders; the
current core runtime audit is 3051 effective lines (3862 including
documentation comments).

## Re-generating the specification fixture

```bash
python gen_specs.py
moon fmt --check
moon test --target wasm-gc
```

`gen_specs.py` downloads the six JSON files from the upstream Mustache
specification repository and records them as MoonBit tests. The official
scalar-section, deeply nested context, inline partial indentation, and
standalone partial indentation cases are included in the generated suite.

## Benchmark protocol

The three examples are the repeatable application fixtures:

| Fixture | Scenario | Expected signal |
| --- | --- | --- |
| `simple` | scalar interpolation and list rendering | escaped output is deterministic |
| `partials` | reusable HTML fragment with an array section | partial context is preserved |
| `complex_html` | nested user records, roles, and HTML layout | realistic multi-record output |

For a local timing sample, run each command 30 times in a warm shell and
record the median wall-clock time, toolchain version, target, and machine in
the release notes. Do not compare timings across targets or MoonBit versions
without recording those fields.
