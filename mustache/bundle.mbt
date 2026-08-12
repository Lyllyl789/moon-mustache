///|
/// A named, precompiled template collection with shared partials.
pub struct TemplateBundle {
  templates : Map[String, Template]
  sources : Map[String, String]
  mut partials : Map[String, String]
}

///|
pub fn TemplateBundle::new(
  partials? : Map[String, String] = Map([]),
) -> TemplateBundle {
  { templates: {}, sources: {}, partials }
}

///|
/// Add or replace a named partial source.
pub fn TemplateBundle::add_partial(
  self : TemplateBundle,
  name : String,
  source : String,
) -> Unit {
  self.partials[name] = source
}

///|
/// Add or replace a named template and compile it immediately.
pub fn TemplateBundle::add_template(
  self : TemplateBundle,
  name : String,
  source : String,
) -> Unit raise MustacheError {
  let compiled = compile(source)
  self.sources[name] = source
  self.templates[name] = compiled
}

///|
/// Remove a named template from the bundle.
pub fn TemplateBundle::remove_template(
  self : TemplateBundle,
  name : String,
) -> Bool {
  let existed = self.templates.get(name) is Some(_)
  if existed {
    self.templates.remove(name)
    self.sources.remove(name)
  }
  existed
}

///|
/// Remove a named partial from the bundle.
pub fn TemplateBundle::remove_partial(
  self : TemplateBundle,
  name : String,
) -> Bool {
  let existed = self.partials.get(name) is Some(_)
  if existed {
    self.partials.remove(name)
  }
  existed
}

///|
/// Return whether a named template exists.
pub fn TemplateBundle::has_template(
  self : TemplateBundle,
  name : String,
) -> Bool {
  self.templates.get(name) is Some(_)
}

///|
/// Return whether a named partial exists.
pub fn TemplateBundle::has_partial(
  self : TemplateBundle,
  name : String,
) -> Bool {
  self.partials.get(name) is Some(_)
}

///|
/// Return all template names in insertion order.
pub fn TemplateBundle::template_names(self : TemplateBundle) -> Array[String] {
  let names = []
  for name, _ in self.templates {
    names.push(name)
  }
  names
}

///|
/// Return all partial names in insertion order.
pub fn TemplateBundle::partial_names(self : TemplateBundle) -> Array[String] {
  let names = []
  for name, _ in self.partials {
    names.push(name)
  }
  names
}

///|
/// Render a named template with the bundle's partials.
pub fn TemplateBundle::render(
  self : TemplateBundle,
  name : String,
  context : Json,
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  match self.templates.get(name) {
    None => raise RenderError("Unknown bundle template: " + name)
    Some(template) =>
      template.render_with_options(context, self.partials, options)
  }
}

///|
/// Render a named template and return runtime counters.
pub fn TemplateBundle::render_with_stats(
  self : TemplateBundle,
  name : String,
  context : Json,
  options? : RenderOptions = RenderOptions::default(),
) -> (String, RenderStats) raise MustacheError {
  match self.templates.get(name) {
    None => raise RenderError("Unknown bundle template: " + name)
    Some(template) =>
      template.render_with_stats(context, self.partials, options)
  }
}

///|
/// Validate every named template and its shared partial dependency graph.
pub fn TemplateBundle::validate(
  self : TemplateBundle,
  strict_partials? : Bool = true,
  max_depth? : Int = 64,
) -> ValidationReport raise MustacheError {
  let issues = []
  let mut templates_checked = 0
  let mut references_checked = 0
  for name, template in self.templates {
    let report = template.validate(
      partials=self.partials,
      strict_partials~,
      max_depth~,
    )
    templates_checked += report.templates_checked()
    references_checked += report.references_checked()
    for issue in report.issues() {
      issues.push(issue)
    }
    if name.length() == 0 {
      issues.push({
        code: "EMPTY_TEMPLATE_NAME",
        message: "template names must not be empty",
        severity: Error,
        template_name: name,
        depth: 0,
      })
    }
  }
  { issues, templates_checked, references_checked }
}

///|
/// Return a compiled template's static metrics from the bundle.
pub fn TemplateBundle::metrics(
  self : TemplateBundle,
  name : String,
) -> TemplateMetrics? {
  match self.templates.get(name) {
    None => None
    Some(template) => Some(template.analyze())
  }
}

///|
/// Return all source names and their source lengths.
pub fn TemplateBundle::source_lengths(
  self : TemplateBundle,
) -> Map[String, Int] {
  let lengths : Map[String, Int] = {}
  for name, source in self.sources {
    lengths[name] = source.length()
  }
  lengths
}

///|
/// Replace all partials atomically from a map supplied by an application.
pub fn TemplateBundle::replace_partials(
  self : TemplateBundle,
  partials : Map[String, String],
) -> Unit {
  self.partials = partials
}

///|
/// Return a defensive copy of the current partial source map.
pub fn TemplateBundle::partials(self : TemplateBundle) -> Map[String, String] {
  self.partials
}

///|
/// Return a defensive copy of the current template source map.
pub fn TemplateBundle::sources(self : TemplateBundle) -> Map[String, String] {
  self.sources
}
