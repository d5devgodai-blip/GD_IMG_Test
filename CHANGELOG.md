# Changelog

All notable changes to this project are recorded here. The **project version is the git tag** —
run `git describe --tags` to see which version a clone is at. Format loosely follows
[Keep a Changelog](https://keepachangelog.com); this repo is the manuals→Dify pipeline **and** the
jsDelivr image host (`d5devgodai-blip/GD_IMG_Test`).

**How to version a push:** add your change under `[Unreleased]`; when you push a release, rename it to
the new version, date it, and `git tag -a vX.Y.Z` on that commit (new manual → minor bump; image/text
fix → patch bump). `git describe --tags` then tells any clone its version.

## [Unreleased]
- **PoiCL_V123** (11th manual) — images published & renamed to `PoiCL_V123/PoiCL_V123_Image/`
  (`974ef3e`, pitfall-29 naming). Markdown/map deliverable still pending → will land as **v1.1.0**.

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

[1.0.0]: https://github.com/d5devgodai-blip/GD_IMG_Test/releases/tag/v1.0.0
