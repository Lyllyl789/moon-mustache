# moon-mustache

一个使用纯 MoonBit 编写的、完全符合 Mustache 规范的逻辑无状态模板引擎。

`moon-mustache` 专为 WebAssembly、JavaScript 和 Native 后端设计，支持高效的动态 HTML 渲染、配置文件模板生成和各种文本生成任务，且具有零外部依赖（仅依赖 `moonbitlang/core`）。

## 项目信息

- **项目名称**：`moon-mustache` (Mustache 模板引擎)
- **项目标识 (Module)**：`Lyllyl789/mustache`
- **项目简介**：基于 MoonBit 强类型与高性能特征实现的 Mustache 规范模板引擎。支持变量插值、嵌套列表/条件区块、取反区块、局部模板（支持缩进保留）、自定义分界符等完整特性，为 MoonBit 生态补齐高复用性的动态渲染工具。

## 特性列表

- **标准插值**：`{{var}}`（默认进行 HTML 实体转义）
- **非转义插值**：`{{{var}}}` 或 `{{&var}}`（输出原始 HTML/文本）
- **条件区块**：`{{#var}}...{{/var}}`（值非空/为真时渲染，若为数组则进行列表循环迭代）
- **取反区块**：`{{^var}}...{{/var}}`（当值为假、null 或空列表时渲染）
- **模板注释**：`{{! comment }}`（渲染时自动忽略）
- **局部模板 (Partials)**：`{{> partial}}`（支持嵌套渲染，并且符合规范地保留并应用调用处的行首缩进）
- **动态修改分界符**：`{{=<% %>=}}`（支持在模板解析中动态更改标签起止标识符）
- **独立标签行首尾空白消除**：对注释、区块头尾、局部模板及分界符变更等独立标签行，自动消除前后空白及尾部换行符。
- **点路径访问**：支持 `{{user.profile.name}}` 点符号对象层级寻值。
- **隐式迭代器**：列表渲染时支持使用 `{{.}}` 代表当前迭代项本身。

## 快速开始

### 1. 添加依赖

在您的 MoonBit 项目 `moon.pkg.json` 中引入依赖：

```json
{
  "import": [
    "Lyllyl789/mustache/mustache"
  ]
}
```

### 2. 基础变量渲染

```moonbit
fn main {
  let template = "Hello {{name}}! Welcome to {{location}}."
  let context : Json = {
    "name": "Lu Yilu",
    "location": "Beijing, China"
  }

  try {
    let output = @mustache.render_string(template, context)
    println(output) // 输出: Hello Lu Yilu! Welcome to Beijing, China.
  } catch {
    ParseError(msg) => println("Parse error: \{msg}")
    RenderError(msg) => println("Render error: \{msg}")
  }
}
```

### 3. 数组区块渲染 (循环)

```moonbit
fn main {
  let template = 
    $|{{#skills}}
    $|- {{.}}
    $|{{/skills}}

  let context : Json = {
    "skills": ["MoonBit", "WebAssembly", "Mustache"]
  }

  try {
    let output = @mustache.render_string(template, context)
    println(output)
    /*
    输出:
    - MoonBit
    - WebAssembly
    - Mustache
    */
  } catch {
    _ => println("Error rendering")
  }
}
```

### 4. 局部模板 (Partials) 与缩进保留

```moonbit
fn main {
  let template = 
    $|<h2>Names</h2>
    $|{{#people}}
    $|  {{> user}}
    $|{{/people}}

  let partials = Map([
    ("user", "<strong>{{name}}</strong> ({{email}})\n")
  ])

  let context : Json = {
    "people": [
      { "name": "Alice", "email": "alice@example.com" },
      { "name": "Bob", "email": "bob@example.com" }
    ]
  }

  try {
    let output = @mustache.render_string(template, context, partials = partials)
    println(output)
    /*
    输出 (注意 <strong> 前面的两个空格被正确保留并应用了):
    <h2>Names</h2>
      <strong>Alice</strong> (alice@example.com)
      <strong>Bob</strong> (bob@example.com)
    */
  } catch {
    _ => ()
  }
}
```

## 测试与校验

在项目根目录下执行以下命令运行测试：

```bash
# 检查项目语法和类型
moon check

# 运行所有单元和集成测试
moon test

# 运行示例程序
moon run examples/simple
moon run examples/partials
```

## 许可证

本项目基于 [MIT](LICENSE) 开源许可证发布。
