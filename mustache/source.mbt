///|
/// A zero-based location inside a template source string.
pub struct SourcePosition {
  offset : Int
  line : Int
  column : Int
}

///|
pub fn SourcePosition::offset(self : SourcePosition) -> Int {
  self.offset
}

///|
pub fn SourcePosition::line(self : SourcePosition) -> Int {
  self.line
}

///|
pub fn SourcePosition::column(self : SourcePosition) -> Int {
  self.column
}

///|
pub fn SourcePosition::summary(self : SourcePosition) -> String {
  self.line.to_string() + ":" + self.column.to_string()
}

///|
/// Return whether this is the first character of the source.
pub fn SourcePosition::is_start(self : SourcePosition) -> Bool {
  self.offset == 0
}

///|
/// A half-open source range with a start and end position.
pub struct SourceSpan {
  start : SourcePosition
  end : SourcePosition
}

///|
pub fn SourceSpan::start(self : SourceSpan) -> SourcePosition {
  self.start
}

///|
pub fn SourceSpan::end(self : SourceSpan) -> SourcePosition {
  self.end
}

///|
pub fn SourceSpan::length(self : SourceSpan) -> Int {
  self.end.offset() - self.start.offset()
}

///|
pub fn SourceSpan::contains(self : SourceSpan, offset : Int) -> Bool {
  offset >= self.start.offset() && offset < self.end.offset()
}

///|
pub fn SourceSpan::summary(self : SourceSpan) -> String {
  self.start.summary() + "-" + self.end.summary()
}

///|
/// Return whether a span has no width.
pub fn SourceSpan::is_empty(self : SourceSpan) -> Bool {
  self.start.offset() == self.end.offset()
}

///|
/// Source metadata used by editors, diagnostics, and cache keys.
pub struct TemplateSource {
  text : String
  line_starts : Array[Int]
}

///|
/// Normalize CRLF and CR input so generated diagnostics have stable offsets.
pub fn normalize_source(source : String) -> String {
  let sb = StringBuilder::new()
  let mut index = 0
  while index < source.length() {
    let code = source[index]
    if code == (13).to_uint16() {
      sb.write_char((10).to_char().unwrap())
      if index + 1 < source.length() && source[index + 1] == (10).to_uint16() {
        index += 1
      }
    } else {
      sb.write_char(code.to_int().to_char().unwrap())
    }
    index += 1
  }
  sb.to_string()
}

///|
/// Remove a UTF-16 BOM when a source was read from a text file.
pub fn strip_bom(source : String) -> String {
  if source.length() > 0 && source[0] == (65279).to_uint16() {
    source[1:].to_owned()
  } else {
    source
  }
}

///|
/// Build source metadata without parsing or changing the source.
pub fn TemplateSource::new(source : String) -> TemplateSource {
  let line_starts = [0]
  let mut index = 0
  while index < source.length() {
    if source[index] == (10).to_uint16() {
      line_starts.push(index + 1)
    }
    index += 1
  }
  { text: source, line_starts }
}

///|
/// Build normalized source metadata for cross-platform diagnostics.
pub fn TemplateSource::normalized(source : String) -> TemplateSource {
  TemplateSource::new(normalize_source(strip_bom(source)))
}

///|
/// Return the source exactly as stored in this object.
pub fn TemplateSource::text(self : TemplateSource) -> String {
  self.text
}

///|
/// Return the number of logical lines, including an empty final line.
pub fn TemplateSource::line_count(self : TemplateSource) -> Int {
  self.line_starts.length()
}

///|
/// Return the UTF-16 code-unit length of the source.
pub fn TemplateSource::char_count(self : TemplateSource) -> Int {
  self.text.length()
}

///|
/// Return the first offset of a one-based line number.
pub fn TemplateSource::line_start(self : TemplateSource, line : Int) -> Int? {
  if line < 1 || line > self.line_count() {
    None
  } else {
    Some(self.line_starts[line - 1])
  }
}

///|
/// Return a one-based line's text without its line ending.
pub fn TemplateSource::line_text(self : TemplateSource, line : Int) -> String? {
  if line < 1 || line > self.line_count() {
    return None
  }
  let start = self.line_starts[line - 1]
  let end = if line < self.line_count() {
    self.line_starts[line] - 1
  } else {
    self.text.length()
  }
  let actual_end = if end > start && self.text[end - 1] == (13).to_uint16() {
    end - 1
  } else {
    end
  }
  Some(self.text[start:actual_end].to_owned())
}

