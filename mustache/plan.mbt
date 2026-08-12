///|
/// A compiled template together with source and dependency metadata.
pub struct TemplatePlan {
  source : TemplateSource
  template : Template
  query : TemplateQuery
}

///|
/// A partial dependency as observed by a compiled plan.
pub struct PlanDependency {
  name : String
  available : Bool
  source_chars : Int
  metrics : TemplateMetrics?
}

///|
pub fn PlanDependency::name(self : PlanDependency) -> String {
  self.name
}

///|
pub fn PlanDependency::available(self : PlanDependency) -> Bool {
  self.available
}

///|
pub fn PlanDependency::source_chars(self : PlanDependency) -> Int {
  self.source_chars
}

///|
pub fn PlanDependency::metrics(self : PlanDependency) -> TemplateMetrics? {
  self.metrics
}

///|
/// Compile a source string and prepare all static metadata once.
pub fn TemplatePlan::compile(
  source : String,
) -> TemplatePlan raise MustacheError {
  let template = compile(source)
  let source_info = TemplateSource::new(source)
  { source: source_info, template, query: TemplateQuery::new(template) }
}

///|
/// Build a plan using normalized source metadata while preserving render text.
pub fn TemplatePlan::compile_normalized(
  source : String,
) -> TemplatePlan raise MustacheError {
  let template = compile(source)
  {
    source: TemplateSource::normalized(source),
    template,
    query: TemplateQuery::new(template),
  }
}

///|
/// Return the original source metadata.
pub fn TemplatePlan::source(self : TemplatePlan) -> TemplateSource {
  self.source
}

///|
/// Return the compiled AST-backed template.
pub fn TemplatePlan::template(self : TemplatePlan) -> Template {
  self.template
}

///|
/// Return the precomputed static query object.
pub fn TemplatePlan::query(self : TemplatePlan) -> TemplateQuery {
  self.query
}

///|
/// Return a stable source key for a deployment cache.
pub fn TemplatePlan::cache_key(self : TemplatePlan, scope : String) -> String {
  self.source.cache_key(scope)
}

///|
/// Return the plan's static complexity metrics.
pub fn TemplatePlan::metrics(self : TemplatePlan) -> TemplateMetrics {
  self.query.metrics()
}

///|
/// Return names of all partials referenced by the root template.
pub fn TemplatePlan::partial_names(self : TemplatePlan) -> Array[String] {
  self.template.partial_names()
}

///|
/// Return whether this plan references a partial by name.
pub fn TemplatePlan::requires_partial(
  self : TemplatePlan,
  name : String,
) -> Bool {
  self.partial_names().contains(name)
}

///|
/// Resolve all direct partials and expose their own static metrics.
pub fn TemplatePlan::dependencies(
  self : TemplatePlan,
  partials : Map[String, String],
) -> Array[PlanDependency] raise MustacheError {
  let result = []
  for name in self.partial_names() {
    match partials.get(name) {
      None =>
        result.push({ name, available: false, source_chars: 0, metrics: None })
      Some(source) => {
        let compiled = compile(source)
        result.push({
          name,
          available: true,
          source_chars: source.length(),
          metrics: Some(compiled.analyze()),
        })
      }
    }
  }
  result
}

///|
/// Return all direct dependencies that are missing from a partial map.
pub fn TemplatePlan::missing_partials(
  self : TemplatePlan,
  partials : Map[String, String],
) -> Array[String] {
  let missing = []
  for name in self.partial_names() {
    if partials.get(name) is None {
      missing.push(name)
    }
  }
  missing
}

///|
/// Validate the complete partial graph before rendering.
pub fn TemplatePlan::validate(
  self : TemplatePlan,
  partials? : Map[String, String] = Map([]),
  strict_partials? : Bool = true,
  max_depth? : Int = 64,
) -> ValidationReport raise MustacheError {
  self.template.validate(partials~, strict_partials~, max_depth~)
}

///|
/// Render with the caller's operational limits.
pub fn TemplatePlan::render(
  self : TemplatePlan,
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  self.template.render_with_options(context, partials, options)
}

///|
/// Render and expose operational counters for production telemetry.
pub fn TemplatePlan::render_with_stats(
  self : TemplatePlan,
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> (String, RenderStats) raise MustacheError {
  self.template.render_with_stats(context, partials, options)
}

///|
/// Validate strict dependencies and render only when the plan is complete.
pub fn TemplatePlan::render_checked(
  self : TemplatePlan,
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  let report = self.validate(partials~, strict_partials=true)
  if report.has_errors() {
    raise RenderError("template plan validation failed: " + report.summary())
  }
  self.render(context, partials~, options~)
}

///|
/// Return the source position for an offset, clamped to valid bounds.
pub fn TemplatePlan::position(
  self : TemplatePlan,
  offset : Int,
) -> SourcePosition {
  self.source.position(offset)
}

///|
/// Return a diagnostic excerpt around an offset.
pub fn TemplatePlan::excerpt(
  self : TemplatePlan,
  offset : Int,
  radius? : Int = 1,
) -> String {
  let position = self.position(offset)
  self.source.excerpt(position.line(), radius~)
}

///|
/// Return a compact report suitable for build logs.
pub fn TemplatePlan::summary(self : TemplatePlan) -> String {
  let metrics = self.metrics()
  "source=" +
  self.source.fingerprint() +
  ", nodes=" +
  metrics.node_count().to_string() +
  ", variables=" +
  metrics.variable_count().to_string() +
  ", sections=" +
  metrics.section_count().to_string() +
  ", partials=" +
  metrics.partial_count().to_string()
}

///|
/// Return whether the source is empty or contains only whitespace.
pub fn TemplatePlan::is_blank(self : TemplatePlan) -> Bool {
  let text = self.source.text()
  for index in 0..<text.length() {
    let code = text[index]
    if code != (32).to_uint16() &&
      code != (9).to_uint16() &&
      code != (10).to_uint16() &&
      code != (13).to_uint16() {
      return false
    }
  }
  true
}

///|
/// Return all root variable names that can affect interpolation output.
pub fn TemplatePlan::required_variables(self : TemplatePlan) -> Array[String] {
  self.query.required_variables()
}

///|
/// Return all section names that can affect control flow.
pub fn TemplatePlan::control_names(self : TemplatePlan) -> Array[String] {
  self.query.control_names()
}

///|
/// Return a plan's dependency summary for tooling and review reports.
pub fn TemplatePlan::dependency_summary(self : TemplatePlan) -> String {
  self.query.dependency_summary()
}
