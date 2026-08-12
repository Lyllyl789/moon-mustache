///|
test "render options preserve permissive missing partial behavior" {
  let options = RenderOptions::default()
  let result = render_string_with_options("A{{>missing}}B", {}, {}, options) catch {
    _ => fail("default options should ignore missing partials")
  }
  inspect(result, content="AB")
}

///|
test "strict partial mode reports missing partials" {
  let options = RenderOptions::new(missing_partial_is_error=true) catch {
    _ => fail("valid options rejected")
  }
  let message = render_string_with_options("{{>missing}}", {}, {}, options) catch {
    RenderError(message) => message
    _ => "wrong error kind"
  }
  inspect(message, content="Missing partial: missing")
}

///|
test "partial recursion is bounded" {
  let partials : Map[String, String] = { "loop": "{{>loop}}" }
  let options = RenderOptions::new(max_partial_depth=3) catch {
    _ => fail("valid options rejected")
  }
  let message = render_string_with_options("{{>loop}}", {}, partials, options) catch {
    RenderError(message) => message
    _ => "wrong error kind"
  }
  inspect(message, content="Partial recursion depth exceeded for: loop")
}

///|
test "invalid recursion limit is rejected early" {
  let attempt = fn() -> String raise MustacheError {
    let _ = RenderOptions::new(max_partial_depth=0)
    "no error"
  }
  let message = attempt() catch {
    RenderError(message) => message
    _ => "wrong error kind"
  }
  inspect(message, content="max_partial_depth must be at least 1")
}
