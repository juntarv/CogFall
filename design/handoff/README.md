# CogFall — Design Handoff (self-authored fallback)

The `claude-design` MCP was present in this session but gated behind an
un-granted `needs_consent` approval, so the mockups were produced with the
tokens-first fallback path instead: self-contained 390×844 HTML in
`design/html/` rendered to `design/*.png`.

- `project/styles/tokens.css` — copy of the design tokens (also mirrored to
  the project root as `design-tokens.css`).
- `project/uploads/` — intentionally empty. All imagery is **inline SVG**
  authored directly in each screen's HTML (no external raster files), per the
  fallback rule "self-contained HTML … no external images". The imagery
  inventory (motifs + intended per-screen role) is documented in `DESIGN.md`.
