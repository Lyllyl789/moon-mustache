pub(all) enum Node {
  Text(String)
  Variable(String, escape~ : Bool)
  Section(String, Array[Node], inverted~ : Bool)
  Partial(String, indent~ : String, standalone~ : Bool)
} derive(Debug, Eq)

pub(all) suberror MustacheError {
  ParseError(String)
  RenderError(String)
}

impl Show for MustacheError with output(self, logger) {
  match self {
    ParseError(msg) => logger.write_string("ParseError: \{msg}")
    RenderError(msg) => logger.write_string("RenderError: \{msg}")
  }
}
