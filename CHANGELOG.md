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

**No image push** — nothing in this section changes a CDN url, so no tag bump is due yet. The map and
markdown edits below are gitignored here; their history lives in `d5devgodai-blip/Dify_file_manager`.

### Added
- **`preflight_guard.py` (repo root) — a new pipeline step 0.** The invariant becomes
  `preflight_guard.py` → `build_*.py` → `postprocess_*.py` → `verify_*.py`. The guard lists every
  paragraph the build's skip rules would discard and demands structural proof each is discardable,
  exiting 1 with the offending paragraphs named. It runs *before* the md is generated, because
  afterwards there is nothing left to compare against. Also reports fully-hidden paragraphs carrying
  real text, and the text-box paragraph count.
- **Pitfall 35 — a paragraph STYLE is never proof of what a paragraph IS.** QA reported that
  CRAFT5_8_法面_v1's 用語 glossary had lost every term label. The author had styled each term
  (`のり面求積図`, `のり枠、フレーム`, `ブロック`, …) with Word's built-in `toc 1` style, and
  `build_*.py` skipped anything styled `toc` — so the terms went and the definitions stayed. Across
  the batch the rule deleted **76 content paragraphs**: CRAFT5_8_法面_v1 24, CRAFT5_8_本体_v1 47,
  PowerSSA_8_本体_v1 3, MovieCaptureTool_1_本体_v1 1, PoiCL_1_本体_v2 1. A genuine generated-TOC line
  always carries proof Word wrote it (a `_Toc…` hyperlink anchor, a `PAGEREF`/`TOC` field, or a
  dot-leader + page-number tail), so builds must call `preflight_guard.is_real_toc_entry(p)` instead
  of testing the style name. Supersedes pitfall 28's narrower "gate the 目次-skip on
  no-image-in-the-paragraph" — the image test was one symptom, not the rule.
- **Pitfall 34 added to the SKILL.md index** (page numbers/image placement must be re-derived from
  the PDF); it existed in `pitfalls.md` but had never been listed.

### Changed
- **`CLAUDE.md`**: the pipeline invariant now names the preflight and carries both new rules — the
  style-is-not-evidence gate, and the requirement that content coverage be positional.

### Known issues
- **The 76 deleted paragraphs are still missing from the published `.md` files.** The guard prevents
  recurrence; it does not repair what already shipped. Being corrected by hand.
- **The content-coverage check is not positional, which is why this shipped 13 times.** It asks "does
  this text appear ANYWHERE in the md", and a term like `のり面求積図` occurs all through the body —
  so 65 of the 76 deletions passed it. Pitfall 35 specifies the replacement (anchor on paragraphs
  occurring exactly once, longest-increasing-subsequence spine, require every remaining paragraph
  between its neighbouring anchors; 646 anchors on CRAFT5_8_法面_v1, and it finds them). **The 14
  verify scripts are unchanged** — documented, not implemented.
- **The DOCX sources do not cover the whole printed manual.** Page-level coverage of PDF text against
  the delivered md runs 52–88% (Anchor 52%, CRAFT5本体 88%). Of 222 pages below 60%, **209 were never
  in the DOCX at all** and only 1 was a genuine pipeline loss (補強土_16_概算工事費編_v1 PDF p.72, cell
  「特殊作業員　普通作業員」). Systematically absent from the Word sources: front matter (はじめに /
  使用許諾契約と著作権保護 / 表記規則), the サポート情報・お問い合わせ・奥付 tail in 8 of 13 manuals, and
  **Anchor's entire appendix** — its DOCX stops at PDF p.127, so pp.128–214 (報告書 output samples,
  ~40% of the manual) were never available. Needs the complete Word sources, not pipeline work.
- **Pitfall numbering has diverged from the toolkit repo.** This repo lacks the "ask whether it is a
  software manual" pitfall (it is a CLAUDE.md hard rule here instead), so from 34 onward the numbers
  are offset by one: this repo's 34/35 are `godai-support-ai`'s 35/36. Cross-references inside each
  repo are self-consistent; renumbering would break them, so it was left alone.

