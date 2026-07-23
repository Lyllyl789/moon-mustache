fn main {
  let template =
    #|<!DOCTYPE html>
    #|<html>
    #|<head>
    #|  <title>{{title}}</title>
    #|</head>
    #|<body>
    #|  <h1>{{title}}</h1>
    #|  {{#users}}
    #|  <div class="user-card">
    #|    <h2>{{name}}</h2>
    #|    <p>Email: <a href="mailto:{{email}}">{{email}}</a></p>
    #|    <ul>
    #|      {{#roles}}
    #|      <li>{{.}}</li>
    #|      {{/roles}}
    #|      {{^roles}}
    #|      <li>No roles assigned</li>
    #|      {{/roles}}
    #|    </ul>
    #|  </div>
    #|  {{/users}}
    #|  {{^users}}
    #|  <p>No users found in the system.</p>
    #|  {{/users}}
    #|</body>
    #|</html>

  let data_str = 
    #|{
    #|  "title": "System User Report",
    #|  "users": [
    #|    {
    #|      "name": "Alice Smith",
    #|      "email": "alice@example.com",
    #|      "roles": ["Admin", "Manager"]
    #|    },
    #|    {
    #|      "name": "Bob Jones",
    #|      "email": "bob@example.com",
    #|      "roles": ["User"]
    #|    },
    #|    { "name": "Charlie Brown", "email": "charlie@example.com", "roles": [] }
    #|  ]
    #|}
  
  let data : Json = @json.parse(data_str) catch { _ => return }

  let result = @mustache.render_string(template, data) catch {
    _ => {
      return
    }
  }

  println(result)
}
