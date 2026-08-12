///|
/// A reusable query object for dependency-aware tooling.
pub struct TemplateQuery {
  template : Template
  references : Array[TemplateReference]
  metrics : TemplateMetrics
}

///|
/// Build a query object once when an editor or build tool needs many lookups.
pub fn TemplateQuery::new(template : Template) -> TemplateQuery {
  { template, references: template.references(), metrics: template.analyze() }
}

///|
pub fn TemplateQuery::metrics(self : TemplateQuery) -> TemplateMetrics {
  self.metrics
}

///|
pub fn TemplateQuery::references(
  self : TemplateQuery,
) -> Array[TemplateReference] {
  self.references
}

///|
/// Return all references at a specific nesting depth.
pub fn TemplateQuery::references_at_depth(
  self : TemplateQuery,
  depth : Int,
) -> Array[TemplateReference] {
  let result = []
  for reference in self.references {
    if reference.depth() == depth {
      result.push(reference)
    }
  }
  result
}

///|
/// Return references of one category.
pub fn TemplateQuery::references_of_kind(
  self : TemplateQuery,
  kind : ReferenceKind,
) -> Array[TemplateReference] {
  let result = []
  for reference in self.references {
    if reference.kind() == kind {
      result.push(reference)
    }
  }
  result
}

///|
/// Return whether a reference category is present.
pub fn TemplateQuery::uses_kind(
  self : TemplateQuery,
  kind : ReferenceKind,
) -> Bool {
  for reference in self.references {
    if reference.kind() == kind {
      return true
    }
  }
  false
}

///|
/// Return the deepest nesting level used by a named reference.
pub fn TemplateQuery::name_depth(self : TemplateQuery, name : String) -> Int {
  let mut depth = -1
  for reference in self.references {
    if reference.name() == name && reference.depth() > depth {
      depth = reference.depth()
    }
  }
  depth
}

///|
/// Return a stable list of variable paths that must be supplied by callers.
pub fn TemplateQuery::required_variables(self : TemplateQuery) -> Array[String] {
  let result = []
  for reference in self.references {
    match reference.kind() {
      EscapedVariable | RawVariable =>
        if !result.contains(reference.name()) {
          result.push(reference.name())
        }
      _ => ()
    }
  }
  result
}

///|
/// Return the names of sections that may change output control flow.
pub fn TemplateQuery::control_names(self : TemplateQuery) -> Array[String] {
  let result = []
  for reference in self.references {
    match reference.kind() {
      Section | InvertedSection =>
        if !result.contains(reference.name()) {
          result.push(reference.name())
        }
      _ => ()
    }
  }
  result
}

///|
/// Return a human-readable dependency list for tooling output.
pub fn TemplateQuery::dependency_summary(self : TemplateQuery) -> String {
  let sb = StringBuilder::new()
  sb.write_string("variables=")
  sb.write_string(self.required_variables().join(","))
  sb.write_string("; controls=")
  sb.write_string(self.control_names().join(","))
  sb.write_string("; partials=")
  let partials = []
  for reference in self.references_of_kind(Partial) {
    if !partials.contains(reference.name()) {
      partials.push(reference.name())
    }
  }
  sb.write_string(partials.join(","))
  sb.to_string()
}

///|
/// Find all static references to a name, including role and depth.
pub fn TemplateQuery::find(
  self : TemplateQuery,
  name : String,
) -> Array[TemplateReference] {
  let result = []
  for reference in self.references {
    if reference.name() == name {
      result.push(reference)
    }
  }
  result
}

///|
/// Return a compiled template stored by this query.
pub fn TemplateQuery::template(self : TemplateQuery) -> Template {
  self.template
}

///|
/// Return whether a template is structurally empty.
pub fn TemplateQuery::is_empty(self : TemplateQuery) -> Bool {
  self.metrics.node_count() == 0
}

///|
/// Return whether the template has any dynamic control flow.
pub fn TemplateQuery::is_dynamic(self : TemplateQuery) -> Bool {
  self.metrics.section_count() > 0 || self.metrics.partial_count() > 0
}
