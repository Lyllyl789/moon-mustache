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
