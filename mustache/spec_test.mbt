///|
test "interpolation.json - No Interpolation" {
  // Mustache-free templates should render as-is.
  let template = "Hello from {Mustache}!\n"
  let data_str = "{}"
  let expected = "Hello from {Mustache}!\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Basic Interpolation" {
  // Unadorned tags should interpolate content into the template.
  let template = "Hello, {{subject}}!\n"
  let data_str = "{\"subject\": \"world\"}"
  let expected = "Hello, world!\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - No Re-interpolation" {
  // Interpolated tag output should not be re-interpolated.
  let template = "{{template}}: {{planet}}"
  let data_str = "{\"template\": \"{{planet}}\", \"planet\": \"Earth\"}"
  let expected = "{{planet}}: Earth"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - HTML Escaping" {
  // Basic interpolation should be HTML escaped.
  let template = "These characters should be HTML escaped: {{forbidden}}\n"
  let data_str = "{\"forbidden\": \"& \\\" < >\"}"
  let expected = "These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache" {
  // Triple mustaches should interpolate without HTML escaping.
  let template = "These characters should not be HTML escaped: {{{forbidden}}}\n"
  let data_str = "{\"forbidden\": \"& \\\" < >\"}"
  let expected = "These characters should not be HTML escaped: & \" < >\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand" {
  // Ampersand should interpolate without HTML escaping.
  let template = "These characters should not be HTML escaped: {{&forbidden}}\n"
  let data_str = "{\"forbidden\": \"& \\\" < >\"}"
  let expected = "These characters should not be HTML escaped: & \" < >\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Basic Integer Interpolation" {
  // Integers should interpolate seamlessly.
  let template = "\"{{mph}} miles an hour!\""
  let data_str = "{\"mph\": 85}"
  let expected = "\"85 miles an hour!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache Integer Interpolation" {
  // Integers should interpolate seamlessly.
  let template = "\"{{{mph}}} miles an hour!\""
  let data_str = "{\"mph\": 85}"
  let expected = "\"85 miles an hour!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand Integer Interpolation" {
  // Integers should interpolate seamlessly.
  let template = "\"{{&mph}} miles an hour!\""
  let data_str = "{\"mph\": 85}"
  let expected = "\"85 miles an hour!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Basic Decimal Interpolation" {
  // Decimals should interpolate seamlessly with proper significance.
  let template = "\"{{power}} jiggawatts!\""
  let data_str = "{\"power\": 1.21}"
  let expected = "\"1.21 jiggawatts!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache Decimal Interpolation" {
  // Decimals should interpolate seamlessly with proper significance.
  let template = "\"{{{power}}} jiggawatts!\""
  let data_str = "{\"power\": 1.21}"
  let expected = "\"1.21 jiggawatts!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand Decimal Interpolation" {
  // Decimals should interpolate seamlessly with proper significance.
  let template = "\"{{&power}} jiggawatts!\""
  let data_str = "{\"power\": 1.21}"
  let expected = "\"1.21 jiggawatts!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Basic Null Interpolation" {
  // Nulls should interpolate as the empty string.
  let template = "I ({{cannot}}) be seen!"
  let data_str = "{\"cannot\": null}"
  let expected = "I () be seen!"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache Null Interpolation" {
  // Nulls should interpolate as the empty string.
  let template = "I ({{{cannot}}}) be seen!"
  let data_str = "{\"cannot\": null}"
  let expected = "I () be seen!"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand Null Interpolation" {
  // Nulls should interpolate as the empty string.
  let template = "I ({{&cannot}}) be seen!"
  let data_str = "{\"cannot\": null}"
  let expected = "I () be seen!"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Basic Context Miss Interpolation" {
  // Failed context lookups should default to empty strings.
  let template = "I ({{cannot}}) be seen!"
  let data_str = "{}"
  let expected = "I () be seen!"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache Context Miss Interpolation" {
  // Failed context lookups should default to empty strings.
  let template = "I ({{{cannot}}}) be seen!"
  let data_str = "{}"
  let expected = "I () be seen!"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand Context Miss Interpolation" {
  // Failed context lookups should default to empty strings.
  let template = "I ({{&cannot}}) be seen!"
  let data_str = "{}"
  let expected = "I () be seen!"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Basic Interpolation" {
  // Dotted names should be considered a form of shorthand for sections.
  let template = "\"{{person.name}}\" == \"{{#person}}{{name}}{{/person}}\""
  let data_str = "{\"person\": {\"name\": \"Joe\"}}"
  let expected = "\"Joe\" == \"Joe\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Triple Mustache Interpolation" {
  // Dotted names should be considered a form of shorthand for sections.
  let template = "\"{{{person.name}}}\" == \"{{#person}}{{{name}}}{{/person}}\""
  let data_str = "{\"person\": {\"name\": \"Joe\"}}"
  let expected = "\"Joe\" == \"Joe\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Ampersand Interpolation" {
  // Dotted names should be considered a form of shorthand for sections.
  let template = "\"{{&person.name}}\" == \"{{#person}}{{&name}}{{/person}}\""
  let data_str = "{\"person\": {\"name\": \"Joe\"}}"
  let expected = "\"Joe\" == \"Joe\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Arbitrary Depth" {
  // Dotted names should be functional to any level of nesting.
  let template = "\"{{a.b.c.d.e.name}}\" == \"Phil\""
  let data_str = "{\"a\": {\"b\": {\"c\": {\"d\": {\"e\": {\"name\": \"Phil\"}}}}}}"
  let expected = "\"Phil\" == \"Phil\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Broken Chains" {
  // Any falsey value prior to the last part of the name should yield ''.
  let template = "\"{{a.b.c}}\" == \"\""
  let data_str = "{\"a\": {}}"
  let expected = "\"\" == \"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Broken Chain Resolution" {
  // Each part of a dotted name should resolve only against its parent.
  let template = "\"{{a.b.c.name}}\" == \"\""
  let data_str = "{\"a\": {\"b\": {}}, \"c\": {\"name\": \"Jim\"}}"
  let expected = "\"\" == \"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Initial Resolution" {
  // The first part of a dotted name should resolve as any other name.
  let template = "\"{{#a}}{{b.c.d.e.name}}{{/a}}\" == \"Phil\""
  let data_str = "{\"a\": {\"b\": {\"c\": {\"d\": {\"e\": {\"name\": \"Phil\"}}}}}, \"b\": {\"c\": {\"d\": {\"e\": {\"name\": \"Wrong\"}}}}}"
  let expected = "\"Phil\" == \"Phil\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - Context Precedence" {
  // Dotted names should be resolved against former resolutions.
  let template = "{{#a}}{{b.c}}{{/a}}"
  let data_str = "{\"a\": {\"b\": {}}, \"b\": {\"c\": \"ERROR\"}}"
  let expected = ""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names are never single keys" {
  // Dotted names shall not be parsed as single, atomic keys
  let template = "{{a.b}}"
  let data_str = "{\"a.b\": \"c\"}"
  let expected = ""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Dotted Names - No Masking" {
  // Dotted Names in a given context are unvavailable due to dot splitting
  let template = "{{a.b}}"
  let data_str = "{\"a.b\": \"c\", \"a\": {\"b\": \"d\"}}"
  let expected = "d"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Implicit Iterators - Basic Interpolation" {
  // Unadorned tags should interpolate content into the template.
  let template = "Hello, {{.}}!\n"
  let data_str = "\"world\""
  let expected = "Hello, world!\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Implicit Iterators - HTML Escaping" {
  // Basic interpolation should be HTML escaped.
  let template = "These characters should be HTML escaped: {{.}}\n"
  let data_str = "\"& \\\" < >\""
  let expected = "These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Implicit Iterators - Triple Mustache" {
  // Triple mustaches should interpolate without HTML escaping.
  let template = "These characters should not be HTML escaped: {{{.}}}\n"
  let data_str = "\"& \\\" < >\""
  let expected = "These characters should not be HTML escaped: & \" < >\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Implicit Iterators - Ampersand" {
  // Ampersand should interpolate without HTML escaping.
  let template = "These characters should not be HTML escaped: {{&.}}\n"
  let data_str = "\"& \\\" < >\""
  let expected = "These characters should not be HTML escaped: & \" < >\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Implicit Iterators - Basic Integer Interpolation" {
  // Integers should interpolate seamlessly.
  let template = "\"{{.}} miles an hour!\""
  let data_str = "85"
  let expected = "\"85 miles an hour!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Interpolation - Surrounding Whitespace" {
  // Interpolation should not alter surrounding whitespace.
  let template = "| {{string}} |"
  let data_str = "{\"string\": \"---\"}"
  let expected = "| --- |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache - Surrounding Whitespace" {
  // Interpolation should not alter surrounding whitespace.
  let template = "| {{{string}}} |"
  let data_str = "{\"string\": \"---\"}"
  let expected = "| --- |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand - Surrounding Whitespace" {
  // Interpolation should not alter surrounding whitespace.
  let template = "| {{&string}} |"
  let data_str = "{\"string\": \"---\"}"
  let expected = "| --- |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Interpolation - Standalone" {
  // Standalone interpolation should not alter surrounding whitespace.
  let template = "  {{string}}\n"
  let data_str = "{\"string\": \"---\"}"
  let expected = "  ---\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache - Standalone" {
  // Standalone interpolation should not alter surrounding whitespace.
  let template = "  {{{string}}}\n"
  let data_str = "{\"string\": \"---\"}"
  let expected = "  ---\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand - Standalone" {
  // Standalone interpolation should not alter surrounding whitespace.
  let template = "  {{&string}}\n"
  let data_str = "{\"string\": \"---\"}"
  let expected = "  ---\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Interpolation With Padding" {
  // Superfluous in-tag whitespace should be ignored.
  let template = "|{{ string }}|"
  let data_str = "{\"string\": \"---\"}"
  let expected = "|---|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Triple Mustache With Padding" {
  // Superfluous in-tag whitespace should be ignored.
  let template = "|{{{ string }}}|"
  let data_str = "{\"string\": \"---\"}"
  let expected = "|---|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "interpolation.json - Ampersand With Padding" {
  // Superfluous in-tag whitespace should be ignored.
  let template = "|{{& string }}|"
  let data_str = "{\"string\": \"---\"}"
  let expected = "|---|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Truthy" {
  // Truthy sections should have their contents rendered.
  let template = "\"{{#boolean}}This should be rendered.{{/boolean}}\""
  let data_str = "{\"boolean\": true}"
  let expected = "\"This should be rendered.\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Falsey" {
  // Falsey sections should have their contents omitted.
  let template = "\"{{#boolean}}This should not be rendered.{{/boolean}}\""
  let data_str = "{\"boolean\": false}"
  let expected = "\"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Null is falsey" {
  // Null is falsey.
  let template = "\"{{#null}}This should not be rendered.{{/null}}\""
  let data_str = "{\"null\": null}"
  let expected = "\"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Context" {
  // Objects and hashes should be pushed onto the context stack.
  let template = "\"{{#context}}Hi {{name}}.{{/context}}\""
  let data_str = "{\"context\": {\"name\": \"Joe\"}}"
  let expected = "\"Hi Joe.\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Parent contexts" {
  // Names missing in the current context are looked up in the stack.
  let template = "\"{{#sec}}{{a}}, {{b}}, {{c.d}}{{/sec}}\""
  let data_str = "{\"a\": \"foo\", \"b\": \"wrong\", \"sec\": {\"b\": \"bar\"}, \"c\": {\"d\": \"baz\"}}"
  let expected = "\"foo, bar, baz\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - List Contexts" {
  // All elements on the context stack should be accessible within lists.
  let template = "{{#tops}}{{#middles}}{{tname.lower}}{{mname}}.{{#bottoms}}{{tname.upper}}{{mname}}{{bname}}.{{/bottoms}}{{/middles}}{{/tops}}"
  let data_str = "{\"tops\": [{\"tname\": {\"upper\": \"A\", \"lower\": \"a\"}, \"middles\": [{\"mname\": \"1\", \"bottoms\": [{\"bname\": \"x\"}, {\"bname\": \"y\"}]}]}]}"
  let expected = "a1.A1x.A1y."
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - List" {
  // Lists should be iterated; list items should visit the context stack.
  let template = "\"{{#list}}{{item}}{{/list}}\""
  let data_str = "{\"list\": [{\"item\": 1}, {\"item\": 2}, {\"item\": 3}]}"
  let expected = "\"123\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Empty List" {
  // Empty lists should behave like falsey values.
  let template = "\"{{#list}}Yay lists!{{/list}}\""
  let data_str = "{\"list\": []}"
  let expected = "\"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Doubled" {
  // Multiple sections per template should be permitted.
  let template = "{{#bool}}\n* first\n{{/bool}}\n* {{two}}\n{{#bool}}\n* third\n{{/bool}}\n"
  let data_str = "{\"bool\": true, \"two\": \"second\"}"
  let expected = "* first\n* second\n* third\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Nested (Truthy)" {
  // Nested truthy sections should have their contents rendered.
  let template = "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
  let data_str = "{\"bool\": true}"
  let expected = "| A B C D E |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Nested (Falsey)" {
  // Nested falsey sections should be omitted.
  let template = "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
  let data_str = "{\"bool\": false}"
  let expected = "| A  E |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Context Misses" {
  // Failed context lookups should be considered falsey.
  let template = "[{{#missing}}Found key 'missing'!{{/missing}}]"
  let data_str = "{}"
  let expected = "[]"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - String" {
  // Implicit iterators should directly interpolate strings.
  let template = "\"{{#list}}({{.}}){{/list}}\""
  let data_str = "{\"list\": [\"a\", \"b\", \"c\", \"d\", \"e\"]}"
  let expected = "\"(a)(b)(c)(d)(e)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - Integer" {
  // Implicit iterators should cast integers to strings and interpolate.
  let template = "\"{{#list}}({{.}}){{/list}}\""
  let data_str = "{\"list\": [1, 2, 3, 4, 5]}"
  let expected = "\"(1)(2)(3)(4)(5)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - Decimal" {
  // Implicit iterators should cast decimals to strings and interpolate.
  let template = "\"{{#list}}({{.}}){{/list}}\""
  let data_str = "{\"list\": [1.1, 2.2, 3.3, 4.4, 5.5]}"
  let expected = "\"(1.1)(2.2)(3.3)(4.4)(5.5)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - Array" {
  // Implicit iterators should allow iterating over nested arrays.
  let template = "\"{{#list}}({{#.}}{{.}}{{/.}}){{/list}}\""
  let data_str = "{\"list\": [[1, 2, 3], [\"a\", \"b\", \"c\"]]}"
  let expected = "\"(123)(abc)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - HTML Escaping" {
  // Implicit iterators with basic interpolation should be HTML escaped.
  let template = "\"{{#list}}({{.}}){{/list}}\""
  let data_str = "{\"list\": [\"&\", \"\\\"\", \"<\", \">\"]}"
  let expected = "\"(&amp;)(&quot;)(&lt;)(&gt;)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - Triple mustache" {
  // Implicit iterators in triple mustache should interpolate without HTML escaping.
  let template = "\"{{#list}}({{{.}}}){{/list}}\""
  let data_str = "{\"list\": [\"&\", \"\\\"\", \"<\", \">\"]}"
  let expected = "\"(&)(\")(<)(>)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - Ampersand" {
  // Implicit iterators in an Ampersand tag should interpolate without HTML escaping.
  let template = "\"{{#list}}({{&.}}){{/list}}\""
  let data_str = "{\"list\": [\"&\", \"\\\"\", \"<\", \">\"]}"
  let expected = "\"(&)(\")(<)(>)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Implicit Iterator - Root-level" {
  // Implicit iterators should work on root-level lists.
  let template = "\"{{#.}}({{value}}){{/.}}\""
  let data_str = "[{\"value\": \"a\"}, {\"value\": \"b\"}]"
  let expected = "\"(a)(b)\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Dotted Names - Truthy" {
  // Dotted names should be valid for Section tags.
  let template = "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"Here\""
  let data_str = "{\"a\": {\"b\": {\"c\": true}}}"
  let expected = "\"Here\" == \"Here\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Dotted Names - Falsey" {
  // Dotted names should be valid for Section tags.
  let template = "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"\""
  let data_str = "{\"a\": {\"b\": {\"c\": false}}}"
  let expected = "\"\" == \"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Dotted Names - Broken Chains" {
  // Dotted names that cannot be resolved should be considered falsey.
  let template = "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"\""
  let data_str = "{\"a\": {}}"
  let expected = "\"\" == \"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Surrounding Whitespace" {
  // Sections should not alter surrounding whitespace.
  let template = " | {{#boolean}}	|	{{/boolean}} | \n"
  let data_str = "{\"boolean\": true}"
  let expected = " | 	|	 | \n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Internal Whitespace" {
  // Sections should not alter internal whitespace.
  let template = " | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
  let data_str = "{\"boolean\": true}"
  let expected = " |  \n  | \n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Indented Inline Sections" {
  // Single-line sections should not alter surrounding whitespace.
  let template = " {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n"
  let data_str = "{\"boolean\": true}"
  let expected = " YES\n GOOD\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Standalone Lines" {
  // Standalone lines should be removed from the template.
  let template = "| This Is\n{{#boolean}}\n|\n{{/boolean}}\n| A Line\n"
  let data_str = "{\"boolean\": true}"
  let expected = "| This Is\n|\n| A Line\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Indented Standalone Lines" {
  // Indented standalone lines should be removed from the template.
  let template = "| This Is\n  {{#boolean}}\n|\n  {{/boolean}}\n| A Line\n"
  let data_str = "{\"boolean\": true}"
  let expected = "| This Is\n|\n| A Line\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Standalone Line Endings" {
  // \"\r\n\" should be considered a newline for standalone tags.
  let template = "|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|"
  let data_str = "{\"boolean\": true}"
  let expected = "|\r\n|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Standalone Without Previous Line" {
  // Standalone tags should not require a newline to precede them.
  let template = "  {{#boolean}}\n#{{/boolean}}\n/"
  let data_str = "{\"boolean\": true}"
  let expected = "#\n/"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Standalone Without Newline" {
  // Standalone tags should not require a newline to follow them.
  let template = "#{{#boolean}}\n/\n  {{/boolean}}"
  let data_str = "{\"boolean\": true}"
  let expected = "#\n/\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "sections.json - Padding" {
  // Superfluous in-tag whitespace should be ignored.
  let template = "|{{# boolean }}={{/ boolean }}|"
  let data_str = "{\"boolean\": true}"
  let expected = "|=|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Falsey" {
  // Falsey sections should have their contents rendered.
  let template = "\"{{^boolean}}This should be rendered.{{/boolean}}\""
  let data_str = "{\"boolean\": false}"
  let expected = "\"This should be rendered.\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Truthy" {
  // Truthy sections should have their contents omitted.
  let template = "\"{{^boolean}}This should not be rendered.{{/boolean}}\""
  let data_str = "{\"boolean\": true}"
  let expected = "\"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Null is falsey" {
  // Null is falsey.
  let template = "\"{{^null}}This should be rendered.{{/null}}\""
  let data_str = "{\"null\": null}"
  let expected = "\"This should be rendered.\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Context" {
  // Objects and hashes should behave like truthy values.
  let template = "\"{{^context}}Hi {{name}}.{{/context}}\""
  let data_str = "{\"context\": {\"name\": \"Joe\"}}"
  let expected = "\"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - List" {
  // Lists should behave like truthy values.
  let template = "\"{{^list}}{{n}}{{/list}}\""
  let data_str = "{\"list\": [{\"n\": 1}, {\"n\": 2}, {\"n\": 3}]}"
  let expected = "\"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Empty List" {
  // Empty lists should behave like falsey values.
  let template = "\"{{^list}}Yay lists!{{/list}}\""
  let data_str = "{\"list\": []}"
  let expected = "\"Yay lists!\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Doubled" {
  // Multiple inverted sections per template should be permitted.
  let template = "{{^bool}}\n* first\n{{/bool}}\n* {{two}}\n{{^bool}}\n* third\n{{/bool}}\n"
  let data_str = "{\"bool\": false, \"two\": \"second\"}"
  let expected = "* first\n* second\n* third\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Nested (Falsey)" {
  // Nested falsey sections should have their contents rendered.
  let template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
  let data_str = "{\"bool\": false}"
  let expected = "| A B C D E |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Nested (Truthy)" {
  // Nested truthy sections should be omitted.
  let template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
  let data_str = "{\"bool\": true}"
  let expected = "| A  E |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Context Misses" {
  // Failed context lookups should be considered falsey.
  let template = "[{{^missing}}Cannot find key 'missing'!{{/missing}}]"
  let data_str = "{}"
  let expected = "[Cannot find key 'missing'!]"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Dotted Names - Truthy" {
  // Dotted names should be valid for Inverted Section tags.
  let template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"\""
  let data_str = "{\"a\": {\"b\": {\"c\": true}}}"
  let expected = "\"\" == \"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Dotted Names - Falsey" {
  // Dotted names should be valid for Inverted Section tags.
  let template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\""
  let data_str = "{\"a\": {\"b\": {\"c\": false}}}"
  let expected = "\"Not Here\" == \"Not Here\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Dotted Names - Broken Chains" {
  // Dotted names that cannot be resolved should be considered falsey.
  let template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\""
  let data_str = "{\"a\": {}}"
  let expected = "\"Not Here\" == \"Not Here\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Surrounding Whitespace" {
  // Inverted sections should not alter surrounding whitespace.
  let template = " | {{^boolean}}	|	{{/boolean}} | \n"
  let data_str = "{\"boolean\": false}"
  let expected = " | 	|	 | \n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Internal Whitespace" {
  // Inverted should not alter internal whitespace.
  let template = " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
  let data_str = "{\"boolean\": false}"
  let expected = " |  \n  | \n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Indented Inline Sections" {
  // Single-line sections should not alter surrounding whitespace.
  let template = " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
  let data_str = "{\"boolean\": false}"
  let expected = " NO\n WAY\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Standalone Lines" {
  // Standalone lines should be removed from the template.
  let template = "| This Is\n{{^boolean}}\n|\n{{/boolean}}\n| A Line\n"
  let data_str = "{\"boolean\": false}"
  let expected = "| This Is\n|\n| A Line\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Standalone Indented Lines" {
  // Standalone indented lines should be removed from the template.
  let template = "| This Is\n  {{^boolean}}\n|\n  {{/boolean}}\n| A Line\n"
  let data_str = "{\"boolean\": false}"
  let expected = "| This Is\n|\n| A Line\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Standalone Line Endings" {
  // \"\r\n\" should be considered a newline for standalone tags.
  let template = "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
  let data_str = "{\"boolean\": false}"
  let expected = "|\r\n|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Standalone Without Previous Line" {
  // Standalone tags should not require a newline to precede them.
  let template = "  {{^boolean}}\n^{{/boolean}}\n/"
  let data_str = "{\"boolean\": false}"
  let expected = "^\n/"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Standalone Without Newline" {
  // Standalone tags should not require a newline to follow them.
  let template = "^{{^boolean}}\n/\n  {{/boolean}}"
  let data_str = "{\"boolean\": false}"
  let expected = "^\n/\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "inverted.json - Padding" {
  // Superfluous in-tag whitespace should be ignored.
  let template = "|{{^ boolean }}={{/ boolean }}|"
  let data_str = "{\"boolean\": false}"
  let expected = "|=|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Inline" {
  // Comment blocks should be removed from the template.
  let template = "12345{{! Comment Block! }}67890"
  let data_str = "{}"
  let expected = "1234567890"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Multiline" {
  // Multiline comments should be permitted.
  let template = "12345{{!\n  This is a\n  multi-line comment...\n}}67890\n"
  let data_str = "{}"
  let expected = "1234567890\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Standalone" {
  // All standalone comment lines should be removed.
  let template = "Begin.\n{{! Comment Block! }}\nEnd.\n"
  let data_str = "{}"
  let expected = "Begin.\nEnd.\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Indented Standalone" {
  // All standalone comment lines should be removed.
  let template = "Begin.\n  {{! Indented Comment Block! }}\nEnd.\n"
  let data_str = "{}"
  let expected = "Begin.\nEnd.\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Standalone Line Endings" {
  // \"\r\n\" should be considered a newline for standalone tags.
  let template = "|\r\n{{! Standalone Comment }}\r\n|"
  let data_str = "{}"
  let expected = "|\r\n|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Standalone Without Previous Line" {
  // Standalone tags should not require a newline to precede them.
  let template = "  {{! I'm Still Standalone }}\n!"
  let data_str = "{}"
  let expected = "!"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Standalone Without Newline" {
  // Standalone tags should not require a newline to follow them.
  let template = "!\n  {{! I'm Still Standalone }}"
  let data_str = "{}"
  let expected = "!\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Multiline Standalone" {
  // All standalone comment lines should be removed.
  let template = "Begin.\n{{!\nSomething's going on here...\n}}\nEnd.\n"
  let data_str = "{}"
  let expected = "Begin.\nEnd.\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Indented Multiline Standalone" {
  // All standalone comment lines should be removed.
  let template = "Begin.\n  {{!\n    Something's going on here...\n  }}\nEnd.\n"
  let data_str = "{}"
  let expected = "Begin.\nEnd.\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Indented Inline" {
  // Inline comments should not strip whitespace
  let template = "  12 {{! 34 }}\n"
  let data_str = "{}"
  let expected = "  12 \n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Surrounding Whitespace" {
  // Comment removal should preserve surrounding whitespace.
  let template = "12345 {{! Comment Block! }} 67890"
  let data_str = "{}"
  let expected = "12345  67890"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "comments.json - Variable Name Collision" {
  // Comments must never render, even if variable with same name exists.
  let template = "comments never show: >{{! comment }}<"
  let data_str = "{\"! comment\": 1, \"! comment \": 2, \"!comment\": 3, \"comment\": 4}"
  let expected = "comments never show: ><"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Basic Behavior" {
  // The greater-than operator should expand to the named partial.
  let template = "\"{{>text}}\""
  let data_str = "{}"
  let expected = "\"from partial\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["text"] = "from partial"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Failed Lookup" {
  // The empty string should be used when the named partial is not found.
  let template = "\"{{>text}}\""
  let data_str = "{}"
  let expected = "\"\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Context" {
  // The greater-than operator should operate within the current context.
  let template = "\"{{>partial}}\""
  let data_str = "{\"text\": \"content\"}"
  let expected = "\"*content*\""
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["partial"] = "*{{text}}*"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Recursion" {
  // The greater-than operator should properly recurse.
  let template = "{{>node}}"
  let data_str = "{\"content\": \"X\", \"nodes\": [{\"content\": \"Y\", \"nodes\": []}]}"
  let expected = "X<Y<>>"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["node"] = "{{content}}<{{#nodes}}{{>node}}{{/nodes}}>"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Nested" {
  // The greater-than operator should work from within partials.
  let template = "{{>outer}}"
  let data_str = "{\"a\": \"hello\", \"b\": \"world\"}"
  let expected = "*hello world!*"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["outer"] = "*{{a}} {{>inner}}*"
  partials_map["inner"] = "{{b}}!"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Surrounding Whitespace" {
  // The greater-than operator should not alter surrounding whitespace.
  let template = "| {{>partial}} |"
  let data_str = "{}"
  let expected = "| 	|	 |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["partial"] = "	|	"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Standalone Line Endings" {
  // \"\r\n\" should be considered a newline for standalone tags.
  let template = "|\r\n{{>partial}}\r\n|"
  let data_str = "{}"
  let expected = "|\r\n>|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["partial"] = ">"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Standalone Without Previous Line" {
  // Standalone tags should not require a newline to precede them.
  let template = "  {{>partial}}\n>"
  let data_str = "{}"
  let expected = "  >\n  >>"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["partial"] = ">\n>"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Standalone Without Newline" {
  // Standalone tags should not require a newline to follow them.
  let template = ">\n  {{>partial}}"
  let data_str = "{}"
  let expected = ">\n  >\n  >"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["partial"] = ">\n>"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "partials.json - Padding Whitespace" {
  // Superfluous in-tag whitespace should be ignored.
  let template = "|{{> partial }}|"
  let data_str = "{\"boolean\": true}"
  let expected = "|[]|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["partial"] = "[]"
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Pair Behavior" {
  // The equals sign (used on both sides) should permit delimiter changes.
  let template = "{{=<% %>=}}(<%text%>)"
  let data_str = "{\"text\": \"Hey!\"}"
  let expected = "(Hey!)"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Special Characters" {
  // Characters with special meaning regexen should be valid delimiters.
  let template = "({{=[ ]=}}[text])"
  let data_str = "{\"text\": \"It worked!\"}"
  let expected = "(It worked!)"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Sections" {
  // Delimiters set outside sections should persist.
  let template = "[\n{{#section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|#section|\n  {{data}}\n  |data|\n|/section|\n]\n"
  let data_str = "{\"section\": true, \"data\": \"I got interpolated.\"}"
  let expected = "[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Inverted Sections" {
  // Delimiters set outside inverted sections should persist.
  let template = "[\n{{^section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|^section|\n  {{data}}\n  |data|\n|/section|\n]\n"
  let data_str = "{\"section\": false, \"data\": \"I got interpolated.\"}"
  let expected = "[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Partial Inheritence" {
  // Delimiters set in a parent template should not affect a partial.
  let template = "[ {{>include}} ]\n{{= | | =}}\n[ |>include| ]\n"
  let data_str = "{\"value\": \"yes\"}"
  let expected = "[ .yes. ]\n[ .yes. ]\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["include"] = ".{{value}}."
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Post-Partial Behavior" {
  // Delimiters set in a partial should not affect the parent template.
  let template = "[ {{>include}} ]\n[ .{{value}}.  .|value|. ]\n"
  let data_str = "{\"value\": \"yes\"}"
  let expected = "[ .yes.  .yes. ]\n[ .yes.  .|value|. ]\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let partials_map : Map[String, String] = {}
  partials_map["include"] = ".{{value}}. {{= | | =}} .|value|."
  let result = render_string(template, data, partials=partials_map) catch {
    _ => fail("Render error")
  }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Surrounding Whitespace" {
  // Surrounding whitespace should be left untouched.
  let template = "| {{=@ @=}} |"
  let data_str = "{}"
  let expected = "|  |"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Outlying Whitespace (Inline)" {
  // Whitespace should be left untouched.
  let template = " | {{=@ @=}}\n"
  let data_str = "{}"
  let expected = " | \n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Standalone Tag" {
  // Standalone lines should be removed from the template.
  let template = "Begin.\n{{=@ @=}}\nEnd.\n"
  let data_str = "{}"
  let expected = "Begin.\nEnd.\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Indented Standalone Tag" {
  // Indented standalone lines should be removed from the template.
  let template = "Begin.\n  {{=@ @=}}\nEnd.\n"
  let data_str = "{}"
  let expected = "Begin.\nEnd.\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Standalone Line Endings" {
  // \"\r\n\" should be considered a newline for standalone tags.
  let template = "|\r\n{{= @ @ =}}\r\n|"
  let data_str = "{}"
  let expected = "|\r\n|"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Standalone Without Previous Line" {
  // Standalone tags should not require a newline to precede them.
  let template = "  {{=@ @=}}\n="
  let data_str = "{}"
  let expected = "="
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Standalone Without Newline" {
  // Standalone tags should not require a newline to follow them.
  let template = "=\n  {{=@ @=}}"
  let data_str = "{}"
  let expected = "=\n"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}

///|
test "delimiters.json - Pair with Padding" {
  // Superfluous in-tag whitespace should be ignored.
  let template = "|{{= @   @ =}}|"
  let data_str = "{}"
  let expected = "||"
  let data : Json = @json.parse(data_str) catch {
    _ => fail("Json parse error")
  }
  let result = render_string(template, data) catch { _ => fail("Render error") }
  if result != expected {
    fail("Expected: " + expected + ", got: " + result)
  }
}
