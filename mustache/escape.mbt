///|
pub fn escape_html(s : String) -> String {
  let sb = StringBuilder::new()
  let len = s.length()
  let mut i = 0
  let char_amp = (38).to_uint16()
  let char_lt = (60).to_uint16()
  let char_gt = (62).to_uint16()
  let char_quot = (34).to_uint16()
  let char_apos = (39).to_uint16()

  while i < len {
    let c = s[i]
    if c == char_amp {
      sb.write_string("&amp;")
    } else if c == char_lt {
      sb.write_string("&lt;")
    } else if c == char_gt {
      sb.write_string("&gt;")
    } else if c == char_quot {
      sb.write_string("&quot;")
    } else if c == char_apos {
      sb.write_string("&#39;")
    } else {
      let ch = c.to_int().to_char().unwrap()
      sb.write_char(ch)
    }
    i = i + 1
  }
  sb.to_string()
}
