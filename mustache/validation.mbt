///|
/// Severity of a static template validation issue.
pub(all) enum ValidationSeverity {
  Error
  Warning
} derive(Debug, Eq)

///|
/// A stable, machine-readable validation result.
pub struct ValidationIssue {
  code : String
  message : String
  severity : ValidationSeverity
  template_name : String
  depth : Int
}

///|
pub fn ValidationIssue::code(self : ValidationIssue) -> String {
  self.code
}

///|
pub fn ValidationIssue::message(self : ValidationIssue) -> String {
  self.message
}

///|
pub fn ValidationIssue::severity(self : ValidationIssue) -> ValidationSeverity {
  self.severity
}

///|
pub fn ValidationIssue::template_name(self : ValidationIssue) -> String {
  self.template_name
}

///|
pub fn ValidationIssue::depth(self : ValidationIssue) -> Int {
  self.depth
}

///|
/// Complete static validation report for a template and its partial graph.
pub struct ValidationReport {
  issues : Array[ValidationIssue]
  templates_checked : Int
  references_checked : Int
}

///|
pub fn ValidationReport::issues(
  self : ValidationReport,
) -> Array[ValidationIssue] {
  self.issues
}

///|
pub fn ValidationReport::templates_checked(self : ValidationReport) -> Int {
  self.templates_checked
}

///|
pub fn ValidationReport::references_checked(self : ValidationReport) -> Int {
  self.references_checked
}

///|
pub fn ValidationReport::has_errors(self : ValidationReport) -> Bool {
  for issue in self.issues {
    if issue.severity == Error {
      return true
    }
  }
  false
}

///|
pub fn ValidationReport::error_count(self : ValidationReport) -> Int {
  let mut count = 0
  for issue in self.issues {
    if issue.severity == Error {
      count += 1
    }
  }
  count
}

///|
pub fn ValidationReport::warning_count(self : ValidationReport) -> Int {
  let mut count = 0
  for issue in self.issues {
    if issue.severity == Warning {
      count += 1
    }
  }
  count
}

///|
fn add_issue(
  issues : Array[ValidationIssue],
  code : String,
  message : String,
  severity : ValidationSeverity,
  template_name : String,
  depth : Int,
) -> Unit {
  issues.push({ code, message, severity, template_name, depth })
}

///|
fn validate_nodes(
  nodes : Array[Node],
  template_name : String,
  depth : Int,
  max_depth : Int,
  issues : Array[ValidationIssue],
  refs : Ref[Int],
) -> Unit {
  if depth > max_depth {
    add_issue(
      issues,
      "MAX_DEPTH",
      "template nesting exceeds configured validation depth",
      Error,
      template_name,
      depth,
    )
  }
  for node in nodes {
    match node {
      Text(_) => ()
      Variable(name, ..) => {
        refs.val += 1
        if name.length() == 0 {
          add_issue(
            issues,
            "EMPTY_VARIABLE",
            "variable name must not be empty",
            Error,
            template_name,
            depth,
          )
        }
      }
      Section(name, children, ..) => {
        refs.val += 1
        if name.length() == 0 {
          add_issue(
            issues,
            "EMPTY_SECTION",
            "section name must not be empty",
            Error,
            template_name,
            depth,
          )
        }
        validate_nodes(
          children,
          template_name,
          depth + 1,
          max_depth,
          issues,
          refs,
        )
      }
      Partial(name, ..) => {
        refs.val += 1
        if name.length() == 0 {
          add_issue(
            issues,
            "EMPTY_PARTIAL",
            "partial name must not be empty",
            Error,
            template_name,
            depth,
          )
        }
      }
    }
  }
}

///|
fn validate_partials(
  name : String,
  template : Template,
  partials : Map[String, String],
  strict_partials : Bool,
  max_depth : Int,
  issues : Array[ValidationIssue],
  visited : Map[String, Bool],
  refs : Ref[Int],
  templates : Ref[Int],
) -> Unit raise MustacheError {
  if visited.get(name) is Some(true) {
    return
  }
  visited[name] = true
  templates.val += 1
  validate_nodes(template.nodes, name, 0, max_depth, issues, refs)
  for partial_name in template.partial_names() {
    match partials.get(partial_name) {
      None => {
        let severity = if strict_partials { Error } else { Warning }
        let code = if strict_partials {
          "MISSING_PARTIAL"
        } else {
          "OPTIONAL_PARTIAL"
        }
        add_issue(
          issues,
          code,
          "partial is not present in the supplied bundle: " + partial_name,
          severity,
          name,
          0,
        )
      }
      Some(source) => {
        let compiled = compile(source)
        validate_partials(
          partial_name, compiled, partials, strict_partials, max_depth, issues, visited,
          refs, templates,
        )
      }
    }
  }
}

///|
/// Validate syntax-derived structure and the complete partial dependency graph.
pub fn Template::validate(
  self : Template,
  partials? : Map[String, String] = Map([]),
  strict_partials? : Bool = false,
  max_depth? : Int = 64,
) -> ValidationReport raise MustacheError {
  if max_depth < 1 {
    raise RenderError("validation max_depth must be positive")
  }
  let issues = []
  let visited : Map[String, Bool] = {}
  let refs = Ref(0)
  let templates = Ref(0)
  validate_partials(
    "<root>", self, partials, strict_partials, max_depth, issues, visited, refs,
    templates,
  )
  { issues, templates_checked: templates.val, references_checked: refs.val }
}

///|
/// Validate a raw template and return structured issues.
pub fn validate_string(
  source : String,
  partials? : Map[String, String] = Map([]),
  strict_partials? : Bool = false,
  max_depth? : Int = 64,
) -> ValidationReport raise MustacheError {
  let template = compile(source)
  template.validate(partials~, strict_partials~, max_depth~)
}

///|
/// Convert a report into a compact human-readable summary.
pub fn ValidationReport::summary(self : ValidationReport) -> String {
  let sb = StringBuilder::new()
  sb.write_string("templates=")
  sb.write_string(self.templates_checked.to_string())
  sb.write_string(", references=")
  sb.write_string(self.references_checked.to_string())
  sb.write_string(", errors=")
  sb.write_string(self.error_count().to_string())
  sb.write_string(", warnings=")
  sb.write_string(self.warning_count().to_string())
  for issue in self.issues {
    sb.write_string("\n[")
    sb.write_string(issue.code)
    sb.write_string("] ")
    sb.write_string(issue.message)
  }
  sb.to_string()
}
