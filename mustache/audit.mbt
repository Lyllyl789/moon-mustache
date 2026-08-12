///|
/// Severity used by release audits.
pub(all) enum AuditSeverity {
  AuditError
  AuditWarning
  AuditInfo
} derive(Eq)

///|
/// One actionable finding produced by a template release audit.
pub struct AuditFinding {
  code : String
  message : String
  severity : AuditSeverity
  template_name : String
  related_name : String
}

///|
pub fn AuditFinding::code(self : AuditFinding) -> String {
  self.code
}

///|
pub fn AuditFinding::message(self : AuditFinding) -> String {
  self.message
}

///|
pub fn AuditFinding::severity(self : AuditFinding) -> AuditSeverity {
  self.severity
}

///|
pub fn AuditFinding::template_name(self : AuditFinding) -> String {
  self.template_name
}

///|
pub fn AuditFinding::related_name(self : AuditFinding) -> String {
  self.related_name
}

///|
/// Release policy for static complexity and dependency checks.
pub struct AuditPolicy {
  max_nodes : Int
  max_depth : Int
  max_text_chars : Int
  max_partials : Int
  require_partials : Bool
  require_variables : Bool
  reject_duplicate_partials : Bool
}

///|
/// Construct a conservative policy suitable for CI release gates.
pub fn AuditPolicy::strict() -> AuditPolicy {
  {
    max_nodes: 10000,
    max_depth: 64,
    max_text_chars: 1000000,
    max_partials: 256,
    require_partials: true,
    require_variables: false,
    reject_duplicate_partials: false,
  }
}

///|
/// Construct a policy with explicit operational limits.
pub fn AuditPolicy::new(
  max_nodes? : Int = 10000,
  max_depth? : Int = 64,
  max_text_chars? : Int = 1000000,
  max_partials? : Int = 256,
  require_partials? : Bool = true,
  require_variables? : Bool = false,
  reject_duplicate_partials? : Bool = false,
) -> AuditPolicy raise MustacheError {
  if max_nodes < 1 || max_depth < 1 || max_text_chars < 1 || max_partials < 0 {
    raise RenderError("audit policy limits must be non-negative and positive")
  }
  {
    max_nodes,
    max_depth,
    max_text_chars,
    max_partials,
    require_partials,
    require_variables,
    reject_duplicate_partials,
  }
}

///|
/// Return the maximum AST node count allowed by this policy.
pub fn AuditPolicy::max_nodes(self : AuditPolicy) -> Int {
  self.max_nodes
}

///|
/// Return the maximum static nesting depth allowed by this policy.
pub fn AuditPolicy::max_depth(self : AuditPolicy) -> Int {
  self.max_depth
}

///|
/// Return the maximum literal text size allowed by this policy.
pub fn AuditPolicy::max_text_chars(self : AuditPolicy) -> Int {
  self.max_text_chars
}

///|
/// Return the maximum direct partial count allowed by this policy.
pub fn AuditPolicy::max_partials(self : AuditPolicy) -> Int {
  self.max_partials
}

///|
/// Return whether missing partials are release errors.
pub fn AuditPolicy::require_partials(self : AuditPolicy) -> Bool {
  self.require_partials
}

///|
/// Return whether variable references must be covered by a data contract.
pub fn AuditPolicy::require_variables(self : AuditPolicy) -> Bool {
  self.require_variables
}

///|
/// Return whether repeated partial tags should be reported.
pub fn AuditPolicy::reject_duplicate_partials(self : AuditPolicy) -> Bool {
  self.reject_duplicate_partials
}

///|
/// Complete release audit result.
pub struct AuditReport {
  findings : Array[AuditFinding]
  templates_checked : Int
  nodes_checked : Int
  partials_checked : Int
}

///|
pub fn AuditReport::findings(self : AuditReport) -> Array[AuditFinding] {
  self.findings
}

///|
pub fn AuditReport::templates_checked(self : AuditReport) -> Int {
  self.templates_checked
}

///|
pub fn AuditReport::nodes_checked(self : AuditReport) -> Int {
  self.nodes_checked
}

///|
pub fn AuditReport::partials_checked(self : AuditReport) -> Int {
  self.partials_checked
}

///|
pub fn AuditReport::error_count(self : AuditReport) -> Int {
  let mut count = 0
  for finding in self.findings {
    if finding.severity() == AuditError {
      count += 1
    }
  }
  count
}

///|
pub fn AuditReport::warning_count(self : AuditReport) -> Int {
  let mut count = 0
  for finding in self.findings {
    if finding.severity() == AuditWarning {
      count += 1
    }
  }
  count
}

///|
pub fn AuditReport::is_release_ready(self : AuditReport) -> Bool {
  self.error_count() == 0
}

///|
fn audit_finding(
  findings : Array[AuditFinding],
  code : String,
  message : String,
  severity : AuditSeverity,
  template_name : String,
  related_name : String,
) -> Unit {
  findings.push({ code, message, severity, template_name, related_name })
}

