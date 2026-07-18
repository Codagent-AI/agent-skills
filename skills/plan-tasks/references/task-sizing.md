# Task Sizing Calibration

Read this reference when the initial LOE estimate is Medium, Large, or XL, or when provider, migration, feasibility, cutover, or cleanup boundaries are ambiguous.

## Calibration anchors

- **Small → 1 task:** Add one patterned policy setting and carry it through persistence, user-facing configuration, runtime enforcement, provider-specific flags, docs, and tests.
- **Medium → 2 tasks:** Migrate a shared contract, then add a substantial capability that depends on the new contract.
- **Large → 3–4 tasks:** Replace one high-risk subsystem across platforms or providers, including its shared foundation, integrations, production transition, and substantial legacy cleanup.

Treat a shared-contract migration plus one configurable capability built on it as Medium, regardless of how many packages, settings screens, or existing adapters it touches. Raise it to Large only when it also replaces a core subsystem, introduces substantial new external integration mechanisms, or requires a staged production transition.

## Shared foundations and provider integrations

Create a separate foundational task when multiple substantial downstream units consume its stable contract and it can be verified independently with fakes or contract tests, or when it creates an explicit decision or release gate. Do not split merely because the change contains a spike, migration, or new internal package.

Separate provider integrations from their shared core only when they consume a stable contract and require substantial provider-specific protocols, configuration mechanisms, native data formats, hooks, or fixture suites. Keep different flags or arguments emitted through existing adapters with the contract or capability they implement. Keep substantial provider integrations together unless individual integrations have their own release boundary.

## High-risk subsystem replacements

Apply all of these rules:

1. **Fold feasibility into the first foundation task by default.** Bundle a spike with the shared core it directly shapes when its findings are immediately consumed and the design already defines fallbacks for failed assumptions. A label such as "blocking" does not by itself justify a separate task. Split only when a human go/no-go decision or separately scheduled research phase must occur before implementation can be planned.
2. **Separate a reusable shared core from downstream bodies of work.** When two or more substantial units—such as runtime execution and external integrations—consume the same stable, fake-testable contract, treat the core as independently meaningful before production switches to it. Keep its feasibility work in this core task unless the prior rule requires a separate research phase.
3. **Separate substantial provider integrations from the shared core.** Keep the provider matrix as one outcome when it requires distinct protocols, native formats, hooks, or fixture suites. Treat argument or flag differences in existing adapters as patterned propagation instead.
4. **Fold replacement construction into its production transition.** Keep a new internal path with its cutover when it has no user or operational value until traffic switches to it. Split only for a real staged rollout, independently deployable dark launch, or explicit approval/rollback gate.
5. **Separate legacy removal when retention is a safety stage.** Make cleanup a later task when the old path remains as characterization coverage or rollback safety and removal is substantial. Bundle hardening or narrowing of the retained portion of the same subsystem into cleanup. Split it only when it can ship independently or belongs to a different owner or codebase. Fold mechanical, inseparable deletion into cutover.
