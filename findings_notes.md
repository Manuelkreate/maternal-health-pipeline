From int_neonatal_mortality:

* Gombe 2018 MMR proxy = 2,912 — appears genuine given North East conflict exposure and low facility delivery
* Ondo NMR drop from 33.5 (2018) to 7.1 (2024) — steep decline, reduced sample size warrants cautious interpretation
* Kwara NMR drop from 35.1 (2018) to 8.9 (2024) - also a steep decline. Birth count records reduced from 2510 to 2207. Not significant enough for the drop. Cautious stats
* Rivers MMR proxy = 1,687 — anomalously high for South South, potentially linked to Niger Delta conflict history

From int_anc_vs_delivery:

* North-South divide is stark — Kebbi has 5.4% facility delivery and 92.8% of ANC attendees still deliver without skilled help
* Gombe has 73.6% of ANC attendees delivering without skilled help — worst continuity-of-care gap

From int_conflict_intensity:

* Kebbi shows near-zero conflict activity but has the worst facility delivery rate (5.4%) and highest ANC-to-no-skilled-delivery gap (92.8%) nationally. Conflict does not explain Kebbi's outcomes — points to infrastructure, distance, cultural, or economic barriers. This project cannot determine which. Flag as key anomaly.

General:

* geopolitical_zone is null for all 2018 rows — derived from seed table instead of source data
* Nassarawa spelling inconsistency between ACLED ("Nassarawa") and standard spelling ("Nasarawa") — using ACLED's version for join consistency


Weighted score composition:
| **Metric** | **Suggested Weight**|
|-----------|----------|
| MR delta | 25% |
| Facility delivery delta | 20% |
| Skilled birth attendant delta | 15% |
| ANC 4+ visits delta | 15% |
| ANC but no skilled delivery delta | 10% |
| Home delivery no skilled attendant delta | 10% |
| MMR proxy delta | 5% |
| Doctor at delivery delta | 0% (already captured in skilled attendant) |
| ANC attended but delivered home delta | 0% (overlaps with above) |


Methodology:
* Rankings reflect improvement between survey periods, not absolute performance. A state ranking highly may still have poor absolute outcomes. Cross-reference with mart_state_health_profile for absolute figures.