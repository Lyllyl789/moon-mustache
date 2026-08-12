///|
pub struct Template {
  nodes : Array[Node]
}

///|
/// Rendering policy for production callers.
pub struct RenderOptions {
  max_partial_depth : Int
  missing_partial_is_error : Bool
}

///|
pub fn RenderOptions::default() -> RenderOptions {
  { max_partial_depth: 64, missing_partial_is_error: false }
}

///|
pub fn RenderOptions::new(
  max_partial_depth? : Int = 64,
  missing_partial_is_error? : Bool = false,
) -> RenderOptions raise MustacheError {
  if max_partial_depth < 1 {
    raise RenderError("max_partial_depth must be at least 1")
  }
  { max_partial_depth, missing_partial_is_error }
}

///|
pub fn compile(template : String) -> Template raise MustacheError {
  let tokens = tokenize(template)
  let parser = Parser::new(tokens)
  let nodes = parser.parse()
  { nodes, }
}

///|
pub fn Template::render(
  self : Template,
  context : Json,
  partials? : Map[String, String] = Map([]),
) -> String raise MustacheError {
  self.render_with_options(context, partials, RenderOptions::default())
}

///|
/// Render a compiled template with explicit partial safety policy.
pub fn Template::render_with_options(
  self : Template,
  context : Json,
  partials : Map[String, String],
  options : RenderOptions,
) -> String raise MustacheError {
  let sb = StringBuilder::new()
  let ctx = Context::new(context)
  render_nodes(self.nodes, ctx, partials, sb, options, 0)
  sb.to_string()
}

///|
pub fn render_string(
  template : String,
  context : Json,
  partials? : Map[String, String] = Map([]),
) -> String raise MustacheError {
  let t = compile(template)
  t.render(context, partials~)
}

///|
/// Compile and render with explicit production options.
pub fn render_string_with_options(
  template : String,
  context : Json,
  partials : Map[String, String],
  options : RenderOptions,
) -> String raise MustacheError {
  let t = compile(template)
  t.render_with_options(context, partials, options)
}
