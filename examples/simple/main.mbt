///|
fn main {
  let template =
    $|Hello {{name}}!
    $|Welcome to {{location}}.
    $|{{#skills}}
    $|- {{.}}
    $|{{/skills}}

  let context : Json = {
    "name": "Lu Yilu",
    "location": "Beijing, China",
    "skills": ["MoonBit", "WebAssembly", "Mustache"],
  }

  try {
    let output = @mustache.render_string(template, context)
    println(output)
  } catch {
    ParseError(msg) => println("Parse error: \{msg}")
    RenderError(msg) => println("Render error: \{msg}")
  }
}
