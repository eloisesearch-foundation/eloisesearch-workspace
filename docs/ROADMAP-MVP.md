# Eloisesearch MVP roadmap

## Objective

A developer clones the demo, runs it, and searches a movie catalog from a Rails +
Nuxt application backed entirely by Eloisesearch: phrases and exclusions,
genre and rating filters, facets, suggestions as they type, highlighted results
and pagination, with indexes that survive restarts. Everything the demo relies on
is documented in the API contract and proven by tests.

The MVP is a single-node service whose API is a documented subset of the
Elasticsearch 9.5.4 REST API and Query DSL, verified against OpenSearch, so teams
can migrate existing applications and tools by pointing them at Eloisesearch. The
demo itself is written against that compatible API.

## Ground rules

- **This file is the task list.** Every open item for the MVP lives here, as a
  checkbox under its phase. Design docs and Notion describe and explain; they do
  not track work. Tick an item in the same commit that completes it.
- **One item at a time.** Each item is designed, tested, implemented, documented
  and merged before the next starts.
- **Design before code** for anything non-trivial: `docs/design-<topic>.md` in the
  repository that owns it (`make docs-new-design`).
- **Docs and CHANGELOG ship with the change**, never "later".
- **The use case decides scope.** A feature the demo does not need waits until
  after the MVP unless it is required for correctness or safety.
- **No performance claims before measurements** (see the
  [quality plan](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/quality-plan.md)).

## Phases

Status: **Done**, **In progress**, **Next**, **Planned**.

### Phase 0 — Define the contract (`eloisesearch`, `eloisesearch-integration`) — In progress

Outcome: the team can say exactly which requests the MVP supports and how success
is measured.

