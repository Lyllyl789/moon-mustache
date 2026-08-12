///|
/// A deployable named template entry with lifecycle metadata.
pub struct RegistryEntry {
  name : String
  source : String
  plan : TemplatePlan
  revision : Int
  enabled : Bool
  tags : Array[String]
}

///|
pub fn RegistryEntry::name(self : RegistryEntry) -> String {
  self.name
}

///|
pub fn RegistryEntry::source(self : RegistryEntry) -> String {
  self.source
}

///|
pub fn RegistryEntry::plan(self : RegistryEntry) -> TemplatePlan {
  self.plan
}

///|
pub fn RegistryEntry::revision(self : RegistryEntry) -> Int {
  self.revision
}

///|
pub fn RegistryEntry::enabled(self : RegistryEntry) -> Bool {
  self.enabled
}

///|
pub fn RegistryEntry::tags(self : RegistryEntry) -> Array[String] {
  self.tags
}

///|
pub fn RegistryEntry::has_tag(self : RegistryEntry, tag : String) -> Bool {
  self.tags.contains(tag)
}

///|
pub fn RegistryEntry::is_revision(self : RegistryEntry, revision : Int) -> Bool {
  self.revision == revision
}

///|
/// A mutable registry for atomic template replacement and controlled rollout.
pub struct TemplateRegistry {
  entries : Map[String, RegistryEntry]
  mut order : Array[String]
  mut next_revision : Int
}

///|
pub fn TemplateRegistry::new() -> TemplateRegistry {
  { entries: {}, order: [], next_revision: 1 }
}

///|
/// Add a new template or replace an existing name with a new revision.
pub fn TemplateRegistry::register(
  self : TemplateRegistry,
  name : String,
  source : String,
  tags? : Array[String] = [],
) -> RegistryEntry raise MustacheError {
  if name.length() == 0 {
    raise RenderError("registry template name must not be empty")
  }
  let plan = TemplatePlan::compile(source)
  let existed = self.entries.get(name) is Some(_)
  let entry : RegistryEntry = {
    name,
    source,
    plan,
    revision: self.next_revision,
    enabled: true,
    tags,
  }
  self.entries[name] = entry
  if !existed {
    self.order.push(name)
  }
  self.next_revision += 1
  entry
}

///|
/// Register source after normalizing BOM and platform line endings.
pub fn TemplateRegistry::register_normalized(
  self : TemplateRegistry,
  name : String,
  source : String,
  tags? : Array[String] = [],
) -> RegistryEntry raise MustacheError {
  self.register(name, normalize_source(strip_bom(source)), tags~)
}

///|
/// Return an entry by name when it exists, regardless of enabled state.
pub fn TemplateRegistry::get(
  self : TemplateRegistry,
  name : String,
) -> RegistryEntry? {
  self.entries.get(name)
}

///|
/// Return whether a name is registered and enabled.
pub fn TemplateRegistry::is_enabled(
  self : TemplateRegistry,
  name : String,
) -> Bool {
  match self.entries.get(name) {
    None => false
    Some(entry) => entry.enabled()
  }
}

///|
/// Enable or disable a template without deleting its source or revision.
pub fn TemplateRegistry::set_enabled(
  self : TemplateRegistry,
  name : String,
  enabled : Bool,
) -> Bool {
  match self.entries.get(name) {
    None => false
    Some(entry) => {
      let updated : RegistryEntry = {
        name: entry.name,
        source: entry.source,
        plan: entry.plan,
        revision: entry.revision,
        enabled,
        tags: entry.tags,
      }
      self.entries[name] = updated
      true
    }
  }
}

///|
/// Remove a template from the active registry.
pub fn TemplateRegistry::remove(self : TemplateRegistry, name : String) -> Bool {
  let existed = self.entries.get(name) is Some(_)
  if existed {
    self.entries.remove(name)
    let remaining = []
    for old_name in self.order {
      if old_name != name {
        remaining.push(old_name)
      }
    }
    self.order = remaining
  }
  existed
}

///|
/// Return registered names in deterministic insertion order.
pub fn TemplateRegistry::names(self : TemplateRegistry) -> Array[String] {
  self.order
}

///|
pub fn TemplateRegistry::len(self : TemplateRegistry) -> Int {
  self.entries.length()
}

///|
pub fn TemplateRegistry::is_empty(self : TemplateRegistry) -> Bool {
  self.len() == 0
}

///|
pub fn TemplateRegistry::contains(
  self : TemplateRegistry,
  name : String,
) -> Bool {
  self.entries.get(name) is Some(_)
}

///|
pub fn TemplateRegistry::disabled_names(
  self : TemplateRegistry,
) -> Array[String] {
  let result = []
  for name in self.order {
    if !self.is_enabled(name) {
      result.push(name)
    }
  }
  result
}

///|
pub fn TemplateRegistry::revision_of(
  self : TemplateRegistry,
  name : String,
) -> Int? {
  match self.entries.get(name) {
    None => None
    Some(entry) => Some(entry.revision())
  }
}

