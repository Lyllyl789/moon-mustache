///|
pub struct Template {
  nodes : Array[Node]
}

///|
/// Rendering policy for production callers.
pub struct RenderOptions {
  max_partial_depth : Int
  missing_partial_is_error : Bool
  max_output_chars : Int
  max_nodes : Int
  max_context_depth : Int
}

///|
pub fn RenderOptions::default() -> RenderOptions {
  {
    max_partial_depth: 64,
    missing_partial_is_error: false,
    max_output_chars: 1_000_000,
    max_nodes: 100_000,
    max_context_depth: 128,
  }
}

///|
pub fn RenderOptions::new(
  max_partial_depth? : Int = 64,
  missing_partial_is_error? : Bool = false,
  max_output_chars? : Int = 1_000_000,
  max_nodes? : Int = 100_000,
  max_context_depth? : Int = 128,
) -> RenderOptions raise MustacheError {
  if max_partial_depth < 1 {
    raise RenderError("max_partial_depth must be at least 1")
  }
  if max_output_chars < 1 || max_nodes < 1 || max_context_depth < 1 {
    raise RenderError("render limits must be positive")
  }
  {
    max_partial_depth,
    missing_partial_is_error,
    max_output_chars,
    max_nodes,
    max_context_depth,
  }
}

///|
/// Runtime counters useful for observability and admission control.
pub struct RenderStats {
  mut nodes_visited : Int
  mut variables_resolved : Int
  mut missing_variables : Int
  mut sections_entered : Int
  mut partials_rendered : Int
  mut output_chars : Int
  mut max_partial_depth_seen : Int
}

///|
pub fn RenderStats::nodes_visited(self : RenderStats) -> Int {
  self.nodes_visited
}

///|
pub fn RenderStats::variables_resolved(self : RenderStats) -> Int {
  self.variables_resolved
}

///|
pub fn RenderStats::missing_variables(self : RenderStats) -> Int {
  self.missing_variables
}

///|
pub fn RenderStats::sections_entered(self : RenderStats) -> Int {
  self.sections_entered
}

///|
pub fn RenderStats::partials_rendered(self : RenderStats) -> Int {
  self.partials_rendered
}

///|
pub fn RenderStats::output_chars(self : RenderStats) -> Int {
  self.output_chars
}

///|
pub fn RenderStats::max_partial_depth_seen(self : RenderStats) -> Int {
  self.max_partial_depth_seen
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
  let (output, _) = self.render_with_stats(context, partials, options)
  output
}

///|
/// Render and return counters for production telemetry.
pub fn Template::render_with_stats(
  self : Template,
  context : Json,
  partials : Map[String, String],
  options : RenderOptions,
) -> (String, RenderStats) raise MustacheError {
  let sb = StringBuilder::new()
  let ctx = Context::new(context)
  let stats : RenderStats = {
    nodes_visited: 0,
    variables_resolved: 0,
    missing_variables: 0,
    sections_entered: 0,
    partials_rendered: 0,
    output_chars: 0,
    max_partial_depth_seen: 0,
  }
  render_nodes(self.nodes, ctx, partials, sb, options, 0, stats)
  (sb.to_string(), stats)
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
