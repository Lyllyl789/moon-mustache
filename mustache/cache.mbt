///|
/// Operational counters for a compiled template cache.
pub struct CacheStats {
  hits : Int
  misses : Int
  inserts : Int
  evictions : Int
  invalidations : Int
}

///|
pub fn CacheStats::hits(self : CacheStats) -> Int {
  self.hits
}

///|
pub fn CacheStats::misses(self : CacheStats) -> Int {
  self.misses
}

///|
pub fn CacheStats::inserts(self : CacheStats) -> Int {
  self.inserts
}

///|
pub fn CacheStats::evictions(self : CacheStats) -> Int {
  self.evictions
}

///|
pub fn CacheStats::invalidations(self : CacheStats) -> Int {
  self.invalidations
}

///|
/// A bounded insertion-ordered cache for compiled templates.
pub struct TemplateCache {
  capacity : Int
  mut entries : Map[String, Template]
  mut order : Array[String]
  mut hits : Int
  mut misses : Int
  mut inserts : Int
  mut evictions : Int
  mut invalidations : Int
}

///|
pub fn TemplateCache::new(capacity : Int) -> TemplateCache raise MustacheError {
  if capacity < 1 {
    raise RenderError("template cache capacity must be positive")
  }
  {
    capacity,
    entries: {},
    order: [],
    hits: 0,
    misses: 0,
    inserts: 0,
    evictions: 0,
    invalidations: 0,
  }
}

///|
fn TemplateCache::cache_remove_order(
  self : TemplateCache,
  key : String,
) -> Unit {
  let next = []
  for old_key in self.order {
    if old_key != key {
      next.push(old_key)
    }
  }
  self.order = next
}

///|
fn TemplateCache::cache_touch(self : TemplateCache, key : String) -> Unit {
  self.cache_remove_order(key)
  self.order.push(key)
}

///|
/// Return a cached template and refresh its recency.
pub fn TemplateCache::get(self : TemplateCache, key : String) -> Template? {
  match self.entries.get(key) {
    None => {
      self.misses += 1
      None
    }
    Some(template) => {
      self.hits += 1
      self.cache_touch(key)
      Some(template)
    }
  }
}

///|
/// Insert or replace a compiled template under a stable application key.
pub fn TemplateCache::put(
  self : TemplateCache,
  key : String,
  template : Template,
) -> Unit {
  let existed = self.entries.get(key) is Some(_)
  self.entries[key] = template
  self.cache_touch(key)
  if !existed {
    self.inserts += 1
  }
  while self.order.length() > self.capacity {
    let oldest = self.order[0]
    let next = []
    let mut index = 1
    while index < self.order.length() {
      next.push(self.order[index])
      index += 1
    }
    self.order = next
    self.entries.remove(oldest)
    self.evictions += 1
  }
}

///|
/// Compile, cache, and return a template in one operation.
pub fn TemplateCache::get_or_compile(
  self : TemplateCache,
  key : String,
  source : String,
) -> Template raise MustacheError {
  match self.get(key) {
    Some(template) => template
    None => {
      let template = compile(source)
      self.put(key, template)
      template
    }
  }
}

///|
/// Render a source template while reusing a compiled cache entry.
pub fn TemplateCache::render(
  self : TemplateCache,
  key : String,
  source : String,
  context : Json,
  partials? : Map[String, String] = Map([]),
  options? : RenderOptions = RenderOptions::default(),
) -> String raise MustacheError {
  let template = self.get_or_compile(key, source)
  template.render_with_options(context, partials, options)
}

///|
/// Remove one cache entry. Returns whether an entry existed.
pub fn TemplateCache::invalidate(self : TemplateCache, key : String) -> Bool {
  let existed = self.entries.get(key) is Some(_)
  if existed {
    self.entries.remove(key)
    self.cache_remove_order(key)
    self.invalidations += 1
  }
  existed
}

///|
/// Clear every entry while preserving cumulative counters.
pub fn TemplateCache::clear(self : TemplateCache) -> Unit {
  self.entries = Map([])
  self.order = []
}

///|
/// Return the current number of cached templates.
pub fn TemplateCache::len(self : TemplateCache) -> Int {
  self.entries.length()
}

///|
/// Return the configured capacity.
pub fn TemplateCache::capacity(self : TemplateCache) -> Int {
  self.capacity
}

///|
/// Snapshot cache counters for logs or metrics export.
pub fn TemplateCache::stats(self : TemplateCache) -> CacheStats {
  {
    hits: self.hits,
    misses: self.misses,
    inserts: self.inserts,
    evictions: self.evictions,
    invalidations: self.invalidations,
  }
}

///|
/// Return cache keys from least to most recently used.
pub fn TemplateCache::keys(self : TemplateCache) -> Array[String] {
  self.order
}
