# moon-mustache

`moon-mustache` is a pure MoonBit implementation of the Mustache template engine.
It targets WebAssembly, JavaScript, and native backends, with a strong focus on
predictable rendering rules, small surface area, and easy integration into other
MoonBit projects.

## Project Summary

- Project name: `moon-mustache`
- Module name: `Lyllyl789/mustache`
- License: MIT
- Toolchain target: MoonBit `0.10.3`
- Manifest format: current `moon.mod` / `moon.pkg`

## What It Supports

- Standard interpolation: `{{var}}`
- Unescaped interpolation: `{{{var}}}` and `{{&var}}`
- Sections: `{{#var}}...{{/var}}`
- Inverted sections: `{{^var}}...{{/var}}`
- Comments: `{{! comment }}`
- Partials: `{{> partial}}`
- Delimiter changes: `{{=<% %>=}}`
- Standalone tag trimming for comments, sections, partials, and delimiter changes
- Dotted lookup: `{{user.profile.name}}`
- Implicit iterator support with `{{.}}`

## Repository Layout

- `mustache/` - core parser, renderer, lexer, AST, context, and tests
- `examples/simple/` - minimal rendering example
- `examples/partials/` - partial rendering example
- `README.md` - project overview and usage
- `LICENSE` - MIT license

## Quick Start

### 1. Add the dependency

In your MoonBit project, import the module:

```moonbit
import {
  "Lyllyl789/mustache/mustache",
}
```

### 2. Render a template

```moonbit
fn main {
  let template = "Hello {{name}}! Welcome to {{location}}."
  let context : Json = {
    "name": "Lu Yilu",
    "location": "Beijing, China"
  }

  try {
    let output = @mustache.render_string(template, context)
    println(output)
  } catch {
    ParseError(msg) => println("Parse error: \{msg}")
    RenderError(msg) => println("Render error: \{msg}")
  }
}
```

### 3. Run the examples

```bash
moon run examples/simple
moon run examples/partials
```

## Verification

Run these commands from the repository root:

```bash
moon check
moon fmt --warn
moon info
moon test
```

The CI workflow in `.github/workflows/ci.yml` runs the same validation steps on
every push and pull request.

## Development Notes

The implementation is intentionally small and modular:

- `lexer.mbt` converts Mustache syntax into tokens
- `parser.mbt` turns tokens into an AST
- `context.mbt` resolves variables and dotted paths
- `render.mbt` executes the AST against input JSON
- `mustache_test.mbt` covers interpolation, sections, inverted sections,
  comments, delimiter changes, partials, dotted lookup, implicit iterators, and
  standalone tag trimming

## Retrospective

- The renderer keeps parsing, context resolution, and output generation separate
  so each part can evolve independently.
- The test suite focuses on core Mustache behavior instead of a single happy path.
- MoonBit's built-in checks make it practical to keep formatting, interface
  generation, and tests in a single reproducible workflow.

## License

This project is released under the [MIT License](LICENSE).

## Production API and safety boundaries

The stable entry points are `compile`, `render_string`, and
`Template::render`. Templates are compiled into an AST once and can then be
rendered repeatedly with different JSON contexts. Rendering is synchronous,
deterministic, and has no filesystem, network, or process dependencies.

For services that accept user-controlled templates or partials, use
`RenderOptions` with `render_string_with_options` or
`Template::render_with_options`:

```moonbit
let options = @mustache.RenderOptions::new(
  max_partial_depth=32,
  missing_partial_is_error=true,
)
let html = @mustache.render_string_with_options(
  template,
  context,
  partials,
  options,
)
```

The default behavior remains compatible with Mustache: a missing partial is
rendered as an empty string. The explicit options API adds two operational
guards: a bounded partial recursion depth to prevent accidental infinite
expansion, and strict missing-partial errors for deployments that require
complete template bundles. Invalid limits are rejected before rendering.

## Behavior and boundary matrix

| Area | Supported behavior | Boundary covered by tests |
| --- | --- | --- |
| Lookup | names, dotted paths, `.` iterator | missing keys, nested objects, arrays |
| Sections | truthy values, arrays, objects, inverted sections | empty arrays, false, null, nested contexts |
| Escaping | HTML escaping and triple/ampersand raw output | `&`, `<`, `>`, quotes, apostrophes |
| Layout | comments, standalone lines, CRLF, indented partials | inline vs standalone tags |
| Syntax | delimiter changes and nested sections | mismatched/unclosed tags |
| Partials | nesting, recursion, inherited context | missing partials and depth limits |

The executable regression suite contains the upstream Mustache specification
cases plus project-specific safety tests. The generated specification fixture
is produced by `gen_specs.py`; its source, license, skipped cases, and exact
regeneration command are documented in [TESTING.md](TESTING.md).

## Reproducible verification

Run from the repository root:

```bash
moon version --all
moon update
moon check --target all --deny-warn
moon fmt --warn
moon info
moon test --target all
moon run examples/simple
moon run examples/partials
moon run examples/complex_html
```

The CI workflow repeats check, format, interface, and multi-target tests on
Linux, macOS, and Windows. JavaScript execution additionally requires
`node` to be available on the runner.

## Open-source compliance

This repository contains original MoonBit implementation code under MIT. The
Mustache regression cases are generated from the public
[`mustache/spec`](https://github.com/mustache/spec) repository; they are test
fixtures, not copied runtime implementation. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)
for provenance, regeneration, and redistribution notes. No private code,
credentials, generated vendored dependency, or runtime service is required.

## Release checklist

Before publishing a version, verify that the default branch contains the same
README, license, CI workflow, generated interface files, examples, and tests;
then run the commands above and publish the exact `moon.mod` version to
mooncakes.io. The repository remotes are intentionally not modified or pushed
by local validation.
