# 📄 `service_utils.chrome_pdf`

Simple Lua utility to **generate PDFs from HTML** using **Chrome DevTools Protocol** directly over WebSocket.

Part of the [`service_utils`](https://github.com/Tekenlight/service_utils) project under the [`evlua`](https://github.com/Tekenlight) ecosystem.

---

## 🚀 Features

* Launches Chrome headless automatically
* Connects using Chrome DevTools Protocol (CDP) via WebSocket
* Creates a new browser tab
* Navigates to a local HTML file
* Generates a PDF and saves it to disk
* Lightweight: **no external Puppeteer or Node.js needed**
* Pure Lua + Chrome

---

## 📦 Requirements

* **Google Chrome** or **Chromium** installed (version 59+)
* **Lua 5.1+** (tested with LuaJIT and Lua 5.3)
* Lua dependencies:

  * evlua framework
  * service\_utils

---

## 🛠 Installation

Clone the repository:

```bash
git clone https://github.com/Tekenlight/service_utils.git
```

Ensure `service_utils` is in your Lua module path.

---

## 🧩 Usage Example

```lua
local chrome_pdf = require("service_utils.chrome_pdf")

-- Configuration
local html_file = "/tmp/example.html"

-- Generate PDF
chrome_pdf.generate_pdf_from_html(html_file, params);
params is an optional lua table with possible properties as follows
{
    display_header_footer = true,
    header_template = [[
            <div style="font-size:10px; width:100%; text-align:center;">
                <span class="title"></span>
            </div>

        ]],
    footer_template = [[
            <div style="font-size:10px; width:100%; text-align:right; padding-right:20px;">
                Page <span class="pageNumber"></span> of <span class="totalPages"></span>
            </div>
        ]],
    margin_top = 0.5,
    margin_bottom = 0.5,
    margin_left = 0.5,
    margin_right = 0.5,
    print_background = true,
    paper_width = 8.27,
    paper_height = 11.69
}

```

✅ This will:

* Launch Chrome headless,
* Open the HTML file,
* Wait for it to load,
* Print it to PDF,
* Save it at the given output path.

---

## ⚙️ API

### `chrome_pdf.generate_pdf_from_html(html_file, output_pdf, chrome_path)`

| Argument      | Description                                     |
| :------------ | :---------------------------------------------- |
| `html_file`   | Path to the local HTML file you want to convert |
| `output_pdf`  | Path where the resulting PDF should be saved    |
| `chrome_path` | Path to Chrome or Chromium executable           |

Returns: `true` on success, or raises an error if something fails.

---

## 🛡️ License

MIT License. See [LICENSE](LICENSE).

---

## ✨ Credits

Developed by [Tekenlight](https://github.com/Tekenlight)
Built as part of [`evlua`](https://github.com/Tekenlight/evlua) and [`service_utils`](https://github.com/Tekenlight/service_utils).

---

# 📋 Notes

* This library talks **directly** to Chrome over the **DevTools Protocol**.
* **No Puppeteer, No Node.js** dependency.
* Works well inside server-side Lua frameworks for document generation, microservices, and backend tools.

---

# 🚀 Future Enhancements (Planned)

* Allow passing PDF options (margins, orientation, etc.)
* Allow specifying URL instead of file
* Automatic Chrome path detection
* Timeout handling
* Batch generation support

---

# 📜 Full Example Project Structure

```plaintext
service_utils/
  chrome_pdf.lua
  README.md
  examples/
    generate_pdf_example.lua
```

Example script:

```evlua
-- examples/generate_pdf_example.lua
local chrome_pdf = require("service_utils.chrome_pdf")
chrome_pdf.generate_pdf_from_html("/tmp/test.html", "/tmp/test.pdf", "/usr/bin/google-chrome")
```

---


