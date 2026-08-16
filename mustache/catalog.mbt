///|
/// Metadata attached to a deployable template revision.
pub struct TemplateRevision {
  name : String
  version : Int
  source : String
  template : Template
  tags : Array[String]
}

///|
pub fn TemplateRevision::name(self : TemplateRevision) -> String {
  self.name
}

///|
pub fn TemplateRevision::version(self : TemplateRevision) -> Int {
  self.version
}

///|
pub fn TemplateRevision::source(self : TemplateRevision) -> String {
  self.source
}

///|
pub fn TemplateRevision::template(self : TemplateRevision) -> Template {
  self.template
}

///|
pub fn TemplateRevision::tags(self : TemplateRevision) -> Array[String] {
  self.tags
}

///|
/// Registry for named and aliased template revisions.
pub struct TemplateCatalog {
  revisions : Map[String, TemplateRevision]
  mut aliases : Map[String, String]
  mut next_version : Int
}

///|
pub fn TemplateCatalog::new() -> TemplateCatalog {
  { revisions: {}, aliases: {}, next_version: 1 }
}

///|
fn catalog_key(scope : String, name : String) -> String {
  if scope.length() == 0 {
    name
  } else {
    scope + "/" + name
  }
}

///|
/// Publish a new immutable revision under a namespace and name.
pub fn TemplateCatalog::publish(
  self : TemplateCatalog,
  scope : String,
  name : String,
  source : String,
  tags? : Array[String] = [],
) -> TemplateRevision raise MustacheError {
  if name.length() == 0 {
    raise RenderError("catalog template name must not be empty")
  }
  let key = catalog_key(scope, name)
  let compiled = compile(source)
  let revision : TemplateRevision = {
    name: key,
    version: self.next_version,
    source,
    template: compiled,
    tags,
  }
  self.revisions[key] = revision
  self.next_version += 1
  revision
}

///|
/// Replace an alias target without changing the target revision.
pub fn TemplateCatalog::set_alias(
  self : TemplateCatalog,
  alias_name : String,
  target : String,
) -> Bool {
  if self.revisions.get(target) is None {
    false
  } else {
    self.aliases[alias_name] = target
    true
  }
}

///|
fn TemplateCatalog::resolve_catalog_key(
  self : TemplateCatalog,
  name : String,
) -> String {
  match self.aliases.get(name) {
    None => name
    Some(target) => target
  }
}

///|
/// Resolve a name or alias to a published revision.
pub fn TemplateCatalog::get(
  self : TemplateCatalog,
  name : String,
) -> TemplateRevision? {
  let key = self.resolve_catalog_key(name)
  self.revisions.get(key)
}

///|
/// Render a published revision with shared partials.
pub fn TemplateCatalog::render(
  self : TemplateCatalog,
  name : String,
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  match self.get(name) {
    None => raise RenderError("unknown catalog template: " + name)
    Some(revision) =>
      revision.template.render_with_options(context, partials, options)
  }
}

///|
/// Return whether a revision or alias exists.
pub fn TemplateCatalog::contains(self : TemplateCatalog, name : String) -> Bool {
  self.get(name) is Some(_)
}

///|
/// Remove a revision and aliases that point to it.
pub fn TemplateCatalog::remove(self : TemplateCatalog, name : String) -> Bool {
  let key = self.resolve_catalog_key(name)
  let existed = self.revisions.get(key) is Some(_)
  if existed {
    self.revisions.remove(key)
    let next_aliases : Map[String, String] = Map([])
    for alias_name, target in self.aliases {
      if target != key {
        next_aliases[alias_name] = target
      }
    }
    self.aliases = next_aliases
  }
  existed
}

///|
/// Return all published revision names.
pub fn TemplateCatalog::names(self : TemplateCatalog) -> Array[String] {
  let names = []
  for name, _ in self.revisions {
    names.push(name)
  }
  names
}

///|
/// Return all aliases and their targets.
pub fn TemplateCatalog::aliases(self : TemplateCatalog) -> Map[String, String] {
  self.aliases
}

///|
/// Return all revisions carrying a requested tag.
pub fn TemplateCatalog::find_by_tag(
  self : TemplateCatalog,
  tag : String,
) -> Array[TemplateRevision] {
  let result = []
  for _, revision in self.revisions {
    if revision.tags.contains(tag) {
      result.push(revision)
    }
  }
  result
}

///|
/// Return the latest assigned version number.
pub fn TemplateCatalog::latest_version(self : TemplateCatalog) -> Int {
  self.next_version - 1
}

///|
/// Return catalog metadata suitable for a release report.
pub fn TemplateCatalog::summary(self : TemplateCatalog) -> String {
  "revisions=" +
  self.revisions.length().to_string() +
  ", aliases=" +
  self.aliases.length().to_string() +
  ", latest_version=" +
  self.latest_version().to_string()
}
