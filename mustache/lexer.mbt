enum Token {
  TText(String)
  TVariable(String, escape~ : Bool)
  TSectionStart(String)
  TInvertedSectionStart(String)
  TSectionEnd(String)
  TComment(String)
  TPartial(String, indent~ : String)
} derive(Debug, Eq)

fn find_substring(s : String, sub : String, start : Int) -> Int {
  let len = s.length()
  let sub_len = sub.length()
  if sub_len == 0 {
    return start
  }
  let mut i = start
  while i <= len - sub_len {
    let mut match_found = true
    let mut j = 0
    while j < sub_len {
      if s[i + j] != sub[j] {
        match_found = false
        break
      }
      j = j + 1
    }
    if match_found {
      return i
    }
    i = i + 1
  }
  -1
}

fn is_whitespace(c : UInt16) -> Bool {
  c == (32).to_uint16() || c == (9).to_uint16() || c == (13).to_uint16() || c == (10).to_uint16()
}

fn trim_whitespace(s : String) -> String {
  let len = s.length()
  let mut start = 0
  while start < len && is_whitespace(s[start]) {
    start = start + 1
  }
  let mut end = len
  while end > start && is_whitespace(s[end - 1]) {
    end = end - 1
  }
  s[start:end].to_owned()
}

fn split_whitespace(s : String) -> Array[String] {
  let res = []
  let len = s.length()
  let mut start = 0
  let mut in_word = false
  let mut i = 0
  while i < len {
    let c = s[i]
    if is_whitespace(c) {
      if in_word {
        res.push(s[start:i].to_owned())
        in_word = false
      }
    } else {
      if !in_word {
        start = i
        in_word = true
      }
    }
    i = i + 1
  }
  if in_word {
    res.push(s[start:len].to_owned())
  }
  res
}

fn check_standalone(
  template : String,
  tag_start : Int,
  tag_end : Int
) -> (Bool, Int, Int) {
  let len = template.length()
  
  // Look backward
  let mut p = tag_start - 1
  let mut only_ws_before = true
  let char_lf = (10).to_uint16()
  let char_space = (32).to_uint16()
  let char_tab = (9).to_uint16()
  let char_cr = (13).to_uint16()
  while p >= 0 {
    let c = template[p]
    if c == char_lf {
      break
    }
    if c != char_space && c != char_tab && c != char_cr {
      only_ws_before = false
      break
    }
    p = p - 1
  }
  if !only_ws_before {
    return (false, 0, 0)
  }
  let pre_ws_start = p + 1

  // Look forward
  let mut q = tag_end
  let mut only_ws_after = true
  let mut found_newline = false
  let mut newline_end = len
  while q < len {
    let c = template[q]
    if c == char_lf {
      found_newline = true
      newline_end = q + 1
      break
    }
    if c != char_space && c != char_tab && c != char_cr {
      only_ws_after = false
      break
    }
    q = q + 1
  }
  if !only_ws_after {
    return (false, 0, 0)
  }
  
  let post_ws_end = if found_newline { newline_end } else { q }
  (true, pre_ws_start, post_ws_end)
}

fn tokenize(template : String) -> Array[Token] raise MustacheError {
  let tokens = []
  let mut pos = 0
  let mut open_delim = "{{"
  let mut close_delim = "}}"
  let len = template.length()

  let char_lbrace = (123).to_uint16()
  let char_excl = (33).to_uint16()
  let char_hash = (35).to_uint16()
  let char_caret = (94).to_uint16()
  let char_slash = (47).to_uint16()
  let char_gt = (62).to_uint16()
  let char_eq = (61).to_uint16()
  let char_amp = (38).to_uint16()
  let char_space = (32).to_uint16()
  let char_tab = (9).to_uint16()

  while pos < len {
    let next_open = find_substring(template, open_delim, pos)
    if next_open == -1 {
      let text = template[pos:len].to_owned()
      if text.length() > 0 {
        tokens.push(Token::TText(text))
      }
      break
    }

    // Capture preceding text
    let mut pre_text_end = next_open

    // Process tag
    let mut is_triple = false
    let mut actual_close = close_delim
    let mut tag_content_start = next_open + open_delim.length()

    if open_delim == "{{" && tag_content_start < len && template[tag_content_start] == char_lbrace {
      is_triple = true
      actual_close = "}}}"
      tag_content_start = tag_content_start + 1
    }

    let next_close = find_substring(template, actual_close, tag_content_start)
    if next_close == -1 {
      raise ParseError("Unclosed tag starting at position \{next_open}")
    }

    let tag_end = next_close + actual_close.length()
    let raw_content = template[tag_content_start:next_close].to_owned()
    let content = trim_whitespace(raw_content)

    if content.length() == 0 {
      raise ParseError("Empty tag at position \{next_open}")
    }

    let first_char = content[0]
    let is_standalone_candidate = match first_char {
      _ if first_char == char_excl || first_char == char_hash || first_char == char_caret || first_char == char_slash || first_char == char_gt || first_char == char_eq => true
      _ => false
    }

    let mut is_standalone = false
    let mut post_ws_end = tag_end

    if is_standalone_candidate {
      let (standalone, pre_ws_start, post_end) = check_standalone(template, next_open, tag_end)
      if standalone {
        is_standalone = true
        pre_text_end = pre_ws_start
        post_ws_end = post_end
      }
    }

    // Push preceding text if there is any
    if pre_text_end > pos {
      let text = template[pos:pre_text_end].to_owned()
      tokens.push(Token::TText(text))
    }

    // Add token
    if first_char == char_excl {
      let comment_text = content[1:content.length()].to_owned()
      tokens.push(Token::TComment(comment_text))
    } else if first_char == char_hash {
      let name = trim_whitespace(content[1:content.length()].to_owned())
      tokens.push(Token::TSectionStart(name))
    } else if first_char == char_caret {
      let name = trim_whitespace(content[1:content.length()].to_owned())
      tokens.push(Token::TInvertedSectionStart(name))
    } else if first_char == char_slash {
      let name = trim_whitespace(content[1:content.length()].to_owned())
      tokens.push(Token::TSectionEnd(name))
    } else if first_char == char_gt {
      let name = trim_whitespace(content[1:content.length()].to_owned())
      let mut indent = ""
      if is_standalone {
        indent = template[pre_text_end:next_open].to_owned()
      } else {
        let mut p = next_open - 1
        while p >= 0 && (template[p] == char_space || template[p] == char_tab) {
          p = p - 1
        }
        indent = template[p + 1:next_open].to_owned()
      }
      tokens.push(Token::TPartial(name, indent = indent))
    } else if first_char == char_eq {
      let len_content = content.length()
      if len_content < 3 || content[len_content - 1] != char_eq {
        raise ParseError("Invalid delimiter change tag: \{content}")
      }
      let delims_str = trim_whitespace(content[1:len_content - 1].to_owned())
      let parts = split_whitespace(delims_str)
      if parts.length() != 2 {
        raise ParseError("Invalid delimiter specification: \{delims_str}")
      }
      open_delim = parts[0]
      close_delim = parts[1]
    } else if first_char == char_amp {
      let name = trim_whitespace(content[1:content.length()].to_owned())
      tokens.push(Token::TVariable(name, escape = false))
    } else {
      if is_triple {
        tokens.push(Token::TVariable(content, escape = false))
      } else {
        tokens.push(Token::TVariable(content, escape = true))
      }
    }

    pos = post_ws_end
  }

  tokens
}
