pub(all) enum Node {
  Text(String)
  Variable(String, escape~ : Bool)
  Section(String, Array[Node], inverted~ : Bool)
  Partial(String, indent~ : String)
} derive(Debug, Eq)

pub(all) suberror MustacheError {
  ParseError(String)
  RenderError(String)
}
