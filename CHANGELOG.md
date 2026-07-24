# Changelog

All notable changes to this project are recorded here. The **project version is the git tag** —
run `git describe --tags` to see which version a clone is at. Format loosely follows
[Keep a Changelog](https://keepachangelog.com); this repo is the manuals→Dify pipeline **and** the
jsDelivr image host (`d5devgodai-blip/GD_IMG_Test`).

**How to version a push:** add your change under `[Unreleased]`; when you push a release, rename it to
the new version, date it, and `git tag -a vX.Y.Z` on that commit (new manual → minor bump; image/text
fix → patch bump). `git describe --tags` then tells any clone its version.

⚠️ **Tagging is MANDATORY on any image push, not optional.** jsDelivr resolves the tagless CDN URLs
(the scheme every map uses) to the **latest git tag**, not `main` HEAD. So images added after the
newest tag 404, and images deleted after it keep serving from the tag — until a new tag is pushed at
HEAD. Always `git tag` at HEAD right after pushing images, then purge + md5-verify the CDN.

## [Unreleased]

## [1.3.0] — 2026-07-24

Patch to 補強土16_本体_v1: recovers content lost at build time.

### Fixed
- **補強土16_本体_v1** — the build didn't recurse into tables **nested inside a table cell**
  (the green □■□■ callout boxes are an outer table wrapping an inner screenshot+prose table), so it
  emitted a `(nested table)` placeholder and dropped every embedded screenshot. `cell_md` now recurses;
  **9 screenshots recovered** (image32/33/110/111/112/117/192/193/194 · commit at tag) and one real
  data table (対応形式/拡張子) that had been dropped. Also folded the pitfall-30 layout-table flatten
  (image-left figure+caption / side-by-side / 設定条件 boxes) into `table_to_markdown` so the rebuild
  keeps the 78 layout boxes flattened. Rebuilt clean (0 FAIL / 24), CDN md5-verified 9/9.

## [1.2.0] — 2026-07-24

Third release. Adds the 補強土 Ver16 main manual.

### Manuals converted (chunks · image commit)
- **補強土16_本体_v1** (補強土 Ver16 本体・主マニュアル, 第Ⅰ-Ⅲ編) — 360 chunks · `c6da4c6`.
  First shipped manual with **pitfall-28 figure flatten**: 7 annotated screenshots re-rendered from
  the PDF (raster-hash locate) so the rectangle/circle/arrow callouts are baked into the image.

## [1.1.0] — 2026-07-24

Second release. Adds one manual, removes one, and re-points the tagless CDN at current content (the
`v1.0.0`-only tag had frozen every tagless URL at the 10-manual baseline).

### Manuals converted (chunks · image commit)
- **補強土16_概算工事費編** (補強土 Ver16 概算工事費編 / cost-estimation edition) — 39 chunks · `1872a3c`

### Removed
- **補強土16** (Ver16 バージョンアップ用) — dropped from the KB set; its 18 images deleted from the
  host repo (`cc10860`). The `[1.0.0]` entry below stays as shipped history (that tag did include it);
  this `v1.1.0` tag is what actually stops the CDN serving them.

### Also on the CDN
- **PoiCL_V123** images published & renamed to `PoiCL_V123/PoiCL_V123_Image/` (`974ef3e`,
  pitfall-29 naming). Markdown/map deliverable (Supabase) still pending.

### Live manual count: 10 (9 from v1.0.0 minus 補強土16, plus 補強土16_概算工事費編).

## [1.0.0] — 2026-07-23

First tagged release. Ten Japanese software manuals (五大開発 / Godai) converted to Dify
knowledge-base Markdown + JSON maps, with all images published to the jsDelivr CDN. Every manual is
at its own **version 1** (see `CLAUDE.md` for the per-software version model — identity binds by
Supabase path, not by a field in the map).

### Manuals converted (chunks · image commit)
- **PowerSSA** — 226 chunks · `e1fecca`, rebuilt `6779b64` (equations → LaTeX)
- **補強土15** — 298 chunks · `b938aa2`
- **Anchor** (ANCHOR Ver18) — 65 chunks · `6ae33c6`
- **GGRAPH** (Ver8) — 248 chunks · `01d68a0`
- **Formap** (フォーマップ Ver3) — 104 chunks · `05b8438`
- **CRAFT5** (Ver8) — 199 (main) / 88 (nori) chunks · `a2e249a`
- **PoiCL** — 29 chunks · `17c054c`
- **最適擁壁** (Ver6) — 104 chunks · `17c054c`
- **MovieCaptureTool** (第2版) — 9 chunks · `5831339`
- **補強土16** (Ver16 バージョンアップ用) — 11 chunks · `ec05518`

### Infrastructure
- jsDelivr-over-GitHub image hosting (repo path == CDN URL segment).
- `manual-to-dify` skill + three-script pipeline (`build` → `postprocess` → `verify`) generalized
  for new manuals; shareable toolkit at `d:\manual-to-dify-toolkit`.

[1.3.0]: https://github.com/d5devgodai-blip/GD_IMG_Test/releases/tag/v1.3.0
[1.2.0]: https://github.com/d5devgodai-blip/GD_IMG_Test/releases/tag/v1.2.0
[1.1.0]: https://github.com/d5devgodai-blip/GD_IMG_Test/releases/tag/v1.1.0
[1.0.0]: https://github.com/d5devgodai-blip/GD_IMG_Test/releases/tag/v1.0.0
