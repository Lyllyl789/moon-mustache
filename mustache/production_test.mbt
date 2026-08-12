///|
test "render stats report useful operational counters" {
  let template = compile("Hello {{name}} {{missing}}") catch {
    _ => fail("template should compile")
  }
  let (output, stats) = template.render_with_stats(
    { "name": "Moon" },
    {},
    RenderOptions::default(),
  ) catch {
    _ => fail("render should succeed")
  }
  inspect(output, content="Hello Moon ")
  inspect(stats.nodes_visited(), content="4")
  inspect(stats.variables_resolved(), content="1")
  inspect(stats.missing_variables(), content="1")
  inspect(stats.output_chars(), content="11")
}

///|
test "render limits stop oversized output and deep contexts" {
  let output_attempt = fn() -> String raise MustacheError {
    let options = RenderOptions::new(max_output_chars=3)
    render_string_with_options("hello", {}, {}, options)
  }
  let output_message = output_attempt() catch {
    RenderError(message) => message
    _ => "wrong error kind"
  }
  inspect(output_message, content="render output limit exceeded")

  let depth_attempt = fn() -> String raise MustacheError {
    let options = RenderOptions::new(max_context_depth=1)
    render_string_with_options(
      "{{#outer}}{{#inner}}x{{/inner}}{{/outer}}",
      { "outer": { "inner": true } },
      {},
      options,
    )
  }
  let depth_message = depth_attempt() catch {
    RenderError(message) => message
    _ => "wrong error kind"
  }
  inspect(depth_message, content="render context depth limit exceeded")
}

///|
test "static analysis exposes references and complexity" {
  let template = compile("{{#user}}{{name}}{{>card}}{{/user}}") catch {
    _ => fail("template should compile")
  }
  let metrics = template.analyze()
  inspect(metrics.node_count(), content="3")
  inspect(metrics.variable_count(), content="1")
  inspect(metrics.section_count(), content="1")
  inspect(metrics.partial_count(), content="1")
  inspect(template.variable_names().join(","), content="name")
  inspect(template.section_names().join(","), content="user")
  inspect(template.partial_names().join(","), content="card")
  inspect(template.reference_count("user"), content="1")
  let query = TemplateQuery::new(template)
  inspect(query.required_variables().join(","), content="name")
  inspect(query.control_names().join(","), content="user")
  inspect(query.is_dynamic(), content="true")
}

///|
test "validation reports missing partials and accepts a complete graph" {
  let missing = validate_string("A{{>card}}", strict_partials=true) catch {
    _ => fail("validation should compile")
  }
  inspect(missing.has_errors(), content="true")
  inspect(missing.error_count(), content="1")
  inspect(missing.issues()[0].code(), content="MISSING_PARTIAL")

  let partials : Map[String, String] = { "card": "<b>{{name}}</b>" }
  let complete = validate_string("A{{>card}}", partials~, strict_partials=true) catch {
    _ => fail("complete graph should validate")
  }
  inspect(complete.has_errors(), content="false")
  inspect(complete.templates_checked(), content="2")
  inspect(complete.references_checked(), content="2")
}

///|
test "cache reuses compiled templates and evicts old entries" {
  let cache = TemplateCache::new(2) catch {
    _ => fail("cache should accept positive capacity")
  }
  let first = compile("A") catch { _ => fail("compile failed") }
  let second = compile("B") catch { _ => fail("compile failed") }
  let third = compile("C") catch { _ => fail("compile failed") }
  cache.put("a", first)
  cache.put("b", second)
  let _ = cache.get("a")
  cache.put("c", third)
  inspect(cache.len(), content="2")
  inspect(cache.get("b") is None, content="true")
  inspect(cache.stats().hits(), content="1")
  inspect(cache.stats().evictions(), content="1")
  inspect(cache.keys().join(","), content="a,c")
}

///|
test "batch rendering preserves order and reports shape errors" {
  let report = render_batch(["Hi {{name}}", "{{name}}!"], [{ "name": "A" }])
  inspect(report.succeeded(), content="1")
  inspect(report.failed(), content="1")
  inspect(report.successful_outputs().join(","), content="Hi A")
  inspect(
    report.failure_messages().join(","),
    content="missing context for source",
  )
  inspect(report.summary(), content="succeeded=1, failed=1, output_chars=4")
}

