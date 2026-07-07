struct Parser {
  tokens : Array[Token]
  mut index : Int
}

fn Parser::new(tokens : Array[Token]) -> Parser {
  { tokens, index: 0 }
}

fn Parser::peek(self : Parser) -> Option[Token] {
  if self.index < self.tokens.length() {
    Some(self.tokens[self.index])
  } else {
    None
  }
}

fn Parser::advance(self : Parser) {
  self.index = self.index + 1
}

fn Parser::parse(self : Parser) -> Result[Array[Node], MustacheError] {
  let nodes = []
  while true {
    match self.peek() {
      None => break
      Some(Token::TSectionEnd(name)) => {
        return Result::Err(MustacheError::ParseError("Unexpected section end tag: /\{name}"))
      }
      Some(tok) => {
        self.advance()
        match tok {
          TText(text) => nodes.push(Node::Text(text))
          TVariable(name, escape~) => nodes.push(Node::Variable(name, escape~ = escape))
          TComment(_) => ()
          TPartial(name, indent~) => nodes.push(Node::Partial(name, indent~ = indent))
          TSectionStart(name) => {
            let children = self.parse_section(name)?
            nodes.push(Node::Section(name, children, inverted~ = false))
          }
          TInvertedSectionStart(name) => {
            let children = self.parse_section(name)?
            nodes.push(Node::Section(name, children, inverted~ = true))
          }
          TSectionEnd(_) => ()
        }
      }
    }
  }
  Result::Ok(nodes)
}

fn Parser::parse_section(self : Parser, section_name : String) -> Result[Array[Node], MustacheError] {
  let nodes = []
  while true {
    match self.peek() {
      None => {
        return Result::Err(MustacheError::ParseError("Unclosed section: \{section_name}"))
      }
      Some(Token::TSectionEnd(end_name)) => {
        self.advance()
        if end_name != section_name {
          return Result::Err(MustacheError::ParseError("Mismatched section end tag: expected /\{section_name}, got /\{end_name}"))
        }
        break
      }
      Some(tok) => {
        self.advance()
        match tok {
          TText(text) => nodes.push(Node::Text(text))
          TVariable(name, escape~) => nodes.push(Node::Variable(name, escape~ = escape))
          TComment(_) => ()
          TPartial(name, indent~) => nodes.push(Node::Partial(name, indent~ = indent))
          TSectionStart(name) => {
            let children = self.parse_section(name)?
            nodes.push(Node::Section(name, children, inverted~ = false))
          }
          TInvertedSectionStart(name) => {
            let children = self.parse_section(name)?
            nodes.push(Node::Section(name, children, inverted~ = true))
          }
        }
      }
    }
  }
  Result::Ok(nodes)
}
