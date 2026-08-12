# Third-party notices

## Mustache specification tests

The file `mustache/spec_test.mbt` is generated from the JSON fixtures in the
public [`mustache/spec`](https://github.com/mustache/spec) repository. The
fixtures are used only as behavioral regression data; the runtime lexer,
parser, AST, context resolver, and renderer in this repository are original
MoonBit implementation code.

The fixture source and its license metadata remain with the upstream project.
To refresh the local copy, run `python gen_specs.py` and review the generated
diff. The generator's explicit skip list documents behavior not claimed by
this release.

## Dependencies

Runtime dependency: `moonbitlang/core/json`, supplied through the MoonBit
ecosystem. No vendored dependency or generated third-party source is checked
into the runtime packages.