///|
/// Return the offset immediately before the line ending for a valid line.
pub fn TemplateSource::line_end(self : TemplateSource, line : Int) -> Int? {
  if line < 1 || line > self.line_count() {
    None
  } else if line < self.line_count() {
    Some(self.line_starts[line] - 1)
  } else {
    Some(self.text.length())
  }
}

///|
/// Return the half-open source range occupied by a line.
pub fn TemplateSource::line_span(
  self : TemplateSource,
  line : Int,
) -> SourceSpan? {
  match (self.line_start(line), self.line_end(line)) {
    (Some(start), Some(end)) => Some(self.span(start, end))
    _ => None
  }
}

///|
/// Return source text for a clamped range.
pub fn TemplateSource::range_text(
  self : TemplateSource,
  start : Int,
  end : Int,
) -> String {
  let span = self.span(start, end)
  self.text[span.start().offset():span.end().offset()].to_owned()
}

///|
/// Clamp an offset to source bounds and convert it to a one-based location.
pub fn TemplateSource::position(
  self : TemplateSource,
  offset : Int,
) -> SourcePosition {
  let bounded = if offset < 0 {
    0
  } else if offset > self.text.length() {
    self.text.length()
  } else {
    offset
  }
  let mut line_index = 0
  let mut low = 0
  let mut high = self.line_starts.length()
  while low < high {
    let middle = (low + high) / 2
    if self.line_starts[middle] <= bounded {
      line_index = middle
      low = middle + 1
    } else {
      high = middle
    }
  }
  {
    offset: bounded,
    line: line_index + 1,
    column: bounded - self.line_starts[line_index] + 1,
  }
}

///|
/// Return the one-based line containing an offset.
pub fn TemplateSource::line_at(self : TemplateSource, offset : Int) -> Int {
  self.position(offset).line()
}

///|
/// Return a conventional `line:column` diagnostic label for an offset.
pub fn TemplateSource::location_label(
  self : TemplateSource,
  offset : Int,
) -> String {
  self.position(offset).summary()
}

///|
/// Convert two offsets into a source span after clamping them.
pub fn TemplateSource::span(
  self : TemplateSource,
  start : Int,
  end : Int,
) -> SourceSpan {
  let first = self.position(start)
  let last = self.position(end)
  if last.offset() < first.offset() {
    { start: last, end: first }
  } else {
    { start: first, end: last }
  }
}

///|
/// Return a few lines surrounding a position for an error message.
pub fn TemplateSource::excerpt(
  self : TemplateSource,
  line : Int,
  radius? : Int = 1,
) -> String {
  let safe_radius = if radius < 0 { 0 } else { radius }
  let first = if line - safe_radius < 1 { 1 } else { line - safe_radius }
  let last = if line + safe_radius > self.line_count() {
    self.line_count()
  } else {
    line + safe_radius
  }
  let sb = StringBuilder::new()
  let mut current = first
  while current <= last {
    sb.write_string(current.to_string())
    sb.write_string(" | ")
    match self.line_text(current) {
      None => ()
      Some(text) => sb.write_string(text)
    }
    if current < last {
      sb.write_char((10).to_char().unwrap())
    }
    current += 1
  }
  sb.to_string()
}

///|
/// Return a deterministic compact hash suitable for cache keys.
pub fn TemplateSource::fingerprint(self : TemplateSource) -> String {
  let mut hash = 7
  for index in 0..<self.text.length() {
    hash = (hash * 131 + self.text[index].to_int()) % 1000000007
  }
  self.text.length().to_string() + ":" + hash.to_string()
}

///|
/// Return a stable key that distinguishes source text and a caller namespace.
pub fn TemplateSource::cache_key(
  self : TemplateSource,
  scope : String,
) -> String {
  scope + ":" + self.fingerprint()
}

///|
/// Return whether the source contains a requested literal range.
pub fn TemplateSource::contains(self : TemplateSource, needle : String) -> Bool {
  self.text.contains(needle)
}

///|
/// Return whether a line contains only spaces or tabs.
pub fn TemplateSource::line_is_blank(self : TemplateSource, line : Int) -> Bool {
  match self.line_text(line) {
    None => false
    Some(text) => {
      for index in 0..<text.length() {
        let code = text[index]
        if code != (32).to_uint16() && code != (9).to_uint16() {
          return false
        }
      }
      true
    }
  }
}
