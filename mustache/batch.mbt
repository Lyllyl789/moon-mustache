///|
/// The outcome of one item in a batch render.
pub(all) enum BatchItem {
  Rendered(String)
  Failed(String)
} derive(Debug, Eq)

///|
/// Aggregate result for a batch render operation.
pub struct BatchReport {
  items : Array[BatchItem]
  succeeded : Int
  failed : Int
  output_chars : Int
}

///|
pub fn BatchReport::items(self : BatchReport) -> Array[BatchItem] {
  self.items
}

///|
pub fn BatchReport::succeeded(self : BatchReport) -> Int {
  self.succeeded
}

///|
pub fn BatchReport::failed(self : BatchReport) -> Int {
  self.failed
}

///|
pub fn BatchReport::output_chars(self : BatchReport) -> Int {
  self.output_chars
}

///|
pub fn BatchReport::is_success(self : BatchReport) -> Bool {
  self.failed == 0
}

///|
/// Convert one fallible render into a stable batch item.
fn render_batch_item(
  template : Template,
  context : Json,
  partials : Map[String, String],
  options : RenderOptions,
) -> BatchItem {
  let output = template.render_with_options(context, partials, options) catch {
    ParseError(message) => return BatchItem::Failed("ParseError: " + message)
    RenderError(message) => return BatchItem::Failed("RenderError: " + message)
  }
  BatchItem::Rendered(output)
}

///|
/// Convert one source render into a stable batch item.
fn render_source_batch_item(
  source : String,
  context : Json,
  partials : Map[String, String],
  options : RenderOptions,
) -> BatchItem {
  let output = render_string_with_options(source, context, partials, options) catch {
    ParseError(message) => return BatchItem::Failed("ParseError: " + message)
    RenderError(message) => return BatchItem::Failed("RenderError: " + message)
  }
  BatchItem::Rendered(output)
}

///|
/// Render one compiled template for many independent JSON contexts.
pub fn Template::render_batch(
  self : Template,
  contexts : Array[Json],
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> BatchReport {
  let items : Array[BatchItem] = []
  let mut succeeded = 0
  let mut failed = 0
  let mut output_chars = 0
  for context in contexts {
    let item = render_batch_item(self, context, partials, options)
    match item {
      Rendered(output) => {
        succeeded += 1
        output_chars += output.length()
      }
      Failed(_) => failed += 1
    }
    items.push(item)
  }
  { items, succeeded, failed, output_chars }
}

///|
/// Render many source templates using their own context and shared partials.
pub fn render_batch(
  sources : Array[String],
  contexts : Array[Json],
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> BatchReport {
  let items : Array[BatchItem] = []
  let mut succeeded = 0
  let mut failed = 0
  let mut output_chars = 0
  let mut index = 0
  while index < sources.length() && index < contexts.length() {
    let item = render_source_batch_item(
      sources[index],
      contexts[index],
      partials,
      options,
    )
    match item {
      Rendered(output) => {
        succeeded += 1
        output_chars += output.length()
      }
      Failed(_) => failed += 1
    }
    items.push(item)
    index += 1
  }
  while index < sources.length() {
    items.push(BatchItem::Failed("missing context for source"))
    failed += 1
    index += 1
  }
  while index < contexts.length() {
    items.push(BatchItem::Failed("missing source for context"))
    failed += 1
    index += 1
  }
  { items, succeeded, failed, output_chars }
}

///|
/// Return successful outputs while preserving their original order.
pub fn BatchReport::successful_outputs(self : BatchReport) -> Array[String] {
  let outputs = []
  for item in self.items {
    match item {
      Rendered(output) => outputs.push(output)
      Failed(_) => ()
    }
  }
  outputs
}

///|
/// Return failure messages while preserving their original order.
pub fn BatchReport::failure_messages(self : BatchReport) -> Array[String] {
  let messages = []
  for item in self.items {
    match item {
      Rendered(_) => ()
      Failed(message) => messages.push(message)
    }
  }
  messages
}

///|
/// Produce a compact operational summary for logs.
pub fn BatchReport::summary(self : BatchReport) -> String {
  "succeeded=" +
  self.succeeded.to_string() +
  ", failed=" +
  self.failed.to_string() +
  ", output_chars=" +
  self.output_chars.to_string()
}