///|
fn audit_template(
  name : String,
  template : Template,
  partials : Map[String, String],
  policy : AuditPolicy,
  findings : Array[AuditFinding],
  visited : Map[String, Bool],
  templates_checked : Ref[Int],
  nodes_checked : Ref[Int],
  partials_checked : Ref[Int],
) -> Unit raise MustacheError {
  if visited.get(name) is Some(true) {
    return
  }
  visited[name] = true
  templates_checked.val += 1
  let metrics = template.analyze()
  nodes_checked.val += metrics.node_count()
  partials_checked.val += metrics.partial_count()
  if metrics.node_count() > policy.max_nodes() {
    audit_finding(
      findings,
      "NODE_LIMIT",
      "compiled template exceeds the configured AST node limit",
      AuditError,
      name,
      "",
    )
  }
  if metrics.max_depth() > policy.max_depth() {
    audit_finding(
      findings,
      "DEPTH_LIMIT",
      "compiled template exceeds the configured nesting limit",
      AuditError,
      name,
      "",
    )
  }
  if metrics.text_chars() > policy.max_text_chars() {
    audit_finding(
      findings,
      "TEXT_LIMIT",
      "literal template text exceeds the configured size limit",
      AuditError,
      name,
      "",
    )
  }
  if metrics.partial_count() > policy.max_partials() {
    audit_finding(
      findings,
      "PARTIAL_LIMIT",
      "template references more partials than the policy permits",
      AuditError,
      name,
      "",
    )
  }
  if policy.require_variables() && template.variable_names().length() == 0 {
    audit_finding(
      findings,
      "VARIABLE_CONTRACT",
      "policy requires at least one declared variable reference",
      AuditWarning,
      name,
      "",
    )
  }
  let names = template.partial_names()
  let seen : Map[String, Bool] = {}
  for partial_name in names {
    if policy.reject_duplicate_partials() &&
      seen.get(partial_name) is Some(true) {
      audit_finding(
        findings,
        "DUPLICATE_PARTIAL",
        "partial is referenced more than once by this template",
        AuditWarning,
        name,
        partial_name,
      )
    }
    seen[partial_name] = true
    match partials.get(partial_name) {
      None => {
        let severity = if policy.require_partials() {
          AuditError
        } else {
          AuditWarning
        }
        audit_finding(
          findings, "MISSING_PARTIAL", "partial source is absent from the release bundle",
          severity, name, partial_name,
        )
      }
      Some(source) => {
        let child = compile(source)
        audit_template(
          partial_name, child, partials, policy, findings, visited, templates_checked,
          nodes_checked, partials_checked,
        )
      }
    }
  }
}

///|
/// Audit one compiled template and all of its partial dependencies.
pub fn Template::audit(
  self : Template,
  partials? : Map[String, String] = Map([]),
  policy? : AuditPolicy = AuditPolicy::strict(),
) -> AuditReport raise MustacheError {
  let findings = []
  let visited : Map[String, Bool] = {}
  let templates_checked = Ref(0)
  let nodes_checked = Ref(0)
  let partials_checked = Ref(0)
  audit_template(
    "<root>", self, partials, policy, findings, visited, templates_checked, nodes_checked,
    partials_checked,
  )
  {
    findings,
    templates_checked: templates_checked.val,
    nodes_checked: nodes_checked.val,
    partials_checked: partials_checked.val,
  }
}

///|
/// Audit every template in a named bundle using one release policy.
pub fn TemplateBundle::audit(
  self : TemplateBundle,
  policy? : AuditPolicy = AuditPolicy::strict(),
) -> AuditReport raise MustacheError {
  let findings = []
  let visited : Map[String, Bool] = {}
  let templates_checked = Ref(0)
  let nodes_checked = Ref(0)
  let partials_checked = Ref(0)
  for name, template in self.templates {
    audit_template(
      name,
      template,
      self.partials,
      policy,
      findings,
      visited,
      templates_checked,
      nodes_checked,
      partials_checked,
    )
  }
  {
    findings,
    templates_checked: templates_checked.val,
    nodes_checked: nodes_checked.val,
    partials_checked: partials_checked.val,
  }
}

///|
/// Render only when the static release audit has no errors.
pub fn Template::render_audited(
  self : Template,
  context : Json,
  partials? : Map[String, String] = Map([]),
  policy? : AuditPolicy = AuditPolicy::strict(),
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  let report = self.audit(partials~, policy~)
  if !report.is_release_ready() {
    raise RenderError(
      "template audit failed: " + report.error_count().to_string(),
    )
  }
  self.render_with_options(context, partials, options)
}

///|
/// Produce a compact release-audit summary for CI logs.
pub fn AuditReport::summary(self : AuditReport) -> String {
  "templates=" +
  self.templates_checked.to_string() +
  ", nodes=" +
  self.nodes_checked.to_string() +
  ", partials=" +
  self.partials_checked.to_string() +
  ", errors=" +
  self.error_count().to_string() +
  ", warnings=" +
  self.warning_count().to_string()
}
