fn apply_indent(content : String, indent : String, standalone : Bool) -> String {
  if indent.length() == 0 {
    return content
  }
  let sb = StringBuilder::new()
  let len = content.length()
  let mut i = 0
  let mut at_line_start = standalone
  let char_lf = (10).to_uint16()
  while i < len {
    let c = content[i]
    if at_line_start {
      sb.write_string(indent)
      at_line_start = false
    }
    sb.write_char(c.to_int().to_char().unwrap())
    if c == char_lf {
      at_line_start = true
    }
    i = i + 1
  }
  sb.to_string()
}

fn json_to_string(val : Json) -> String {
  match val {
    Null => ""
    True => "true"
    False => "false"
    Number(n, ..) => n.to_string()
    String(s) => s
    Array(_) | Object(_) => val.stringify()
  }
}

fn render_nodes(
  nodes : Array[Node],
  context : Context,
  partials : Map[String, String],
  sb : StringBuilder
) -> Unit raise MustacheError {
  for node in nodes {
    match node {
      Text(text) => sb.write_string(text)
      Variable(name, escape~) => {
        let val = context.lookup(name)
        if val != null {
          let s = json_to_string(val)
          if escape {
            sb.write_string(escape_html(s))
          } else {
            sb.write_string(s)
          }
        }
      }
      Section(name, children, inverted~) => {
        let val = context.lookup(name)
        let is_true = is_truthy(val)
        if inverted {
          if !is_true {
            render_nodes(children, context, partials, sb)
          }
        } else if is_true {
          match val {
            Array(arr) => {
              for item in arr {
                let new_context = context.push(item)
                render_nodes(children, new_context, partials, sb)
              }
            }
            Object(_) => {
              let new_context = context.push(val)
              render_nodes(children, new_context, partials, sb)
            }
            _ => {
              render_nodes(children, context, partials, sb)
            }
          }
        }
      }
      Partial(name, indent~, standalone~) => {
        match partials.get(name) {
          None => ()
          Some(partial_template) => {
            let tokens = tokenize(partial_template)
            let parser = Parser::new(tokens)
            let partial_nodes = parser.parse()
            
            let partial_sb = StringBuilder::new()
            render_nodes(partial_nodes, context, partials, partial_sb)
            
            let rendered_partial = partial_sb.to_string()
            let indented_partial = apply_indent(rendered_partial, indent, standalone)
            sb.write_string(indented_partial)
          }
        }
      }
    }
  }
}