- [x] Architecture and design decisions recorded ([`design-decisions.md`](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/design-decisions.md)).
- [x] Compatibility target decided: subset of Elasticsearch 9.5.4, verified
      against OpenSearch, routes at the root, no product-check header
      ([`design-decisions.md`](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/design-decisions.md#4-api-compatibility-as-the-adoption-path)).
- [x] Compatibility matrix drafted ([`api-contract.md`](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/api-contract.md)).
- [ ] Pin the OpenSearch reference version.
- [ ] Reference harness: Elasticsearch 9.5.4 and OpenSearch run as containers
      in `eloisesearch-integration` CI, so the movie fixtures can be executed
      against them first (baseline) and against Eloisesearch later.
- [ ] Freeze the deterministic movie test corpus and write the behavioral
      fixtures (`contracts/search-cases.json` in `eloisesearch-integration`).
- [ ] Express every fixture as a request in the compatible API (index mapping,
      `_bulk` load, `_search` bodies), and record the reference responses.
- [ ] Decide the malformed-query contract (`lenient` parsing vs 400
      `parsing_exception`).
- [ ] Decide the "To decide" rows of the matrix: `completion` suggester vs
      edge-n-gram prefix match, `english` analyzer, `query_string`, standalone
      `prefix`/`wildcard`/`fuzzy`, accepted shard/replica settings.
- [ ] Label every candidate capability MVP / next phase / out of scope.

### Phase 1 — Service foundation (`eloisesearch`) — Done

Outcome: a maintainable Rust service that builds, runs and is tested in CI.

- [x] Cargo workspace with `eloisesearch-core` (no transport) and `eloisesearch-server`.
- [x] Formatting, pedantic clippy, unit and in-process HTTP tests, CI, MSRV check.
- [x] Configuration from the environment, structured logging, one error model.
- [x] Error envelope aligned with the reference (`root_cause`) and timeouts
      answered with it (408 `request_timeout`), with tests.
- [x] Docker image and Compose setup with a persistent volume.
- [x] `GET /health` and service documentation.

Exit criterion met: a clean checkout builds and serves `/health` with `make run`.

### Phase 2 — Indexing and persistence (`eloisesearch`) — Next

Outcome: documents are stored durably in a persistent index.

- [ ] `docs/design-persistence.md`: WAL record format, acknowledgment boundary,
      sync policy, checkpoint and recovery procedure, refresh defaults.
- [ ] `PUT /{index}` with the supported `mappings` and analysis `settings`;
      `GET`, `HEAD`, `DELETE /{index}`.
- [ ] `PUT /{index}/_doc/{id}`, `POST /{index}/_doc`, `GET` and `DELETE`
      `/{index}/_doc/{id}`, with the reference response shapes.
- [ ] `_bulk` (NDJSON, per-item results and errors).
- [ ] Refresh semantics (`false` / `true` / `wait_for`) and `POST /{index}/_refresh`.
- [ ] Indexes survive graceful restart and abrupt termination.
- [ ] Errors for invalid schemas, missing indexes, duplicate and missing IDs,
      and persistence failures.
- [ ] Lifecycle tests from the [quality plan](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/quality-plan.md#5-reliability-and-lifecycle-tests)
      run in CI without external services.

Exit: document lifecycle works reliably and data is available after restart.

### Phase 3 — Compatible search API (`eloisesearch`) — Planned

Outcome: the engine serves every query the movie demo needs, through the
compatible API.

- [ ] `GET /`, `HEAD /` (server info with the compatible reference version) and
      `GET /_cluster/health`.
- [ ] `_search` and `_count` with the response shape of the reference
      (`hits.total`, `hits.hits`, `_source`, `highlight`, `aggregations`).
- [ ] Field types and analysis: lowercase, accent folding, edge n-grams.
- [ ] Query DSL subset: `match_all`, `bool`, `simple_query_string` (phrases,
      exclusions, `+`, prefix, fuzzy, field boosts), `match`, `multi_match`
      phrase, `term`, `terms`, `range`.
- [ ] `from`/`size`, `sort` with deterministic ties, `_source` filtering.
- [ ] `aggs` (`terms`, `histogram`), `highlight`, suggestions.
- [ ] Unsupported routes, parameters and query constructs rejected with the
      documented error types.
- [ ] Every MVP feature has request/response fixtures and moves to **Supported**
      in `api-contract.md`.
- [ ] Boundary cases tested: blank input, long prefixes, accents, no matches,
      invalid pagination, malformed queries.
- [ ] Compatibility tests: each Supported row compared against Elasticsearch
      9.5.4 and OpenSearch; differences recorded as Partial.
- [ ] OpenAPI document published.

Exit: contract and compatibility tests verify the supported requests, responses
and errors.

### Phase 4 — Movie-search demo (`eloisesearch-integration`, SDKs) — Planned

Outcome: the demo runs entirely on Eloisesearch.

- [ ] Decide the Ruby SDK scope for the MVP: thin HTTP client or Active Record
      integration, given that existing apps can also keep their current HTTP or
      OpenSearch client.
- [ ] Verify the OpenSearch Ruby and JavaScript clients against the supported
      subset; record results in the client table of `api-contract.md`.
- [ ] Repeatable import of the fixed movie dataset.
- [ ] Behavioral fixtures run against Eloisesearch in CI.
- [ ] Relevance reviewed against the judged query set.
- [ ] Rails API on `eloisesearch-ruby`; Nuxt frontend on the demo API
      (`eloisesearch-javascript` where useful).
- [ ] Search, filters, facets and suggestions verified end to end.
- [ ] Migration guide: moving an existing application to Eloisesearch (endpoint
      change, supported subset, client options including the product check of
      the official Elasticsearch clients).

Exit: every movie-search scenario passes in `eloisesearch-integration`.

### Phase 5 — Stabilization and MVP release — Planned

Outcome: a reproducible, documented MVP others can evaluate.

- [ ] End-to-end tests for indexing, search, updates, deletes and restarts.
- [ ] Small repeatable benchmark (latency, throughput, resources).
- [ ] Limitations, configuration and recovery documented.
- [ ] Versioning policy; tag-triggered release with binaries, checksums and
      release notes from the CHANGELOG; Docker image built from the same binary.
- [ ] Release gate in the [quality plan](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/quality-plan.md#6-release-gate) met.
- [ ] First experimental release tagged (with maintainer approval).

Exit: someone new to the project runs the demo, understands the supported
behavior and reproduces the tests.

## Out of scope for the MVP

Distributed clustering, sharding and replication; multi-tenant authorization;
complex aggregations, vector search and advanced analyzers without a validated
need; production performance claims without benchmarks; Active Record callbacks or
automatic synchronization before the core API is validated.

## Risks to track

- **Scope creep:** a broad API delays the first usable release.
- **Query semantics:** grammar, analysis, ranking and highlighting must be
  specified and tested, not assumed.
- **Persistence and visibility:** commit and refresh rules must be explicit.
- **SDK strategy:** validate the HTTP contract first, then decide how much Rails
  integration the Ruby SDK provides.