### Fixed
- **77 wrong `pdf_page` values corrected across 6 manuals**, verified against the PDFs themselves:
  CRAFT5_8_本体_v1 38 (a contiguous run of sections `1.17`–`1.37` had drifted +2 to +20 pages),
  補強土_15_本体_v1 17, CRAFT5_8_法面_v1 11, PowerSSA_8_本体_v1 8, Anchor_18_本体_v1 2,
  補強土_16_概算工事費編_v1 1. Plus 69 `pdf_page_end` values and 1,284 image entries. All six had been
  **published** while every id-consistency, count and plausibility check stayed green — none of them
  opens the PDF. Re-verification: 0 mismatches across all 13 paged manuals.
- **PowerSSA_8_本体_v1 and 補強土_15_本体_v1 image pages** — ~85% of their image entries (512/612 and
  590/666) recorded a page EARLIER than the section the image belongs to. Both now inherit their host
  chunk's range, matching the other 11 manuals. PowerSSA: image errors 63 → 2, images confirmed on
  their recorded page 76 → 414.
- **`_toc_CRAFT5_8_本体_v1.json` `secnum`** synced to the map's printed section numbers (189 of 199),
  so the toc and the map no longer disagree about what section a chunk is. Only `secnum` changed.

### Added
- **`verify_pages_images.py`** — verification grounded in the PDF rather than in self-consistency:
  each chunk's heading is printed on the page `pdf_page` names; each image's raster is on the page
  `image_map` claims; images sharing a page appear in the md in the PDF's reading order. `--html`
  writes a visual triage report pairing each finding with the rendered page, image outlined in red.
- **`.claude/skills/github-repos/`** — routing and push rules for the three repos this project pushes
  to, including the "one working tree, three clones — never three remotes" rule.

### Known issues
- 29 images sit >2 pages outside their recorded range; 54 are ordered differently in the md than the
  PDF lays them out. Unverified leads, not confirmed defects.
- `補強土_16_概算工事費編_v1` verify: 3 FAIL, pre-existing (md 49 `$$$` segments vs 39 chunks).
- 🚨 The 50 MB jsDelivr cap still blocks any image push — see the note at the top of this file.

## [1.8.0] — 2026-07-30

