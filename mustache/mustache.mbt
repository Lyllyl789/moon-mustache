pub struct Template {
  nodes : Array[Node]
}

pub fn compile(template : String) -> Template raise MustacheError {
  let tokens = tokenize(template)
  let parser = Parser::new(tokens)
  let nodes = parser.parse()
  { nodes: nodes }
}

pub fn Template::render(
  self : Template,
  context : Json,
  partials~ : Map[String, String] = Map([])
) -> String raise MustacheError {
  let sb = StringBuilder::new()
  let ctx = Context::new(context)
  render_nodes(self.nodes, ctx, partials, sb)
  sb.to_string()
}

pub fn render_string(
  template : String,
  context : Json,
  partials~ : Map[String, String] = Map([])
) -> String raise MustacheError {
  let t = compile(template)
  t.render(context, partials = partials)
}
