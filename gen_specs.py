import urllib.request
import json
import os

SPECS = [
    "interpolation.json",
    "sections.json",
    "inverted.json",
    "comments.json",
    "partials.json",
    "delimiters.json"
]

BASE_URL = "https://raw.githubusercontent.com/mustache/spec/master/specs/"

out_file = "mustache/spec_test.mbt"

SKIP_TESTS = set()

def escape_moonbit(s):
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')

def generate_moonbit_tests():
    with open(out_file, "w", encoding="utf-8") as out:
        for spec_name in SPECS:
            url = BASE_URL + spec_name
            print(f"Fetching {url}...")
            response = urllib.request.urlopen(url)
            spec = json.loads(response.read().decode('utf-8'))
            
            for test in spec['tests']:
                test_title = f"{spec_name} - {test['name']}"
                if test_title in SKIP_TESTS:
                    continue
                    
                desc = test['desc'].strip().replace('"', '\\"').replace('\n', ' ')
                
                template_str = '"' + escape_moonbit(test['template']) + '"'
                expected_str = '"' + escape_moonbit(test['expected']) + '"'
                data_json_str = '"' + escape_moonbit(json.dumps(test['data'])) + '"'
                
                partials = test.get('partials', {})
                
                out.write("///|\n")
                out.write(f'test "{test_title}" {{\n')
                out.write(f'  // {desc}\n')
                out.write(f'  let template = {template_str}\n')
                out.write(f'  let data_str = {data_json_str}\n')
                out.write(f'  let expected = {expected_str}\n')
                
                out.write('  let data : Json = @json.parse(data_str) catch {\n')
                out.write('    _ => fail("Json parse error")\n')
                out.write('  }\n')
                
                if partials:
                    out.write(f'  let partials_map : Map[String, String] = Map([])\n')
                    for k, v in partials.items():
                        k_str = '"' + escape_moonbit(k) + '"'
                        v_str = '"' + escape_moonbit(v) + '"'
                        out.write(f'  partials_map[{k_str}] = {v_str}\n')
                    out.write('  let result = render_string(template, data, partials=partials_map) catch {\n')
                    out.write('    _ => fail("Render error")\n')
                    out.write('  }\n')
                else:
                    out.write(f'  let result = render_string(template, data) catch {{ _ => fail("Render error") }}\n')
                
                out.write(f'  if result != expected {{\n')
                out.write(f'    fail("Expected: " + expected + ", got: " + result)\n')
                out.write(f'  }}\n')
                out.write("}\n\n")

    # Keep the generated fixture deterministic with exactly one final newline.
    with open(out_file, "r", encoding="utf-8") as generated:
        content = generated.read().rstrip("\n") + "\n"
    with open(out_file, "w", encoding="utf-8") as generated:
        generated.write(content)

if __name__ == "__main__":
    generate_moonbit_tests()
    print("Done generating tests.")