///|
pub fn TemplateRegistry::source_of(
  self : TemplateRegistry,
  name : String,
) -> String? {
  match self.entries.get(name) {
    None => None
    Some(entry) => Some(entry.source())
  }
}

///|
pub fn TemplateRegistry::tagged_entries(
  self : TemplateRegistry,
  tag : String,
) -> Array[RegistryEntry] {
  let result = []
  for name in self.order {
    match self.entries.get(name) {
      None => ()
      Some(entry) => if entry.has_tag(tag) { result.push(entry) }
    }
  }
  result
}

///|
pub fn TemplateRegistry::latest_revision(self : TemplateRegistry) -> Int {
  self.next_revision - 1
}

///|
/// Return all names carrying a tag, preserving registration order.
pub fn TemplateRegistry::find_by_tag(
  self : TemplateRegistry,
  tag : String,
) -> Array[String] {
  let result = []
  for name in self.order {
    match self.entries.get(name) {
      None => ()
      Some(entry) => if entry.tags().contains(tag) { result.push(name) }
    }
  }
  result
}

///|
/// Return all currently enabled names carrying a tag.
pub fn TemplateRegistry::enabled_by_tag(
  self : TemplateRegistry,
  tag : String,
) -> Array[String] {
  let result = []
  for name in self.find_by_tag(tag) {
    if self.is_enabled(name) {
      result.push(name)
    }
  }
  result
}

///|
/// Render an enabled template with the registry's named partial map.
pub fn TemplateRegistry::render(
  self : TemplateRegistry,
  name : String,
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  match self.entries.get(name) {
    None => raise RenderError("unknown registry template: " + name)
    Some(entry) => {
      if !entry.enabled() {
        raise RenderError("registry template is disabled: " + name)
      }
      entry.plan().render(context, partials~, options~)
    }
  }
}

///|
/// Render after validating the template's complete dependency graph.
pub fn TemplateRegistry::render_checked(
  self : TemplateRegistry,
  name : String,
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  match self.entries.get(name) {
    None => raise RenderError("unknown registry template: " + name)
    Some(entry) => {
      if !entry.enabled() {
        raise RenderError("registry template is disabled: " + name)
      }
      entry.plan().render_checked(context, partials~, options~)
    }
  }
}

///|
/// Render a set of names against one context while preserving name order.
pub fn TemplateRegistry::render_many(
  self : TemplateRegistry,
  names : Array[String],
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> BatchReport {
  let items : Array[BatchItem] = []
  let mut succeeded = 0
  let mut failed = 0
  let mut output_chars = 0
  for name in names {
    match self.entries.get(name) {
      None => {
        items.push(BatchItem::Failed("unknown registry template: " + name))
        failed += 1
      }
      Some(entry) => {
        let item = render_batch_item(
          entry.plan().template(),
          context,
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
      }
    }
  }
  { items, succeeded, failed, output_chars }
}

///|
/// Audit every registered entry using one release policy.
pub fn TemplateRegistry::audit(
  self : TemplateRegistry,
  partials? : Map[String, String] = Map([]),
  policy? : AuditPolicy = AuditPolicy::strict(),
) -> AuditReport raise MustacheError {
  let findings = []
  let templates_checked = Ref(0)
  let nodes_checked = Ref(0)
  let partials_checked = Ref(0)
  for name in self.order {
    match self.entries.get(name) {
      None => ()
      Some(entry) =>
        if entry.enabled() {
          let report = entry.plan().template().audit(partials~, policy~)
          for finding in report.findings() {
            findings.push(finding)
          }
          templates_checked.val += report.templates_checked()
          nodes_checked.val += report.nodes_checked()
          partials_checked.val += report.partials_checked()
        }
    }
  }
  {
    findings,
    templates_checked: templates_checked.val,
    nodes_checked: nodes_checked.val,
    partials_checked: partials_checked.val,
  }
}

///|
/// Return source lengths for monitoring and release reports.
pub fn TemplateRegistry::source_lengths(
  self : TemplateRegistry,
) -> Map[String, Int] {
  let result : Map[String, Int] = {}
  for name in self.order {
    match self.entries.get(name) {
      None => ()
      Some(entry) => result[name] = entry.source().length()
    }
  }
  result
}

///|
/// Return the entry with the highest revision, if any.
pub fn TemplateRegistry::latest(self : TemplateRegistry) -> RegistryEntry? {
  if self.order.length() == 0 {
    None
  } else {
    let mut latest : RegistryEntry? = None
    for name in self.order {
      match self.entries.get(name) {
        None => ()
        Some(entry) =>
          match latest {
            None => latest = Some(entry)
            Some(old) =>
              if entry.revision() > old.revision() {
                latest = Some(entry)
              }
          }
      }
    }
    latest
  }
}

///|
/// Produce a compact operational summary.
pub fn TemplateRegistry::summary(self : TemplateRegistry) -> String {
  let mut enabled = 0
  for name in self.order {
    if self.is_enabled(name) {
      enabled += 1
    }
  }
  "templates=" +
  self.len().to_string() +
  ", enabled=" +
  enabled.to_string() +
  ", latest_revision=" +
  self.latest_revision().to_string()
}
