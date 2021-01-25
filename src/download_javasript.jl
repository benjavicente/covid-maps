using FilePaths

JS_DIR = "js"

begin
    download("https://cdn.jsdelivr.net/npm/vega@5", joinpath(JS_DIR, "vega.min.js"))
    download("https://cdn.jsdelivr.net/npm/vega-lite@4", joinpath(JS_DIR, "vega-lite.min.js"))
    download("https://cdn.jsdelivr.net/npm/vega-embed@6", joinpath(JS_DIR, "vega-embed.min.js"))
end
