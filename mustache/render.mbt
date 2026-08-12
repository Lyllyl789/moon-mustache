///|
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

///|
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

///|
fn render_nodes(
  nodes : Array[Node],
  context : Context,
  partials : Map[String, String],
  sb : StringBuilder,
  options : RenderOptions,
  partial_depth : Int,
  stats : RenderStats,
) -> Unit raise MustacheError {
  if context.depth() > options.max_context_depth {
    raise RenderError("render context depth limit exceeded")
  }
  for node in nodes {
    stats.nodes_visited += 1
    if stats.nodes_visited > options.max_nodes {
      raise RenderError("render node limit exceeded")
    }
    match node {
      Text(text) => append_output(sb, stats, options, text)
      Variable(name, escape~) => {
        let val = context.lookup(name)
        if val != null {
          stats.variables_resolved += 1
          let s = json_to_string(val)
          if escape {
            append_output(sb, stats, options, escape_html(s))
          } else {
            append_output(sb, stats, options, s)
          }
        } else {
          stats.missing_variables += 1
        }
      }
      Section(name, children, inverted~) => {
        stats.sections_entered += 1
        let val = context.lookup(name)
        let is_true = is_truthy(val)
        if inverted {
          if !is_true {
            render_nodes(
              children, context, partials, sb, options, partial_depth, stats,
            )
          }
        } else if is_true {
          match val {
            Array(arr) =>
              for item in arr {
                let new_context = context.push(item)
                render_nodes(
                  children, new_context, partials, sb, options, partial_depth, stats,
                )
              }
            Object(_) => {
              let new_context = context.push(val)
              render_nodes(
                children, new_context, partials, sb, options, partial_depth, stats,
              )
            }
            _ =>
              render_nodes(
                children, context, partials, sb, options, partial_depth, stats,
              )
          }
        }
      }
      Partial(name, indent~, standalone~) =>
        match partials.get(name) {
          None =>
            if options.missing_partial_is_error {
              raise RenderError("Missing partial: \{name}")
            }
          Some(partial_template) => {
            if partial_depth >= options.max_partial_depth {
              raise RenderError("Partial recursion depth exceeded for: \{name}")
            }
            stats.partials_rendered += 1
            if partial_depth + 1 > stats.max_partial_depth_seen {
              stats.max_partial_depth_seen = partial_depth + 1
            }
            let tokens = tokenize(partial_template)
            let parser = Parser::new(tokens)
            let partial_nodes = parser.parse()

            let partial_sb = StringBuilder::new()
            render_nodes(
              partial_nodes,
              context,
              partials,
              partial_sb,
              options,
              partial_depth + 1,
              stats,
            )

            let rendered_partial = partial_sb.to_string()
            let indented_partial = apply_indent(
              rendered_partial, indent, standalone,
            )
            append_output(sb, stats, options, indented_partial)
          }
        }
    }
  }
}

///|
fn append_output(
  sb : StringBuilder,
  stats : RenderStats,
  options : RenderOptions,
  text : String,
) -> Unit raise MustacheError {
  let next_size = stats.output_chars + text.length()
  if next_size > options.max_output_chars {
    raise RenderError("render output limit exceeded")
  }
  stats.output_chars = next_size
  sb.write_string(text)
}
