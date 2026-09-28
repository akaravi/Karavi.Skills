# 7Expert Relevance Mask

| Domain | Mark relevant when | Typical evidence |
|---|---|---|
| Management & Business | goal, priority, KPI, users, cost, roadmap, or scope changes | brief, acceptance, value/risk decision |
| UX/UI | user flow, layout, interaction, accessibility, theme, or RTL/LTR changes | flow, states, screenshots, keyboard evidence |
| Frontend | client components, state, routing, i18n, performance, or browser behavior changes | diff, build, tests, browser evidence |
| Backend & Architecture | API, domain, persistence boundary, concurrency, or integration changes | contract, architecture, migration, failure tests |
| Infrastructure & Security | secrets, auth, headers, network, runtime, deployment, logs, or resilience changes | scan, config audit, health/fault evidence |
| Quality & Testing | acceptance, regression, test data, gates, or release confidence changes | test matrix, commands, results, defects |
| Content & SEO | public content, metadata, indexing, canonical, hreflang, or copy changes | locale/key parity, metadata and link checks |

Mark `not-relevant` only with a short scope reason. Do not invent analysis for a not-relevant domain. The mask is one artifact, not seven repetitive reports.
