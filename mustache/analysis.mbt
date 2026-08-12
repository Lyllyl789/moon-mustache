///|
/// Reference categories reported by the static template analyzer.
pub(all) enum ReferenceKind {
  EscapedVariable
  RawVariable
  Section
  InvertedSection
  Partial
} derive(Debug, Eq)

///|
/// A named reference together with its nesting information.
pub struct TemplateReference {
  name : String
  kind : ReferenceKind
  mut depth : Int
  mut occurrences : Int
}

///|
pub fn TemplateReference::name(self : TemplateReference) -> String {
  self.name
}

///|
pub fn TemplateReference::kind(self : TemplateReference) -> ReferenceKind {
  self.kind
}

///|
pub fn TemplateReference::depth(self : TemplateReference) -> Int {
  self.depth
}

///|
pub fn TemplateReference::occurrences(self : TemplateReference) -> Int {
  self.occurrences
}

///|
/// Aggregate complexity and dependency information for a compiled template.
pub struct TemplateMetrics {
  mut text_chars : Int
  mut node_count : Int
  mut variable_count : Int
  mut section_count : Int
  mut partial_count : Int
  mut max_depth : Int
  mut unique_reference_count : Int
}

///|
pub fn TemplateMetrics::text_chars(self : TemplateMetrics) -> Int {
  self.text_chars
}

///|
pub fn TemplateMetrics::node_count(self : TemplateMetrics) -> Int {
  self.node_count
}

///|
pub fn TemplateMetrics::variable_count(self : TemplateMetrics) -> Int {
  self.variable_count
}

///|
pub fn TemplateMetrics::section_count(self : TemplateMetrics) -> Int {
  self.section_count
}

///|
pub fn TemplateMetrics::partial_count(self : TemplateMetrics) -> Int {
  self.partial_count
}

///|
pub fn TemplateMetrics::max_depth(self : TemplateMetrics) -> Int {
  self.max_depth
}

///|
pub fn TemplateMetrics::unique_reference_count(self : TemplateMetrics) -> Int {
  self.unique_reference_count
}

///|
fn reference_key(name : String, kind : ReferenceKind) -> String {
  let prefix = match kind {
    EscapedVariable => "v:"
    RawVariable => "r:"
    Section => "s:"
    InvertedSection => "i:"
    Partial => "p:"
  }
  prefix + name
}

///|
fn find_reference(
  references : Array[TemplateReference],
  name : String,
  kind : ReferenceKind,
) -> Int {
  let key = reference_key(name, kind)
  let mut index = 0
  while index < references.length() {
    let item = references[index]
    if reference_key(item.name, item.kind) == key {
      return index
    }
    index += 1
  }
  -1
}

///|
fn record_reference(
  references : Array[TemplateReference],
  name : String,
  kind : ReferenceKind,
  depth : Int,
) -> Unit {
  let index = find_reference(references, name, kind)
  if index < 0 {
    references.push({ name, kind, depth, occurrences: 1 })
  } else {
    let old = references[index]
    old.occurrences += 1
    if depth > old.depth {
      old.depth = depth
    }
    references[index] = old
  }
}

///|
fn analyze_nodes(
  nodes : Array[Node],
  depth : Int,
  metrics : TemplateMetrics,
  references : Array[TemplateReference],
) -> Unit {
  if depth > metrics.max_depth {
    metrics.max_depth = depth
  }
  for node in nodes {
    metrics.node_count += 1
    match node {
      Text(text) => metrics.text_chars += text.length()
      Variable(name, escape~) => {
        metrics.variable_count += 1
        let kind = if escape { EscapedVariable } else { RawVariable }
        record_reference(references, name, kind, depth)
      }
      Section(name, children, inverted~) => {
        metrics.section_count += 1
        let kind = if inverted { InvertedSection } else { Section }
        record_reference(references, name, kind, depth)
        analyze_nodes(children, depth + 1, metrics, references)
      }
      Partial(name, ..) => {
        metrics.partial_count += 1
        record_reference(references, name, Partial, depth)
      }
    }
  }
}

///|
/// Analyze a compiled template without rendering it.
pub fn Template::analyze(self : Template) -> TemplateMetrics {
  let metrics : TemplateMetrics = {
    text_chars: 0,
    node_count: 0,
    variable_count: 0,
    section_count: 0,
    partial_count: 0,
    max_depth: 0,
    unique_reference_count: 0,
  }
  let references = []
  analyze_nodes(self.nodes, 0, metrics, references)
  metrics.unique_reference_count = references.length()
  metrics
}

///|
/// Return deduplicated variables, sections, and partial dependencies.
pub fn Template::references(self : Template) -> Array[TemplateReference] {
  let metrics : TemplateMetrics = {
    text_chars: 0,
    node_count: 0,
    variable_count: 0,
    section_count: 0,
    partial_count: 0,
    max_depth: 0,
    unique_reference_count: 0,
  }
  let references = []
  analyze_nodes(self.nodes, 0, metrics, references)
  references
}

///|
fn names_for_kind(
  references : Array[TemplateReference],
  kind : ReferenceKind,
) -> Array[String] {
  let names = []
  for item in references {
    if item.kind == kind {
      names.push(item.name)
    }
  }
  names
}

///|
/// Return escaped and raw variable names in first-use order.
pub fn Template::variable_names(self : Template) -> Array[String] {
  let refs = self.references()
  let names = names_for_kind(refs, EscapedVariable)
  for name in names_for_kind(refs, RawVariable) {
    if !names.contains(name) {
      names.push(name)
    }
  }
  names
}

///|
/// Return all section names, including inverted sections.
pub fn Template::section_names(self : Template) -> Array[String] {
  let refs = self.references()
  let names = names_for_kind(refs, Section)
  for name in names_for_kind(refs, InvertedSection) {
    if !names.contains(name) {
      names.push(name)
    }
  }
  names
}

///|
/// Return partial names in first-use order.
pub fn Template::partial_names(self : Template) -> Array[String] {
  names_for_kind(self.references(), Partial)
}

///|
/// Return whether a compiled template refers to a name in any role.
pub fn Template::contains_name(self : Template, name : String) -> Bool {
  for item in self.references() {
    if item.name == name {
      return true
    }
  }
  false
}

///|
/// Return the total number of occurrences of a reference name.
pub fn Template::reference_count(self : Template, name : String) -> Int {
  let mut count = 0
  for item in self.references() {
    if item.name == name {
      count += item.occurrences
    }
  }
  count
}
