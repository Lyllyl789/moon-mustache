///|
pub fn escape_html(s : String) -> String {
  let sb = StringBuilder::new()
  // Iterate over Unicode scalar values rather than UTF-16 code units. This
  // keeps non-BMP characters such as emoji intact during escaped rendering.
  for c in s {
    if c == '&' {
      sb.write_string("&amp;")
    } else if c == '<' {
      sb.write_string("&lt;")
    } else if c == '>' {
      sb.write_string("&gt;")
    } else if c == '"' {
      sb.write_string("&quot;")
    } else if c == '\'' {
      sb.write_string("&#39;")
    } else {
      sb.write_char(c)
    }
  }
  sb.to_string()
}