///|
test "bundle renders shared partials and reports metrics" {
  let bundle = TemplateBundle::new()
  bundle.add_partial("card", "<b>{{name}}</b>")
  bundle.add_template("home", "Hello {{>card}}") catch {
    _ => fail("template should compile")
  }
  let output = bundle.render("home", { "name": "Moon" }) catch {
    _ => fail("bundle render failed")
  }
  inspect(output, content="Hello <b>Moon</b>")
  inspect(bundle.has_template("home"), content="true")
  inspect(bundle.metrics("home").unwrap().partial_count(), content="1")
  let report = bundle.validate() catch { _ => fail("bundle validation failed") }
  inspect(report.has_errors(), content="false")
}

///|
test "catalog publishes immutable revisions and aliases" {
  let catalog = TemplateCatalog::new()
  let revision = catalog.publish("mail", "welcome", "Welcome {{name}}", tags=[
    "release", "email",
  ]) catch {
    _ => fail("publish should succeed")
  }
  inspect(revision.version(), content="1")
  inspect(catalog.set_alias("stable", "mail/welcome"), content="true")
  let output = catalog.render("stable", { "name": "Ada" }) catch {
    _ => fail("alias render failed")
  }
  inspect(output, content="Welcome Ada")
  inspect(catalog.find_by_tag("release").length(), content="1")
  inspect(catalog.latest_version(), content="1")
}

///|
test "source metadata normalizes line endings and locates diagnostics" {
  let source = TemplateSource::normalized("\u{feff}a\r\nb\rc")
  inspect(source.text(), content="a\nb\nc")
  inspect(source.line_count(), content="3")
  let second_line = match source.line_text(2) {
    None => "missing"
    Some(text) => text
  }
  inspect(second_line, content="b")
  inspect(source.position(2).summary(), content="2:1")
  inspect(source.line_at(4), content="3")
  inspect(source.location_label(4), content="3:1")
  inspect(source.line_is_blank(2), content="false")
  inspect(source.range_text(0, 3), content="a\nb")
  inspect(source.fingerprint(), content="5:-993629944")
}

///|
test "template plan combines rendering diagnostics and dependencies" {
  let plan = TemplatePlan::compile("{{>card}} {{name}}") catch {
    _ => fail("plan should compile")
  }
  inspect(plan.requires_partial("card"), content="true")
  inspect(plan.missing_partials({}).length(), content="1")
  inspect(plan.is_blank(), content="false")
  inspect(plan.metrics().partial_count(), content="1")
  inspect(
    plan.dependency_summary(),
    content="variables=name; controls=; partials=card",
  )
  let partials : Map[String, String] = { "card": "<b>{{name}}</b>" }
  let output = plan.render_checked({ "name": "Moon" }, partials~) catch {
    _ => fail("complete plan should render")
  }
  inspect(output, content="<b>Moon</b> Moon")
  inspect(plan.dependencies(partials)[0].available(), content="true")
}

///|
test "registry supports revisions, rollout, tags, and checked rendering" {
  let registry = TemplateRegistry::new()
  let first = registry.register("welcome", "Welcome {{name}}", tags=["email"]) catch {
    _ => fail("registration should succeed")
  }
  inspect(first.revision(), content="1")
  let second = registry.register("welcome", "Hi {{name}}", tags=["email", "v2"]) catch {
    _ => fail("replacement should succeed")
  }
  inspect(second.revision(), content="2")
  inspect(registry.len(), content="1")
  inspect(registry.find_by_tag("v2").join(","), content="welcome")
  let output = registry.render("welcome", { "name": "Ada" }) catch {
    _ => fail("registry render failed")
  }
  inspect(output, content="Hi Ada")
  inspect(registry.set_enabled("welcome", false), content="true")
  let disabled = fn() -> String raise MustacheError {
    registry.render("welcome", {})
  }
  let message = disabled() catch {
    RenderError(text) => text
    _ => "wrong error kind"
  }
  inspect(message, content="registry template is disabled: welcome")
  inspect(registry.set_enabled("welcome", true), content="true")
  inspect(
    registry.summary(),
    content="templates=1, enabled=1, latest_revision=2",
  )
}
