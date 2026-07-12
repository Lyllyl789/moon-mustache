///|
fn main {
  let template =
    $|<h2>Names</h2>
    $|{{#people}}
    $|  {{> user}}
    $|{{/people}}

  let partials = Map([("user", "<strong>{{name}}</strong> ({{email}})\n")])

  let context : Json = {
    "people": [
      { "name": "Alice", "email": "alice@example.com" },
      { "name": "Bob", "email": "bob@example.com" },
    ],
  }

  try {
    let output = @mustache.render_string(template, context, partials~)
    println(output)
  } catch {
    ParseError(msg) => println("Parse error: \{msg}")
    RenderError(msg) => println("Render error: \{msg}")
  }
}
