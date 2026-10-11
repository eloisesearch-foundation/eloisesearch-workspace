# Eloisesearch documentation index

The canonical, evolving documentation lives in Notion. This folder keeps decisions and notes
that should be versioned next to the code.

## Notion (canonical)

- [Eloisesearch Foundation](https://app.notion.com/p/3f55f14602da802f8b3ae81cc827e084)
  - [Project Initiative](https://app.notion.com/p/3f55f14602da81a29de1f335b889c1dd)
    - [MVP Roadmap](https://app.notion.com/p/3f55f14602da81a4b035f788b6a6f6d2)
    - [API Contract & Feature Matrix](https://app.notion.com/p/3f55f14602da811aaf95c7126104bd2f)
    - [Architecture Decision Record](https://app.notion.com/p/3f55f14602da81578afadf1e7b4c8c11)
    - [Quality, Relevance & Benchmark Plan](https://app.notion.com/p/3f55f14602da8186a34fd1ed58af3730)

## Key decisions (summary)

- Single-node Rust + Tantivy service behind an HTTP/JSON API (OpenAPI); gRPC only if justified.
- Public API: Eloisesearch's own versioned HTTP/JSON contract, specified in OpenAPI and covered by contract tests.
- Near-real-time semantics: durable writes via WAL; `refresh=false|true|wait_for`, ~1 s default refresh.
- Behavioral contract: versioned search fixtures (`contracts/search-cases.json`, in `eloisesearch-integration`);
  assert matching document IDs and relative order, not exact scores.

## Decisions

| # | Title | Status |
| --- | --- | --- |
| [ADR-001](decisions/001-meta-repo-sibling-layout.md) | Meta-repo with sibling repositories | Accepted |
