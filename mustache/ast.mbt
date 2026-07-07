pub(all) enum Node {
  Text(String)
  Variable(String, escape~ : Bool)
  Section(String, Array[Node], inverted~ : Bool)
  Partial(String, indent~ : String)
} derive(Show, Eq)

pub(all) enum MustacheError {
  ParseError(String)
  RenderError(String)
} derive(Show, Eq)

impl Show for MustacheError with output(self, logger) {
  match self {
    ParseError(msg) => logger.write_string("ParseError: \{msg}")
    RenderError(msg) => logger.write_string("RenderError: \{msg}")
  }
}