**Every `web/` batch image file is now named after the `image_map` key that points at it** —
`img_1_1.png`, not Word's opaque `c841a41da01dc4b9ace1f85faf1a9ed5a01cd717.png` (user request).
**93 files** (up from v1.7.0's 89), 18/18 green (23 OK / 0 FAIL each), 29 chunks unchanged.
**Scope is `web/` only** — the other 12 manuals keep their frozen `imageN.ext` names and published urls.

### Changed
- **Image extraction is LAZY.** The build writes each file from `img_id()`, at the moment the id is
  minted, instead of dumping all of `word/media/` up front and pruning afterwards — the file name is
  not knowable until the id exists. A media nothing references is now never written at all, which
  demotes the postprocess prune (step 12) to a guard that should always report `[]`.
- **93 files, not 89**: an id is a POSITION, a file is CONTENT, so a media reused at N positions is
  written N times, once per id (4 cases: `20180531-driver` 5 ids/4 media, `SentinelDriver761` 10/9,
  `セットアップガイドWeb認証版` 16/14). Pointing the later ids at the first id's file would save a few
  KB and make the name lie about which chunk the image belongs to — the opposite of the point.
- Git recorded 89 renames (R100) + 4 additions. The manifest gained a **`source_media`** field, since
  the rename makes the docx original otherwise unguessable.

### Added
- **Verify check 6c** pins the invariant from both directions: every url's basename equals its id,
  and no file sits in the dir that no id claims (the orphan case the prune step used to catch).

### Note
- Every v1.7.0 url is **dead** as of this tag. Nothing downstream had consumed them — this batch is
  still pending Dify ingest — but the tag bump is what makes both the removal and the new names take
  effect on jsDelivr. All 93 purged and md5-verified.

## [1.7.0] — 2026-07-30

The `web/` batch is **image-bearing again** (user instruction), reversing v1.6.0's text-only
decision. **89 image files pushed, 93 image ids across 15 of the 18 manuals**; 18/18 verify green
(22 OK / 0 FAIL each), 29 chunks unchanged. **Scope is `web/` only.**

### Added
- **89 images re-pushed** to `web/*/*_Image/` (15 dirs), staged with an explicit glob pathspec —
  verified 89 additions, 0 deletions, nothing outside an `_Image/` dir. **Tagged at HEAD**, without
  which jsDelivr would keep resolving the maps' tagless urls to v1.6.0 and serve 404 for every one.
- `![img_x_y]` refs are back in the md at their original positions, `image_map.json` is populated,
  and each chunk in `<ID>_map.json` carries its nested `images` block again.

### Changed
- `EMIT_IMAGES = True` — the same single gate flipped back, so body refs, table carve-outs, the
  manifest and the maps returned together. The two states are exact opposites; neither half-applies.
- **Verify check 17b now works in both directions.** It used to assert only the suppressed state and
  merely *warn* if the flag was on; it now checks the enabled state too (md refs == `image_map` ==
  the map's `images` blocks, and an image dir actually on disk), so a half-applied flip fails either
  way. The push-needs-a-tag reminder is kept as a WARN.
- pitfall 28 overlay detection is live again: the 2 unflattenable annotated screenshots in
  `セットアップガイドWeb認証版` are reported once more (no PDF exists to flatten them from).

### Fixed
- `run_web.py` died on console encoding on this Japanese-Windows box: a child writing a Japanese
  section name to a pipe emits cp932 that `encoding="utf-8"` could not decode, and the driver writing
  an em dash to a redirected stdout died on cp932. UTF-8 is now pinned on the children (`PYTHONIOENCODING`
  / `PYTHONUTF8` in the child env) and on the driver's own streams. A reporting-layer fault was
  aborting an otherwise green run.

### Note
- **4 docx were re-saved by the author on 2026-07-30** (`スタンドアロン型USB…_A4_DL版`,
  `スタンドアロン型USBドライバレスライセンス更新_A4`, `スタンドアロン型USBライセンス更新_A4_DL版`,
  `ネットワーク型USBのご使用について_A4`) and now carry fewer, all-PNG media — hence 89 files rather
  than v1.5.0's 96. This is a source change, not a pipeline regression: every image anchor in every
  docx resolves to a rel and reaches the md (93 anchors = 93 refs, 0 unresolved).

## [1.6.0] — 2026-07-29

The `web/` batch goes **TEXT ONLY** (user instruction, same day v1.5.0 published it). All 96 images
added in v1.5.0 are removed again — from the repo, the maps and the markdown. 29 chunks unchanged.
**Scope is `web/` only**: the other 12 manuals' 3,981 tracked image files are untouched.

### Removed
- **All 96 images deleted from the repo** (15 dirs under `web/*/*_Image/`), staged with an explicit
  pathspec — verified 96 deletions, 0 other paths. **Tagged at HEAD**, because jsDelivr keeps serving
  a *deleted* file from the previous tag until a newer one exists (the v1.0.0 incident): without
  v1.6.0 every removed image would still be served by v1.5.0.
- `![img_x_y]` refs gone from all 18 `.md`; `image_map.json` is `{}`; the `images` block is **omitted**
  from every chunk in `<ID>_map.json` (an absent fact is an absent key — consumers must use
  `.get("images", {})`, same convention as the top-level `source_url`).

### Changed
- Suppression is **one gate in the build**, `EMIT_IMAGES = False`, enforced at `para_images()` — which
  starves the body refs, the table carve-outs, the manifest and the maps simultaneously. Chosen over a
  post-hoc strip so a rebuild cannot quietly bring the images back. `extract_images()` also deletes any
  `<ID>_Image/` dir a previous run left, so nothing exists locally for a stray `git add` to re-stage.
- Image-bearing paragraphs still count as **positional placeholders** in table cells, so the
  side-by-side alignment the price-sheet carve-out depends on is unaffected by the removal.
- **New verify check 17b** pins the decision from both ends: no `![img_` in the md, no `image_map`
  entries, no `images` block in the map, and **no image dir on disk**. It warns loudly if
  `EMIT_IMAGES` is ever flipped back, since that needs a fresh push *and* a new tag.
- pitfall 28 overlay detection is skipped while images are suppressed — there is no figure to flatten,
  so the two unflattenable screenshots in `セットアップガイドWeb認証版` are no longer reported.

## [1.5.0] — 2026-07-29

Manuals 13–30: the **`web/` batch — 18 SEPARATE manuals** captured from the 五大開発 support site
(`soft.godai.co.jp/soft/support/…`) and the A4 setup / license-update leaflets it links to (HASP・
Sentinel protect keys, ライセンス認証, セットアップガイド). All 全製品共通, none product-specific.
**18/18 green — 378 OK / 24 WARN / 0 FAIL, 29 chunks, 96 images.**

### Added
- **18 manuals, each its own** folder / deliverables / CDN path / Dify product key (user's choice over
  one combined manual). Images pushed (96 files) and md5-verified.
- **ONE parametrized script trio for all 18** (the CRAFT5 precedent), driven by `run_web.py <id>` /
  `--all` / `--list`, which exists so the build→postprocess→verify invariant can't be broken by habit.
- **No-PDF carve-out applied 18×** (pitfall 32, user-confirmed): `pdf_page`/`pdf_page_end` null, no
  `_toc_*.json`, no figure flatten; every build asserts zero `.pdf`.
- **`source_url` from the trailing `出典: https://…` line** — 9 files have one, and it is emitted
  **ONCE as a top-level key** of `chunk_map.json` / `<ID>_map.json`, never repeated per chunk and
  never per image (user 2026-07-29). Omitted entirely for the 9 files with no 出典 line, so an absent
  fact is an absent key rather than N nulls. Any *other* link stays inline in the body as-is,
  including rels-only targets (appended as `（url）`).
  ⚠️ The map therefore has one non-`Page_IDn` key whose value is a string — lookups by page id are
  unaffected, but a consumer that *iterates* map keys must skip it.
- **Author `$$$` are the delimiters, but 9 of 18 files have none** → one chunk for the whole file,
  delimiter emitted by the build. A `$$$` may also be a table of its own or ride in the last cell of
  a content table; a tiny trailing footer after the last `$$$` is folded into the final chunk.
- Images live at `web/<ID>/<ID>_Image/` — one level deeper than usual; verify check 6b asserts the CDN
  segment equals the repo-relative image dir. 8 of the 18 ids are non-ASCII (percent-encoded).
- 6 decorated docx names normalized (decoration → `_`, every version part kept), e.g.
  `セットアップガイド(A4) 【ドライバレス版】` → `セットアップガイド_A4_ドライバレス版`, so ids stay derived.

### Table handling
- **3 real tables KEPT** as pipe tables (`HaspMonitor` No./製品名 32 rows, `HaspProtect` エラーコード/
  状態, `sentinel_protect_key_support` 項目/内容) — all fully bordered with genuine header rows. The
  other 6 table-bearing files are borderless `①②③` layouts and were flattened.
- New carve-outs, worth promoting to the skill: **inside borders as a corroborating "real table"
  signal**; **step-glyph layout** (col 0 holds only `①…⑳`/`・`) → glyph in front of its text;
  **parallel multi-line cells** → zip into `label：value`, only when the line counts match.

### Fixed
- **Silent text loss in a table carve-out.** A figure/caption branch testing `any(col0_img) and not
  any(col1_img)` treated a `① | text` row's *text* cell as the image and dropped all five text cells
  of `ネットワーク型USB…` — visible only because an image went missing too. The branch now requires the
  image column to be *consistently* image-only and the other column to hold no image at all.
- **New verify check 18, CONTENT COVERAGE** — every source paragraph ≥8 chars must appear in the md,
  compared whitespace-insensitively. This is the net for exactly the class of bug above, where every
  id-consistency check stays green while content vanishes. Generalized into the root `CLAUDE.md`.
- **Double image registration**: reading a cell twice (joined + per-paragraph) registered each in-cell
  image under two ids and orphaned one set, because `img_id()` both mints an id and registers a
  manifest entry. Cells are now read once.
- **`is_listy` bulleted non-lists**: `<w:numId w:val="0"/>` is OOXML's "numbering REMOVED" sentinel,
  so every A4 chapter heading was getting a bogus `・` prefix.
- **Overlay detection delegated** to repo-root `figure_flatten.paragraph_has_overlay_shapes`. A local
  "any shape-ish node" reimplementation fires on every legacy VML picture, because `v:shape` is what
  *hosts* `v:imagedata`.
- `.gitignore`: `web/*/` deliverables ignored (image dirs deliberately NOT), plus `__pycache__/` and
  the per-manual `CLAUDE.md` files, which match the existing convention of staying untracked.

### Known / not fixed
- `セットアップガイドWeb認証版` has **2 annotated screenshots that cannot be flattened** (pitfall 28
  needs a PDF, and there is none). Reported as a verify WARN, not silently accepted.
- `20180531-driver` says "下記のリンクからダウンロード" but the docx contains **no such link** — the page's
  download anchor did not survive the Word capture. Not invented; for the author to fix.
- `20180531-driver`'s `img_1_2`/`img_1_4` are a decorative 39×39 ↓ arrow, pushed as-is pending a
  decision on dropping it.

## [1.4.0] — 2026-07-27

Twelfth manual: **PoiCL_web** — the PoiCL *website* (a scrape of `soft.godai.co.jp/soft/poicl/`
`armarker.html` + `faq.html`), not a paginated document. 7 chunks, 1 image, verify 0 FAIL / 17.

### Added
- **PoiCL_web** (product key `PoiCL_web`, docx renamed `PoiCL_2.docx` → `PoiCL_web.docx` so the id
  stays derived, never hardcoded — pitfall 29). Image pushed (1 file) and md5-verified.
- **First no-PDF manual.** There is no `.pdf` at all, so there are no page numbers: `pdf_page` /
  `pdf_page_end` are `null` everywhere and there is no `_toc_*.json`. What stands in as the origin
  handle is **`source_url` per chunk, recovered from the docx hyperlink relationships**
  (`word/_rels/document.xml.rels`) — the breadcrumb line ending each block carries the link to its
  own page. `Page_IDn` markers are retained unchanged, so the md↔map contract and the downstream
  code node keep working. The build **asserts zero `.pdf`**, so a later-added pdf fails loudly
  rather than being silently ignored.
- **First manual where the author's own `$$$` ARE the delimiters** (user instruction). Inverted
  step 1: a `$$$` is real iff a `Page_IDn` line precedes it, and any *other* `$$$` becomes `---`
  (elsewhere author `$$$` are stripped at build). The docx has **zero heading styles** — section
  titles are the first non-empty paragraph of each block; 7 delimiters → 7 chunks exactly.
- The repeated source-page breadcrumb (`よくある質問 - PoiCL`) moved out of chunk bodies into the map
  as `page_title` — identical trailing text across five chunks hurts retrieval. Verify check 15
  guards it.

### Changed
- `table_to_markdown` carve-out: a **2-col grid with NO header row** → `・label：value` list. The one
  table (動作環境 spec sheet) had no header, so a pipe table promoted the data row
  `パソコン | Windows 11 が動作する機種` into the header slot — misrepresenting content, not merely
  looking ugly, so the usual "when unsure keep the table" default did not apply. Gated on a
  `HEADER_WORDS` vocabulary so any real header row still keeps its table; logged to
  `PoiCL_web_table_review.json` for user confirmation (verify WARN).

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
- **補強土16_本体_v1 (.md polish, no image/tag change — images identical to v1.3.0):** `cell_md` now
  keeps real `|`/newlines and escapes only at pipe-table emission, so non-table `<br>` become real line
  breaks (140→0), a nested 対応形式/拡張子 data table survives as a real table instead of `\|…\|<br>` junk,
  and image-RIGHT figure+caption boxes flatten too (pitfall 30/31).

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
