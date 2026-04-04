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

Metrics are weighted based on consequences to mortality
| **Metric** | **Suggested Weight**|
|-----------|----------|
| MR delta | 25% (should carry the most weight as it has the highest consequence)|
| Facility delivery delta | 20% |
| Skilled birth attendant delta | 15% |
| ANC 4+ visits delta | 15% |
| ANC but no skilled delivery delta | 10% |
| Home delivery no skilled attendant delta | 10% |
| MMR proxy delta | 5% |
| Doctor at delivery delta | 0% (already captured in skilled attendant) |
| ANC attended but delivered home delta | 0% (doesn't really impact anything unless it involves skilled/unskilled attendants) |


Methodology:
* Rankings reflect improvement between survey periods, not absolute performance. A state ranking highly may still have poor absolute outcomes. Cross-reference with mart_state_health_profile for absolute figures.
* NMR figures are DHS survey-derived state-level weighted averages and may differ from modelled national estimates.
* Relibility flag included in delivery_outcomes and birth_order_neonatal models to allow filtering of unreliable birth counts.


Findings from visuals:
* Facility delivery NMR exceeding home delivery NMR Consistent across ANC adequacy categories. Most plausible explanation is emergency referral bias — women arriving at facilities without prior ANC are disproportionately high-risk presentations, not typical planned facility births. This is a hypothesis; the data shows the pattern but cannot confirm the mechanism.
* Imo State's NMR rose from ~25 to 47 per 1,000 despite a facility delivery rate above 29%. One of the sharpest single-state deteriorations in the dataset. Suggests facility access alone did not translate to better outcomes — possible care quality or staffing issue worth investigating.
* No ANC / Facility Delivery cell for 2024. This combination drops out after the reliability filter, meaning too few women reported arriving at a facility with zero prior ANC visits to produce a stable rate. Could reflect genuine improvement in ANC uptake by 2024, or a sampling effect. Either way, the 2018 figure (facility + no ANC = highest NMR in the dataset) stands as the baseline.
* First matrix, and Imo stands out immediately. Adequate ANC, yet 49.82 NMR. Other states like Kebbi (44.42%), Kaduna (43.46), Bauchi (40.93), Adamawa (40.41) *may* be explained with conflict, thankfully we're going to do the visuals too. There are also states with higher NMR with adequate ANC than no_ANC. 
* There's no data for Imo for No ANC, so i can't tell, but even it's adequate anc has a higher NMR than inadequate ANC. Adequate ANC attendance in Imo is not translating to survival. The question is whether women are attending ANC but delivering without skilled attendance, or whether facility quality in Imo specifically is the issue. The birth attendant matrix will shed light on that.
* A state like Bauchi has 40.93 for adequate, 27.11 for inadequate. Jigawa also stands out. it's really weird. Other states that are tilting this data.
The broader pattern is that adequate ANC not guaranteeing low NMR in multiple northern states and directly supports the hypothesis that ANC quality varies by state. Attendance is being captured, but what happens at those visits may differ significantly between north and south.
* the data shows that skilled attendance and facility delivery are associated with higher NMR in no-ANC cases, and a plausible explanation is emergency referral bias. But the data cannot distinguish between "facilities are absorbing high-risk cases" and "facilities are failing high-risk cases." Both could be true simultaneously. 
* The bars generally shorten as wealth index increases within each zone, even in the north-west where overall NMR is elevated. Wealth provides some protection everywhere, but geography sets the ceiling on how much wealth can protect you. a rich woman in the north-west still has worse outcomes than a poor woman in the south-east. All based off off Neomortality rate by zone and wealth visual