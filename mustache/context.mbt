///|
pub(all) enum Context {
  Empty
  Frame(Json, Context)
}

///|
pub fn Context::new(data : Json) -> Context {
  Frame(data, Empty)
}

///|
pub fn Context::push(self : Context, val : Json) -> Context {
  Frame(val, self)
}

///|
/// Return the number of frames currently visible to a render.
pub fn Context::depth(self : Context) -> Int {
  match self {
    Empty => 0
    Frame(_, parent) => 1 + parent.depth()
  }
}

///|
fn has_dot(s : String) -> Bool {
  let len = s.length()
  let mut i = 0
  let dot_code = (46).to_uint16()
  while i < len {
    if s[i] == dot_code {
      return true
    }
    i = i + 1
  }
  false
}

///|
fn split_dots(s : String) -> Array[String] {
  let res = []
  let len = s.length()
  let mut start = 0
  let mut i = 0
  let dot_code = (46).to_uint16()
  while i < len {
    if s[i] == dot_code {
      res.push(s[start:i].to_owned())
      start = i + 1
    }
    i = i + 1
  }
  if start <= len {
    res.push(s[start:len].to_owned())
  }
  res
}

///|
fn resolve_key(json : Json, key : String) -> Json? {
  match json {
    Object(map) => map.get(key)
    _ => None
  }
}

///|
pub fn Context::lookup(self : Context, key : String) -> Json {
  if key == "." {
    match self {
      Frame(val, _) => return val
      Empty => return null
    }
  }

  if has_dot(key) {
    let parts = split_dots(key)
    if parts.length() == 0 {
      return null
    }
    let first = parts[0]
    let current_opt = self.search_stack(first)
    match current_opt {
      None => return null
      Some(current_val) => {
        let mut current = current_val
        let mut i = 1
        let limit = parts.length()
        while i < limit {
          match resolve_key(current, parts[i]) {
            None => return null
            Some(next_val) => current = next_val
          }
          i = i + 1
        }
        return current
      }
    }
  }

  match self.search_stack(key) {
    None => null
    Some(val) => val
  }
}

///|
fn Context::search_stack(self : Context, key : String) -> Json? {
  let mut curr = self
  while true {
    match curr {
      Empty => break
      Frame(val, parent) =>
        match resolve_key(val, key) {
          Some(found) => return Some(found)
          None => curr = parent
        }
    }
  }
  None
}

///|
pub fn is_truthy(val : Json) -> Bool {
  match val {
    Null => false
    False => false
    Array(arr) => arr.length() > 0
    _ => true
  }
}
