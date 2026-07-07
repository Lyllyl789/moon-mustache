test "variables" {
  let context : Json = {
    "name": "Chris",
    "value": 123.45,
    "html": "<b>HTML</b>"
  }
  
  let r1 = try { render_string("Hello {{name}}!", context) } catch { _ => fail("error") }
  inspect(r1, content = "Hello Chris!")
  
  let r2 = try { render_string("Unescaped: {{{html}}}", context) } catch { _ => fail("error") }
  inspect(r2, content = "Unescaped: <b>HTML</b>")
  
  let r3 = try { render_string("Unescaped &: {{&html}}", context) } catch { _ => fail("error") }
  inspect(r3, content = "Unescaped &: <b>HTML</b>")
  
  let r4 = try { render_string("Value: {{value}}", context) } catch { _ => fail("error") }
  inspect(r4, content = "Value: 123.45")
}

test "sections" {
  let context : Json = {
    "repo": [
      { "name": "resque" },
      { "name": "hub" }
    ],
    "empty_list": [],
    "show": true,
    "hide": false
  }

  let r1 = try { render_string("{{#repo}}<b>{{name}}</b>{{/repo}}", context) } catch { _ => fail("error") }
  inspect(r1, content = "<b>resque</b><b>hub</b>")

  let r2 = try { render_string("{{#empty_list}}empty{{/empty_list}}", context) } catch { _ => fail("error") }
  inspect(r2, content = "")

  let r3 = try { render_string("{{#show}}visible{{/show}}", context) } catch { _ => fail("error") }
  inspect(r3, content = "visible")

  let r4 = try { render_string("{{#hide}}invisible{{/hide}}", context) } catch { _ => fail("error") }
  inspect(r4, content = "")
}

test "inverted_sections" {
  let context : Json = {
    "show": true,
    "hide": false,
    "empty_list": []
  }

  let r1 = try { render_string("{{^hide}}hidden{{/hide}}", context) } catch { _ => fail("error") }
  inspect(r1, content = "hidden")

  let r2 = try { render_string("{{^show}}hidden{{/show}}", context) } catch { _ => fail("error") }
  inspect(r2, content = "")

  let r3 = try { render_string("{{^empty_list}}no repos{{/empty_list}}", context) } catch { _ => fail("error") }
  inspect(r3, content = "no repos")
}

test "comments" {
  let context : Json = {}
  let r = try { render_string("Hello {{! ignore me }}World", context) } catch { _ => fail("error") }
  inspect(r, content = "Hello World")
}

test "delimiter_change" {
  let context : Json = { "name": "Chris" }
  let r = try { render_string("{{=<% %>=}}<%name%>", context) } catch { _ => fail("error") }
  inspect(r, content = "Chris")
}

test "partials" {
  let context : Json = { "name": "Chris" }
  let partials = Map([("user", "{{name}}")])
  let r = try { render_string("Hello {{> user}}!", context, partials = partials) } catch { _ => fail("error") }
  inspect(r, content = "Hello Chris!")
}

test "dot_notation" {
  let context : Json = {
    "user": { "name": "Chris" }
  }
  let r = try { render_string("{{user.name}}", context) } catch { _ => fail("error") }
  inspect(r, content = "Chris")
}

test "implicit_iterator" {
  let context : Json = {
    "names": ["A", "B"]
  }
  let r = try { render_string("{{#names}}{{.}}{{/names}}", context) } catch { _ => fail("error") }
  inspect(r, content = "AB")
}

test "standalone_tags" {
  let context : Json = {
    "show": true
  }
  let r = try { render_string("  {{#show}}\n  yes\n  {{/show}}\n", context) } catch { _ => fail("error") }
  inspect(r, content = "  yes\n")
}

