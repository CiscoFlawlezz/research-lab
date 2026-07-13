## title: "Weather Forecast Models — Technical Reference" version: 1 status: "E4 — AI-drafted, pending Architect verification and canonization" created: 2026-07-11 vault_location: "07 References/Data Sources" tags: [nwp, ensembles, data-assimilation, nbm, data-sources, canon-candidate]

# Weather Forecast Models — Technical Reference

**Vault location:** `07 References/Data Sources` **Level:** Quantitative researcher / engineering reference (assumes probability theory, forecast verification concepts, basic numerical methods) **Cross-links:** [[National Weather Service]] · [[NOAA]] · [[Forecast Verification]] · [[Proper Scoring Rules and Calibration - Technical Reference]] · [[Probability]] · [[Bayesian Statistics]] · [[Prediction Markets]] · [[Edge Detection]] · [[Kalshi Ticker Anatomy and Market Structure]] · [[Kalshi API]] · [[Information Theory for Forecasting]] · [[Machine Learning]] · [[Effective Sample Size]] · [[Glossary]] **Created:** 2026-07-11 (V1)

> [!warning] Epistemic status (Invariant 3) This document is AI-drafted testimony, not evidence. Every bibliographic citation and every **numerical model specification** (grid spacing, member counts, update cadence, forecast horizon, product availability) was produced from model knowledge without live retrieval and **must be independently verified against current official documentation before any statement here becomes load-bearing in a registration, ADR, or collector implementation**. Model configurations are _version-sensitive_: operational centers upgrade systems one or more times per year, and a specification that was accurate at drafting may be stale within months. Specifications that feed collector design or A3/A4 decisions carry ★ (priority verification tier); lower-confidence attributions carry ⚑ per house convention. Where this document and any ratified A-series document disagree, the A-series document governs.

> [!info] Scope This is the Lab's canonical reference on **where weather forecasts come from**: the numerical weather prediction (NWP) systems, ensemble methods, post-processing layers, and human forecast processes that generate the probability-relevant information the Lab measures against Kalshi temperature markets. It is a literature synthesis and engineering reference, not a forecasting tutorial. The settlement side of the pipeline (CLI products, station observations, F1) is owned by [[National Weather Service]]; the scoring side is owned by [[Forecast Verification]] and [[Proper Scoring Rules and Calibration - Technical Reference]]; this document owns the _forecast-generation_ side.

---

## 1. Historical Development

### 1.1 Richardson's dream

Numerical weather prediction begins as a thought experiment. Vilhelm Bjerknes (1904 ⚑) first framed forecasting as a deterministic initial-value problem: given the present state of the atmosphere and the physical laws governing it, the future state is computable in principle. Lewis Fry Richardson's _Weather Prediction by Numerical Process_ (1922) attempted it in practice: he discretized the governing equations over a grid covering central Europe and, computing by hand over a period of years, produced a six-hour pressure-tendency forecast that was catastrophically wrong — a predicted surface pressure change of 145 hPa against an observed change near zero. The failure was diagnostic, not conceptual: Richardson's initial data contained unbalanced gravity-wave noise that the equations amplified (the initialization problem, §4), and his explicit time-stepping violated what would later be formalized as the Courant–Friedrichs–Lewy stability condition (1928). Richardson nonetheless framed the field's ambition precisely, imagining a "forecast factory" of 64,000 human computers — a vision that is, structurally, a modern massively parallel supercomputer. The lesson the Lab should retain: **the first serious attempt at a forecasting system failed because of initialization quality and numerical stability, not because of the physics** — the same two failure surfaces that dominate operational NWP today.

### 1.2 The ENIAC era: von Neumann and Charney

The field became viable when three things converged in the late 1940s: electronic computation (John von Neumann's Princeton Meteorology Project, launched 1946), a tractable reduced equation set, and a theory of which atmospheric motions matter. Jule Charney supplied the second and third: his scale analysis (Charney 1948 ⚑) filtered the fast gravity and acoustic waves that had destroyed Richardson's forecast, yielding the quasi-geostrophic system, and Charney, Fjørtoft, and von Neumann (1950) ran the first successful numerical forecasts — 24-hour barotropic (single-level) forecasts of 500 hPa height on the ENIAC. The computation took roughly 24 hours of machine time for a 24-hour forecast: real-time parity, immediately understood as a threshold that hardware growth would cross. Operational NWP began in 1954 (Sweden ⚑) and 1955 (the U.S. Joint Numerical Weather Prediction Unit, ancestor of today's NCEP). The historical arc from filtered models back to Richardson's full **primitive equations** completed in the 1960s as computers grew capable of handling the fast modes with proper initialization.

### 1.3 Lorenz and the discovery of limits

Edward Lorenz's 1963 paper "Deterministic Nonperiodic Flow" demonstrated, in a three-variable convection model, that deterministic nonlinear systems can exhibit sensitive dependence on initial conditions — trajectories starting arbitrarily close diverge exponentially. Lorenz (1969) extended this to the atmosphere's multi-scale structure, arguing that small-scale errors cascade upscale and impose a **finite intrinsic predictability limit** (canonically quoted as roughly two weeks for synoptic-scale weather ⚑) that _no improvement in models or observations can remove_. This is the single most consequential result in the field for the Lab's purposes: it converts weather forecasting from a deterministic engineering problem into an irreducibly probabilistic one, and it is the physical foundation for everything in §5, §7, and §8. The mature statement of the program is Palmer (2019 ⚑) and the ensemble-prediction literature (§7): since the forecast _must_ be uncertain, the scientific product is a probability distribution, and the correct evaluation apparatus is exactly the proper-scoring machinery in [[Proper Scoring Rules and Calibration - Technical Reference]].

### 1.4 Arakawa and the craft of discretization

Akio Arakawa's contributions (1960s–70s) illustrate that _how_ equations are discretized is as consequential as the equations themselves. Arakawa's energy- and enstrophy-conserving finite-difference schemes (Arakawa 1966 ⚑) suppressed the nonlinear computational instability that plagued long integrations, and the **Arakawa grids** (A through E; the staggered C-grid dominates modern models) remain the standard taxonomy for variable placement. Arakawa and Schubert (1974 ⚑) founded modern convective parameterization — the treatment of sub-grid cumulus convection whose imperfections remain a leading source of forecast error and model bias today (§9). The engineering moral: numerical scheme choices made for stability and conservation reasons imprint systematic, structural signatures on model output. Model biases are not noise; they are consequences of design decisions, which is why they are persistent and learnable (§9, §14).

### 1.5 Institutionalization: NCEP, ECMWF, and the quiet revolution

The U.S. line runs JNWPU → National Meteorological Center (NMC, 1958) → **National Centers for Environmental Prediction** (NCEP, 1995), the NOAA/NWS component that runs the American operational suite (§6). The **European Centre for Medium-Range Weather Forecasts** (ECMWF), established by convention in 1975 with first operational forecasts in 1979, pursued a deliberately narrow mandate — medium-range global prediction, one model, maximal resources per forecast — and its Integrated Forecasting System (IFS) has led most global headline skill metrics for decades ⚑. Bauer, Thorpe, and Brunet (2015, _Nature_) named the cumulative result the **"quiet revolution"**: forecast skill has improved by roughly one day of lead time per decade — today's 6-day forecast is as skillful as the 5-day forecast was a decade ago — through the compounding of better observations (especially satellite radiances), better data assimilation, higher resolution, better physics, and ensembles. Two structural implications for the Lab: (i) forecast skill is **non-stationary at decadal scale** — verification baselines drift, and multi-year archives mix regimes; (ii) the marginal improvements now come increasingly from _assimilation and post-processing_, not raw model physics — which is precisely the layer (NBM, MOS, statistical calibration) closest to the Lab's own methods.

### 1.6 The statistical counter-tradition

Running parallel to the dynamical lineage is a statistical one the Lab descends from more directly. Before NWP matured, forecasting _was_ statistics — analog methods, regression on synoptic predictors, subjective probability (Cooke's 1906 ⚑ probability forecasts in Australia; Hallenbeck 1920 ⚑; the U.S. PoP program from 1965, the longest-running operational probability forecast in any field ⚑). When NWP arrived, statistics re-entered as the correction layer: **perfect prog** (regressions on observed predictors, applied to model output) and then **MOS** (Glahn and Lowry 1972 — regressions on _model_ predictors, absorbing model bias into the fit), which has quietly added skill to every U.S. point forecast for five decades. The modern descendants are ensemble post-processing (§3.5) and the NBM (§11). The historiographic point matters for the Lab's self-understanding: **the highest-leverage improvements to point forecasts have repeatedly come from the statistical layer wrapped around the physics, not from the physics alone** — and that layer's tools (regression, calibration, verification, proper scoring) are exactly the Lab's tools. The Lab is not an outsider to meteorology; it is a participant in meteorology's oldest parallel tradition, pointed at a new grading mechanism (a market) instead of a bulletin.

---

## 2. Numerical Weather Prediction

### 2.1 The physical foundations

NWP rests on the claim that the atmosphere is a fluid governed by known physics, so its evolution is the solution of a system of partial differential equations given an initial state. The governing set — the **primitive equations** — comprises:

1. **Momentum equations** (Navier–Stokes on a rotating sphere): three components relating acceleration to pressure-gradient force, Coriolis force, gravity, and friction.
2. **Thermodynamic energy equation**: temperature evolution under adiabatic compression/expansion and diabatic heating (radiation, latent heat release, surface fluxes).
3. **Continuity equation**: conservation of mass.
4. **Equation of state** (ideal gas law): closing the system by relating pressure, density, and temperature.
5. **Moisture (and hydrometeor) conservation equations**: water vapor, cloud water/ice, rain, snow, graupel, each with sources and sinks.

Global models historically imposed the **hydrostatic approximation** (vertical pressure-gradient force balances gravity), valid when horizontal scales greatly exceed vertical scales; convection-permitting models at grid spacings below roughly 10 km must solve **non-hydrostatic** equations because vertical accelerations in convection are no longer negligible. This is the physical dividing line between the global models (§6.1–§6.5) and the convection-allowing models like HRRR (§6.6): they are not just finer versions of the same thing; they solve different equation sets and represent convection by fundamentally different means.

### 2.2 What cannot be resolved must be parameterized

No computationally feasible grid resolves all dynamically active scales — turbulent eddies act at centimeters, cloud droplets at microns. Processes below the grid scale are **parameterized**: represented statistically as functions of the resolved state. The standard parameterization suite covers radiation (shortwave/longwave transfer), deep and shallow convection, cloud microphysics, the planetary boundary layer and turbulence, gravity-wave drag, and land-surface/ocean-surface exchange. Parameterizations are the locus of most model _bias_ (§9): they are semi-empirical, tuned, and imperfect, and their errors are state-dependent and systematic rather than random. For the Lab's target variable — **daily 2 m maximum/minimum temperature at specific stations** — the relevant error budget is dominated by boundary-layer, land-surface, radiation, and (for Miami and coastal NYC) convection and sea-breeze parameterizations, plus the representativeness gap between a grid-cell average and a point station (§9.6). Understanding that a model's 2 m temperature is a _derived, heavily parameterized diagnostic_ — not a directly simulated prognostic on the model's native levels — is essential context for interpreting model output at the station scale ⚑.

### 2.3 Discretization and numerical integration

The continuous equations are discretized in space and time. Three spatial families dominate:

- **Finite-difference / grid-point methods** on latitude–longitude or projected grids (historical NAM/RAP lineage).
- **Spectral methods**, expanding fields in spherical harmonics — ECMWF's IFS and the pre-2019 GFS spectral core; efficient and accurate for smooth global fields, with grid-point transforms for local physics.
- **Finite-volume methods on quasi-uniform spherical grids** — the modern trend, avoiding the pole singularity of lat–lon grids: NOAA's **FV3** (cubed sphere; GFS dynamical core since 2019 ★), DWD's **ICON** (icosahedral), MPAS (Voronoi). ⚑

Time integration must respect the **CFL condition**: information cannot propagate more than one grid cell per time step, so explicit schemes require time steps that shrink with grid spacing. Operational models use **semi-implicit** treatment of fast waves and often **semi-Lagrangian** advection to permit long time steps (the ECMWF hallmark ⚑). The compound cost law matters for engineering intuition: halving horizontal grid spacing multiplies computational cost by roughly **8–16×** (4× more columns, ~2× more vertical resolution in some upgrades, 2× shorter time step), which is why resolution increases arrive in discrete generational upgrades tied to supercomputer procurements, and why model configurations in §6 change on multi-year cadences that the Lab must track as data-provenance events.

### 2.4 Why weather prediction is a numerical simulation problem

The primitive equations admit no closed-form solutions for realistic atmospheres; the system is nonlinear, multi-scale, and chaotic. Every forecast is therefore the output of a large numerical simulation: an approximate solution of approximate equations from an approximate initial state. This framing yields the three-part **error taxonomy** used throughout this document: (i) **initial-condition error** (imperfect observations and assimilation, §4), (ii) **model error** (discretization plus parameterization imperfection, §9), and (iii) **intrinsic chaotic error growth** (Lorenz, §8) that amplifies both. Ensemble prediction (§5, §7) is the operational technology for representing all three as a probability distribution — and the Lab's entire premise is that markets and models may convert that distribution into event probabilities with _different, measurable_ skill.

### 2.5 Vertical structure and the 2 m diagnostic

Models discretize the vertical into 50–140 levels ⚑ on hybrid sigma–pressure coordinates: terrain-following near the surface, transitioning to pure pressure surfaces aloft. Level spacing is concentrated in the boundary layer, but even so the lowest prognostic model level typically sits 10–30 m above the surface ⚑ — **there is no model level at 2 m**. The "2 m temperature" every consumer product reports is a _diagnostic interpolation_ between the lowest model level and the model's skin temperature, mediated by surface-layer similarity theory (Monin–Obukhov ⚑) and the land-surface scheme's estimate of surface fluxes. Three consequences the Lab should hold permanently: (i) 2 m temperature inherits the errors of two parameterizations (surface layer + land surface) _on top of_ free-atmosphere errors; (ii) different centers use different diagnostic formulations, so inter-model 2 m comparisons partially compare interpolation conventions ⚑; (iii) under strongly stable nocturnal conditions the similarity assumptions degrade and the diagnostic is least trustworthy — exactly the regime of record-low markets. This is a second, independent reason (beyond §9.6's representativeness argument) that raw model 2 m values are pre-forecast material rather than forecasts of the settlement variable.

### 2.6 Computational scale of the operational enterprise

Order-of-magnitude anchors ⚑: operational centers run dedicated supercomputers in the tens-of-petaflops class; a global deterministic cycle consumes wall-clock tens of minutes on thousands of nodes under a hard real-time deadline (a forecast late is a forecast worthless); ensembles multiply this by member count at reduced resolution. The real-time deadline forces every center into the same architecture — fixed cycle times, fixed product schedules, staged dissemination — which is precisely why the information clock of §13 is _knowable_: operational meteorology is industrially periodic because supercomputing under deadline demands it.

---

## 3. The Forecast Production Pipeline

Every operational forecast is the output of a repeating industrial cycle. Understanding the cycle's stages — and their _timing_ — is prerequisite to the Lab's latency analysis (§13) and collection design (§15).

### 3.1 Observations

The global observing system feeds every cycle with on the order of **tens of millions of observations per day** ⚑, of radically heterogeneous type:

- **Surface stations** (SYNOP, METAR): the ASOS/AWOS network that also anchors Kalshi settlement (see [[National Weather Service]], F1). Dense over land, sparse over oceans.
- **Radiosondes**: balloon-borne vertical profiles, canonically at 00Z and 12Z from ~800–900 global sites ⚑. Historically the backbone; now a small fraction of assimilated data but still disproportionately valuable as unbiased anchor profiles.
- **Aircraft observations** (AMDAR/ACARS): temperature and wind along flight tracks and ascent/descent profiles near hubs. The COVID-19 flight reduction of 2020 produced a measurable NWP skill degradation ⚑ — a natural experiment demonstrating their weight.
- **Satellite radiances**: the dominant volume — microwave and infrared sounders (AMSU, ATMS, IASI, CrIS ⚑), GNSS radio occultation, scatterometer surface winds, atmospheric motion vectors. Crucially these observe _radiances_, not temperatures; assimilation requires a radiative-transfer observation operator (§4.2).
- **Radar, wind profilers, buoys, ships, ground GNSS**.

### 3.2 Quality control

Raw observations contain gross errors, biases, and representativeness problems. Operational QC includes blacklisting of known-bad platforms, background checks (rejecting observations too far from the model first guess), buddy checks against neighbors, and **variational bias correction** (VarBC ⚑) for satellite radiances, which continuously estimates and removes platform-dependent biases inside the assimilation itself. Engineering resonance for the Lab: operational centers treat _observation ingestion_ as an adversarial data-quality problem with automated rejection and audit trails — the same posture the Lab's collectors take toward API payloads, and a reminder that the model's "initial state" is already a heavily processed statistical product, not raw truth.

### 3.3 Data assimilation and initialization

The QC'd observations are merged with the previous cycle's short-range forecast (the **background** or first guess) to produce the **analysis** — the best estimate of the current atmospheric state on the model grid. §4 treats this in depth. The analysis is then lightly balanced/filtered (initialization) to suppress spurious fast waves — the modern, gentle descendant of the problem that destroyed Richardson's forecast.

### 3.4 Numerical integration

The model integrates forward from the analysis. Global deterministic runs occupy large fractions of some of the world's biggest supercomputers for tens of minutes to a few hours of wall-clock time ⚑. Output states are written at fixed intervals (hourly for short-range/high-resolution systems; 3–6-hourly at longer leads for global systems ⚑).

### 3.5 Post-processing

Raw model output is systematically biased at the point/station scale and is not yet a consumer product. The post-processing layer includes:

- **Model Output Statistics (MOS)** (Glahn and Lowry 1972): regression of observed station outcomes on model predictors, fit per station/season/lead — the classic statistical bias-correction and downscaling technology, still issued for GFS (MAV/MEX bulletins ⚑).
- **Bias correction and downscaling** of gridded fields (e.g., NBM's decaying-average bias correction ⚑).
- **Ensemble post-processing / statistical calibration**: BMA (Raftery et al. 2005), non-homogeneous Gaussian regression / EMOS (Gneiting et al. 2005) — turning underdispersive raw ensembles into calibrated predictive distributions. This is scientifically the closest layer to the Lab's own modeling ambitions and is treated as a first-class subject in [[Forecast Verification]] and [[Machine Learning]].
- **The National Blend of Models (NBM)** — the NWS's operational super-ensemble post-processor (§11).

### 3.6 Dissemination

Products are published as **GRIB2** files on public servers — NOMADS and the NWS/NCEP web services for U.S. models, plus AWS/GCP/Azure Open Data mirrors (NODD program ★) that are now the engineering-preferred access path (§16). ECMWF has moved substantially toward open data (open ENS/HRES subsets at reduced resolution since 2022, expanded since ⚑★ — the current licensing/portfolio state must be verified before any collector depends on it). Dissemination _timing_ is the market-relevant fact: model output becomes public in a staggered stream, by forecast hour, beginning roughly 3.5–5 hours after the nominal cycle time for global models and ~1–2 hours for rapid-refresh systems ⚑★ — the nominal "00Z run" reaches the public mid-morning UTC. §13 develops the market implications; the exact per-product publication schedule is a ★ collector-design input that must be measured, not assumed (dual-timestamp discipline: record both cycle time and retrieval time).

### 3.7 Anatomy of a cycle's timing ★

The stages above imply a strict internal schedule, worth making explicit because §13 and all collector cadence decisions inherit it. For a nominal 00Z global cycle ⚑★ (illustrative; measure per system): observations valid around 00Z arrive over the following tens of minutes to hours; a **data cutoff** closes the assimilation window (early cutoff for the fast "update" runs, later for the full analysis); assimilation and integration consume roughly 1–3 h of wall clock; post-processing and product generation add more; staged public dissemination begins ~3.5–5 h after nominal time for GFS-class systems and completes over the following hour-plus as later forecast hours post ⚑★. Rapid-refresh systems (HRRR) compress the whole chain to ~1–2 h ⚑★. Two Lab-facing corollaries. First, **nominal time ≠ information time ≠ availability time**: a "00Z GFS" contains observations to its cutoff, encodes the world as of roughly 00Z, and reaches the public mid-morning UTC — three distinct timestamps, all of which the archive must be able to reconstruct (dual-timestamp discipline extended to _triple_ for model products: cycle time, availability time, retrieval time). Second, the _staggering_ of availability across forecast hours means "the 00Z run is out" is not an event but a process; market-reaction studies (§13.3) must define the event time operationally — e.g., availability of the forecast hour covering the target day's afternoon — and that definition belongs in a registration, not in code comments.

---

## 4. Data Assimilation

### 4.1 The problem

The atmosphere's state vector in a modern global model has O(109)O(10^9) O(109) degrees of freedom ⚑; the daily observation count is orders of magnitude smaller, irregularly distributed, indirect (radiances), and noisy. Data assimilation is the statistical estimation problem of combining observations yy y with a model background xbx_b xb​ into an analysis xax_a xa​, weighting each by its uncertainty. Its Bayesian skeleton is exactly the machinery in [[Bayesian Statistics]]: the background is the prior, observations enter through a likelihood, the analysis approximates the posterior mode or mean. In the linear-Gaussian idealization the optimal weight is the Kalman gain, xa=xb+K(y−Hxb)x_a = x_b + K(y - H x_b) xa​=xb​+K(y−Hxb​) with K=BH⊤(HBH⊤+R)−1K = B H^\top (H B H^\top + R)^{-1} K=BH⊤(HBH⊤+R)−1, where BB B and RR R are background- and observation-error covariances and HH H the observation operator mapping model state to observation space. All operational methods are computable approximations to this update at immense scale.

### 4.2 Variational methods: 3D-Var and 4D-Var

**3D-Var** finds the analysis by minimizing J(x)=12(x−xb)⊤B−1(x−xb)+12(y−H(x))⊤R−1(y−H(x))J(x) = \tfrac12 (x - x_b)^\top B^{-1} (x - x_b) + \tfrac12 (y - H(x))^\top R^{-1} (y - H(x)) J(x)=21​(x−xb​)⊤B−1(x−xb​)+21​(y−H(x))⊤R−1(y−H(x)) — a maximum-a-posteriori estimate with all observations treated as valid at one time. **4D-Var** generalizes this over an assimilation _window_ (6–12 h ⚑): it seeks the initial state whose model trajectory best fits observations distributed in time, using the tangent-linear and adjoint models to compute gradients. 4D-Var implicitly evolves the background covariance with the flow inside the window and extracts information from observation _timing_ — at the cost of maintaining an adjoint model, one of the largest software liabilities in the field. ECMWF pioneered operational 4D-Var (1997 ⚑) and attributes a substantial share of its historical skill lead to assimilation quality. The variational treatment of satellite radiances through radiative-transfer observation operators (with VarBC) is what unlocked the satellite era's skill gains, including the near-elimination of the historical Southern-Hemisphere skill deficit ⚑.

### 4.3 Ensemble Kalman filters

The **EnKF** (Evensen 1994; Houtekamer and Mitchell 1998 ⚑) represents BB B by the sample covariance of an ensemble of short-range forecasts, making the background error **flow-dependent** by construction and requiring no adjoint. Costs: sampling noise from O(101−2)O(10^{1-2}) O(101−2) members representing O(109)O(10^9) O(109)-dimensional covariances, managed by **covariance localization** (tapering spurious long-range correlations) and **inflation** (counteracting systematic variance underestimation). Variants (serial EnSRF, ETKF, LETKF ⚑) differ in the algebra of the update. EnKFs double as ensemble-generation engines: the analysis ensemble is a ready-made set of initial-condition perturbations (§7.2).

### 4.4 Hybrid methods — the operational present

Modern centers run **hybrids** that combine a climatological/static BB B with ensemble flow-dependent covariances inside a variational solver — hybrid 4DEnVar at NCEP for the GFS (avoiding the adjoint by using ensemble trajectories to represent time evolution ⚑★), and ensemble-of-data-assimilations (EDA)-informed 4D-Var at ECMWF ⚑. The engineering read: **initialization quality is the single largest controllable driver of medium-range forecast skill**, which is why centers spend comparable resources on assimilation as on the forecast model itself, and why forecast databases must record model _and assimilation-system_ versions — an upgrade to either is a provenance break for the Lab's archives (§15.6).

### 4.5 Why this matters downstream

Three durable consequences for the Lab. (i) **Analyses are model-flavored**: "verifying against analysis" partially verifies a model against itself; station observations (the Lab's settlement chain) are the independent ground truth. (ii) **Assimilation windows and cutoffs create the latency floor** in §13 — a "00Z" forecast contains observations only up to its data cutoff and becomes public hours later. (iii) **Flow-dependent uncertainty is real and measurable**: some initial states are simply better constrained than others, which is one reason day-to-day forecast difficulty varies and why ensemble spread carries information (§7.4).

### 4.6 Observation weighting in practice

The abstract weighting in §4.1 (BB B vs. RR R) becomes concrete engineering through several channels worth knowing because they explain day-to-day analysis quality variation. **Observation error covariance RR R** encodes instrument error _plus_ representativeness error (a radiosonde samples a point; the model needs a grid-box mean), and for satellite radiances includes inter-channel correlations that, historically neglected, forced centers to inflate errors and thin data ⚑. **Thinning and superobbing**: dense data (satellite, radar, aircraft) are deliberately subsampled or averaged, both to control correlated-error damage and computational cost — the analysis does not use all data equally even when it uses them all. **Bias correction before weighting**: VarBC (§3.2) means satellite data are adjusted _toward the model climate_ in a controlled way, anchored by unbiased observation types (radiosondes, GNSS-RO ⚑) — remove the anchors and the system can drift toward its own biases, a documented failure mode ⚑. **Quality-control feedback**: observations far from the background get down-weighted or rejected; in rapidly evolving or poorly observed situations this correctly discards bad data _and_ incorrectly discards the surprising-but-true — one mechanism behind occasional spectacular busts in rapidly deepening systems ⚑. The synthesis for the Lab: analysis quality is flow- and observation-availability-dependent; days differ in how well-constrained the initial state was, and ensemble spread (via EDA/EnKF perturbations) is the operational estimate of exactly that variation. When §13's studies eventually ask "why did all models bust together on this day," the answer often lives here, upstream of every model.

---

## 5. Deterministic vs. Ensemble Forecasting

### 5.1 Two products, two epistemologies

A **deterministic forecast** is a single integration from the best available analysis, at the highest affordable resolution: one trajectory, no uncertainty statement. An **ensemble forecast** is a set of mm m integrations (typically 20–50 operationally) from perturbed initial conditions with perturbed model physics, whose dispersion is designed to sample the forecast's error distribution: an explicit, if imperfect, probability object. The deterministic product answers "what is the single best guess?"; the ensemble answers "what is the distribution of plausible outcomes?" — and only the second question is native to the Lab's architecture, because per [[Probability]] and [[Forecast Verification]], a probability is a claim about a population, and only distributional forecasts can be graded as probabilities without an intermediate modeling step.

### 5.2 Why ensembles win for decision-making

Three compounding reasons:

1. **The ensemble mean beats the deterministic run on average error.** Nonlinear error growth makes the deterministic trajectory just one draw; averaging filters unpredictable scales, so the ensemble-mean RMSE is systematically lower at medium range ⚑ — though the mean is smooth and physically unrealistic as a _scenario_.
2. **Distributions dominate points for downstream decisions.** Per the cost–loss framework and the Schervish representation ([[Forecast Verification]] §1.3, §9.4), users with different cost ratios act at different probability thresholds; a point forecast serves one implicit threshold, a calibrated distribution serves all simultaneously. For the Lab this is not analogy but identity: **a Kalshi bracket price _is_ a probability claim, and only a distributional forecast can be compared to it on equal terms.**
3. **Flow-dependent uncertainty.** Spread varies with the meteorological situation, flagging low- and high-predictability regimes — information a deterministic run cannot express at all (§7.4).

### 5.3 The persistent caveat

Raw ensembles are **not calibrated probabilities**. They are systematically underdispersive (too confident) and biased, for reasons developed in §7.5; every serious probabilistic use routes through statistical post-processing (EMOS/BMA/NBM/ML calibration). The Lab should internalize the two-layer picture: _dynamical ensemble_ (physics, scenario generation) + _statistical calibration_ (probability manufacture). Market-facing probability claims live in the second layer — which is exactly where the Lab's own modeling can add value without running any atmospheric model itself.

### 5.4 Where deterministic runs retain their place

The ensemble case (§5.2) should not curdle into dogma; deterministic runs persist operationally for defensible reasons the Lab will encounter in the literature. (i) **Resolution**: the deterministic run historically ran at ~2× the ensemble's resolution, resolving terrain, coastlines, and convection better — a genuine advantage for _feature realism_ even where point scores don't show it (though the ECMWF's recent resolution unification erodes this rationale ⚑★). (ii) **Latency and simplicity**: one field, first available, human-readable. (iii) **Scenario anchoring**: forecasters reason about physical storylines, and a coherent single trajectory supports mechanism-level thinking that a percentile cloud does not. (iv) **Post-processing input**: MOS and many blend components are built on deterministic output for historical-archive reasons. For the Lab, deterministic products enter as _features and blend components_ (§14.2), and as the objects most likely to anchor _market participants'_ attention (§13.3's anchoring hypothesis) — a reason to archive them even if the Lab's own probability manufacture leans on distributions: to model the crowd, archive what the crowd reads.

---

## 6. Major Forecast Models

> [!warning] Version sensitivity (★ throughout) Every specification in this section — grid spacing, vertical levels, member counts, cycle frequency, horizon, output cadence — is a snapshot of a moving target, drafted from model knowledge and **not verified against current official configuration documents**. Operational centers upgrade systems roughly annually. Before any figure here enters a collector spec, ADR, or registration, verify against the primary source (NCEP model documentation pages, ECMWF IFS cycle documentation, DWD/UKMO/ECCC equivalents) and record the verification date. Treat the _qualitative_ characterizations (strengths, biases, roles) as more durable than the numbers, and the numbers as ★ placeholders.

### 6.1 GFS — Global Forecast System (NOAA/NCEP)

- **Organization:** NOAA/NCEP (EMC). The flagship U.S. global deterministic model.
- **Configuration ★:** FV3 finite-volume cubed-sphere dynamical core (since 2019); ~13 km nominal horizontal grid spacing; 127 vertical levels ⚑.
- **Cadence ★:** 4 cycles/day (00/06/12/18Z); horizon 384 h (16 days); output hourly to 120 h, 3-hourly beyond ⚑.
- **Strengths:** free, fully open, long archive, four daily cycles (twice the cycle frequency of ECMWF HRES's headline runs), 16-day horizon, the anchor for MOS and a heavy NBM input.
- **Weaknesses:** persistently behind ECMWF IFS on global headline scores at medium range ⚑; hydrostatic — convection parameterized, so warm-season precipitation and convectively contaminated temperature regimes are structurally uncertain; known lineage of 2 m temperature biases that are region- and regime-dependent (⚑ — measure, don't assume; §9).
- **Lab role:** the canonical "global deterministic" rung candidate; the source of GFS MOS; freely archivable at scale via NODD.

### 6.2 GEFS — Global Ensemble Forecast System (NOAA/NCEP)

- **Configuration ★:** FV3 core; ~25 km; **31 members** (30 perturbed + control) since GEFSv12 (2020) ⚑; 4 cycles/day; horizon 16 days (35 days for a subset of cycles, supporting weeks 3–4 guidance ⚑).
- **Perturbations:** EnKF-based initial perturbations plus stochastic physics (SPPT/SKEB family ⚑).
- **Strengths:** the free, open, U.S. counterpart to ECMWF ENS; a multi-decade **reforecast** dataset exists for GEFSv12 (⚑★ — reforecasts are gold for statistical calibration research because they provide a long training sample under a _fixed_ model version).
- **Weaknesses:** fewer members and coarser resolution than ECMWF ENS; raw underdispersion at short leads (generic to all ensembles).
- **Lab role:** primary candidate for the Lab's first _ensemble_ model rung; bracket probabilities can be computed directly from member counts and then calibrated — the cleanest path from public data to a genuinely distributional forecaster.

### 6.3 ECMWF IFS — Integrated Forecasting System (HRES / deterministic)

- **Organization:** ECMWF (intergovernmental, Reading/Bologna/Bonn).
- **Configuration ★:** spectral semi-implicit semi-Lagrangian hydrostatic core; ~9 km grid (TCo1279) for the high-resolution configuration ⚑; note that in recent cycles the deterministic HRES and the ensemble were unified at the same 9 km resolution, with the "HRES" role played by the ensemble control ⚑★ — the current product architecture must be verified.
- **Cadence ★:** 00/12Z full runs (+06/18Z shorter "boundary" runs ⚑); horizon 10 days (HRES role) / 15 days (ENS).
- **Strengths:** the long-standing global skill leader ⚑; world-class 4D-Var/EDA assimilation; superior medium-range synoptic evolution.
- **Weaknesses:** access. Historically licensed/paid; the open-data offering has expanded (0.25° open products since ~2022–2024 ⚑★) but the exact free portfolio, resolution, and latency **must be verified before any Lab dependency**. U.S. station-scale 2 m temperature is not automatically better than well-post-processed U.S. mesoscale guidance despite headline skill ⚑.
- **Lab role:** reference-class global model; its _availability profile_ (what is free, at what resolution and delay) is a standing ★ open question for collector design.

### 6.4 ECMWF ENS (EPS) — the ECMWF ensemble

- **Configuration ★:** **51 members** (50 perturbed + control); ~9 km in recent cycles ⚑; 00/06/12/18Z with the main cycles at 00/12Z ⚑; horizon 15 days, with extensions bridging to the extended-range system.
- **Perturbations:** EDA-based initial perturbations plus singular vectors (the historical ECMWF signature ⚑) and stochastic physics (SPPT lineage; SPP in recent cycles ⚑).
- **Strengths:** the reference ensemble in the verification literature; largest member count among majors; strong calibration research base.
- **Weaknesses:** access/licensing as above ★; U.S. station post-processing infrastructure (MOS/NBM) is built around U.S. models, so ENS's advantage at the Lab's target variable is an empirical question, not an assumption.
- **Lab role:** the natural "best available ensemble" benchmark _if_ access permits; otherwise the conceptual reference against which GEFS-based rungs are contextualized.

### 6.5 NAM — North American Mesoscale (NOAA/NCEP)

- **Configuration ★:** WRF-NMMB core; 12 km parent over North America with a 3 km CONUS nest ⚑; 4 cycles/day; horizon 84 h (parent) / 60 h (nest) ⚑.
- **Status ⚑★:** NAM has been in sustained-freeze/legacy status for years, with retirement long planned as the Rapid Refresh Forecast System (RRFS) matures. **Its current operational status must be verified before the Lab invests any collection effort**; a model in end-of-life freeze is a poor archive investment.
- **Strengths (historical):** long archive; mesoscale detail; an independent physics lineage from GFS (multi-model diversity).
- **Weaknesses:** frozen physics accumulating relative bias; superseded by HRRR/RRFS for most short-range uses.
- **Lab role:** minimal. Documented here mainly so its NBM membership and legacy MOS products are interpretable.

### 6.6 HRRR — High-Resolution Rapid Refresh (NOAA)

- **Configuration ★:** WRF-ARW core; **3 km** CONUS, convection-allowing (no deep-convection parameterization); **hourly** cycles; horizon 18 h (48 h at 00/06/12/18Z) ⚑; radar-reflectivity assimilation for storm-scale initialization.
- **Strengths:** the premier U.S. short-range model; hourly refresh gives it the freshest initial state of anything public; excels at diurnal detail, convective timing, terrain and coastal gradients — directly relevant to _day-of_ high-temperature evolution.
- **Weaknesses:** short horizon; single deterministic run (no operational ensemble at full scale — RRFS ensembles are the successor path ⚑); 3 km detail is _realistic-looking_ but not point-accurate (the "double penalty" problem, §17.1); succeeded operationally by RRFS on a timeline that must be verified ★.
- **Lab role:** high value for **day-of and day-before** bracket markets: hourly updated 2 m temperature guidance inside the market's trading window. A strong candidate for high-frequency snapshot collection precisely because its information arrives _during_ trading hours (§13).

### 6.7 RAP — Rapid Refresh (NOAA)

- **Configuration ★:** 13 km North America; hourly; horizon 21–51 h ⚑; the parent that provides boundary conditions and assimilation lineage for HRRR.
- **Lab role:** secondary; collect if cheap alongside HRRR, primarily for continuity and as HRRR's coarse prior. Same RRFS-succession caveat ★.

### 6.8 NBM — National Blend of Models (NOAA/NWS)

Summarized here for completeness; §11 is the extensive treatment.

- **Configuration ★:** statistically post-processed, bias-corrected super-ensemble blend of ~30+ model inputs (U.S. and international, deterministic and ensemble); ~2.5 km CONUS grid; hourly updates ⚑; horizon to ~10 days hourly/3-hourly and beyond in coarser steps ⚑; **probabilistic outputs including percentiles** for temperature.
- **Lab role:** arguably the single most important non-market data source for the Lab (§11.5, §15).

### 6.9 GDPS — Global Deterministic Prediction System (ECCC, Canada)

- **Configuration ★:** GEM dynamical core; ~15 km ⚑; 2 cycles/day (00/12Z); horizon 10 days. Companion GEPS ensemble (21 members ⚑).
- **Strengths:** genuinely independent physics/assimilation lineage — high value for multi-model diversity; open data via ECCC Datamart/HPFX ⚑.
- **Weaknesses:** generally behind ECMWF/GFS on U.S. station temperature after U.S.-centric post-processing ⚑; coarser cadence.
- **Lab role:** diversity input; NBM member; low-priority direct collection.

### 6.10 ICON — Icosahedral Nonhydrostatic (DWD, Germany)

- **Configuration ★:** icosahedral finite-volume nonhydrostatic global core; ~13 km global ⚑ with European nest(s); 4 cycles/day ⚑; horizon 7.5 days (main cycles) ⚑; open data since 2017 ⚑.
- **Strengths:** modern nonhydrostatic core; independent lineage; free.
- **Weaknesses:** post-processing ecosystem and verification literature for U.S. stations thinner than for U.S. models.
- **Lab role:** diversity/benchmark; candidate for cheap archival if bandwidth permits, otherwise deferred.

### 6.11 UKMO Unified Model (UK Met Office)

- **Configuration ★:** the Unified Model (seamless global/regional code); global ~10 km ⚑; MOGREPS-G ensemble (~18–36 members ⚑); strong verification pedigree, historically 2nd–3rd on global scores ⚑.
- **Weaknesses for the Lab:** data access is the binding constraint — historically licensed, with partial openings ⚑★; U.S. station relevance mediated mainly through its role as an NBM input and multi-model context.
- **Lab role:** contextual; verify access before any planning ★.

### 6.12 Comparative summary table (★ all figures)

|Model|Type|Grid|Cycles/day|Horizon|Access|Lab priority|
|---|---|---|---|---|---|---|
|GFS|Global det.|~13 km|4|16 d|Open (NODD)|High|
|GEFS|Global ens. (31)|~25 km|4|16–35 d|Open (NODD)|High|
|ECMWF HRES/ctrl|Global det.|~9 km|2(+2)|10 d|Partial/open subset ★|Medium ★|
|ECMWF ENS|Global ens. (51)|~9 km|2(+2)|15 d|Partial ★|Medium ★|
|HRRR|CAM det.|3 km|24|18/48 h|Open (NODD)|High (day-of)|
|RAP|Meso det.|13 km|24|~51 h|Open|Low–medium|
|NAM|Meso det. (legacy)|12/3 km|4|84 h|Open|Low ★ (EOL check)|
|NBM|Blend/post-proc|~2.5 km|24|~10 d+|Open|**Highest**|
|GDPS/GEPS|Global det./ens.|~15 km|2|10–16 d|Open|Low|
|ICON|Global det.|~13 km|4|7.5 d|Open|Low|
|UKMO/MOGREPS|Global det./ens.|~10 km|2–4|~7 d|Restricted ★|Contextual|

### 6.13 Reading model documentation: a field guide ★

Because §6's numbers decay, the durable skill is knowing where truth lives. For NCEP systems: the EMC model pages and, critically, the **Service Change Notices / Technical Implementation Notices** (SCN/TIN ⚑★) that announce every operational change with effective dates — these notices are the raw feed for the version changelog [D-WFM-4] and should be monitored (they are emailed/posted publicly ⚑). For ECMWF: the per-cycle IFS documentation (published at each cycle upgrade, e.g., "CY49R1" ⚑) plus the changes-to-the-forecasting-system pages. For the NBM: NWS product description documents and version release notes ⚑★. For DWD/ECCC/UKMO: respective open-data and model-change pages. Practice to adopt: when a collector is built, its spec cites the _specific documentation version and access date_ for every numerical assumption; when an SCN announces a change, an ADR-trivial changelog row is added _before_ the effective date. Model upgrades are scheduled, announced provenance breaks — the rare kind of data hazard that emails you in advance — and failing to log them converts a free provenance record into an archaeology project later.

---

## 7. Ensemble Systems

### 7.1 Why ensembles exist

Given chaos (§8), the honest forecast object is p(xt∣information at t0)p(x_t \mid \text{information at } t_0) p(xt​∣information at t0​) — a distribution. The distribution is analytically inaccessible, so operational centers approximate it by **Monte Carlo**: integrate the model mm m times from initial states sampled from analysis uncertainty, with model formulations sampled from model uncertainty. Epstein's stochastic-dynamic prediction (1969 ⚑) and Leith's Monte Carlo framing (1974 ⚑) supplied the theory; ECMWF and NCEP operationalized ensembles in 1992 ⚑; Leutbecher and Palmer (2008) is the standard modern review.

### 7.2 Initial-condition perturbations

The art is sampling the _right_ uncertainty: perturbations must (i) reflect actual analysis-error magnitude and structure, and (ii) project onto growing directions, or the ensemble under-disperses immediately. Historical lineages: **bred vectors** (NCEP, 1990s ⚑) — self-sustaining finite perturbations recycled through the model; **singular vectors** (ECMWF ⚑) — fastest-growing directions over an optimization window, computed with tangent-linear/adjoint machinery; **ensemble-DA perturbations** (the modern mainstream) — EnKF analysis members (NCEP) or an Ensemble of Data Assimilations (ECMWF), which sample assimilation uncertainty directly and consistently.

### 7.3 Model-error representation: stochastic physics

Initial-condition spread alone is insufficient because the model itself is wrong in state-dependent ways. Operational schemes inject stochasticity into the physics: **SPPT** (stochastically perturbed parameterization tendencies — multiplying total physics tendencies by a spatially/temporally correlated random field), **SKEB** (stochastic kinetic-energy backscatter), and **SPP** (stochastically perturbed parameters — randomizing uncertain parameters inside schemes) ⚑. Multi-physics and multi-model ensembles (different parameterization suites or entire models per member) achieve the same goal by discrete diversity — the NBM inherits this logic at the post-processing layer (§11).

### 7.4 Spread, and what it does and does not mean

Ensemble **spread** (member standard deviation) is the flow-dependent uncertainty signal. The **spread–skill relationship** is real but statistical: in a perfectly reliable ensemble, spread equals the RMSE of the ensemble mean _in expectation over many cases_ — it is not a per-case error guarantee (misconception §17.3). Spread predicts the _difficulty distribution_, not the individual miss. Verified properly via spread–error diagrams and rank histograms ([[Forecast Verification]] §12).

### 7.5 From members to probabilities

The naive bracket probability is the member fraction: p^(bracket)=1m∑i1{xi∈bracket}\hat p(\text{bracket}) = \frac{1}{m}\sum_i \mathbf{1}\{x_i \in \text{bracket}\} p^​(bracket)=m1​∑i​1{xi​∈bracket}. Three corrections are mandatory before such numbers are market-comparable: (i) **finite-mm m noise** — with 31 members, probability granularity is ~3.2 percentage points, and fair-score adjustments exist for verification (Ferro et al. 2008 ⚑); (ii) **bias** — the ensemble is centered on a biased model climate, so members need station-level bias correction first; (iii) **dispersion** — raw ensembles are underdispersive, so tail-bracket probabilities are systematically understated ⚑. The professional pipeline is members → bias correction → distribution fit / calibration (EMOS, quantile mapping, ML) → bracket integrals. The Lab should never put raw member fractions on the reference ladder as if they were calibrated probabilities; that layer distinction is load-bearing for A2.

### 7.6 Multi-model, lagged, and poor-man's ensembles

Ensembles need not come from one center's perturbation machinery. **Multi-model ensembles** pool distinct systems (GFS + ECMWF + ICON + GDPS …), converting inter-model structural diversity into spread; the TIGGE research archive ⚑ institutionalized this, and the NBM is operationally a bias-corrected multi-model ensemble in post-processing clothing. **Lagged ensembles** pool successive cycles of one system (the last kk k HRRR runs valid at the same target time) — free members at the cost of mixing information ages; time-lagged HRRR ensembles are standard nowcasting practice ⚑. **Poor-man's ensembles** — collections of available deterministic runs — historically rivaled formal ensembles at short range ⚑ precisely because model diversity attacks the error component (model error) that initial-condition perturbations miss. Lab relevance is direct and cheap: the Lab's archive of per-cycle station extracts (§14.4, items 4–5) _is_ the raw material for lagged and poor-man's ensembles at zero additional collection cost; whether such home-built ensembles calibrate into competitive bracket probabilities is a well-posed, registerable V2 question that requires only the collection discipline already proposed. Design note: correlation between members (shared observations, shared lineage — §17.5) means effective member counts are far below nominal counts; [[Effective Sample Size]] logic applies to ensemble members exactly as to city-days.

---

## 8. Forecast Uncertainty

### 8.1 Epistemic and aleatoric components

Using the Lab's standard decomposition ([[Probability]]): **epistemic** uncertainty — reducible in principle — enters through initial-condition error and model error; **aleatoric** uncertainty — irreducible relative to the information set — is enforced by chaotic error growth, which converts _any_ nonzero epistemic error into inevitable forecast divergence. The division is lead-time-dependent: at day 1 most 2 m temperature uncertainty is epistemic (model bias, boundary-layer representation); by day 10 chaos dominates and the forecast relaxes toward climatology. This gradient is why the Lab's reference ladder (climatology → NWS-derived model → market) is _lead-time indexed_: the achievable resolution of any forecaster decays toward the climatological rung as lead grows.

### 8.2 Chaos and the butterfly effect

Lorenz (1963) established sensitive dependence; Lorenz (1969) established the sharper, scale-dependent result: because small scales have fast error-doubling times and errors cascade upscale, **predictability has a finite horizon even with infinitesimally small initial errors** — perfect models and near-perfect observations do not yield unlimited forecasts. Canonical figures: synoptic-scale error-doubling ~1.5–2 days in modern systems ⚑; practical deterministic skill horizon for midlatitude synoptic patterns on the order of 10–14 days ⚑; convective-scale predictability measured in hours. Recent estimates suggest ~4–5 days of _potential_ further improvement remain before the intrinsic limit ⚑ (Zhang et al. 2019 ⚑).

### 8.3 The shape of error growth

Forecast error grows roughly exponentially at short leads (regime of linear perturbation dynamics), then saturates as errors reach climatological variance — at saturation the forecast is no better than a random draw from climatology. Two Lab-relevant corollaries. (i) **Value concentrates at short leads** for bracket-resolution temperature questions: the marginal information over climatology at day 8+ is small compared to day 1–3, so collection and modeling effort should be lead-weighted. (ii) **Uncertainty growth is itself flow-dependent** — blocking regimes, strong forcing, and quiescent ridges have very different predictability; a fixed lead-time error bar is a modeling convenience, not a truth. Ensembles exist to price this variation (§7.4), and _whether markets price it correctly is exactly the kind of question the Lab is built to answer._

---

## 9. Biases and Error Characteristics

> [!info] Standing discipline Bias claims below are _mechanism-level_ syntheses of the operational literature, useful as priors for what to look for. Their **magnitudes and signs at the Lab's five stations are empirical questions** the Lab's own archive must answer once the accrual clock runs. Nothing here should be treated as a quantified station-level bias; per house doctrine, disagreement with a model's climate is measured, not assumed. All ⚑.

### 9.1 Why model bias exists and persists

Bias is the systematic component of forecast error — the part that survives averaging. Its sources are structural: parameterization approximations (§2.2), unresolved terrain and land–water contrast, soil-moisture and land-surface state errors, and the representativeness gap between grid-cell means and point stations. Because the sources are design decisions, biases are **persistent within a model version and discontinuous across upgrades** — the fundamental reason forecast archives must be version-stamped (§15.6) and why statistical post-processing (MOS, NBM, the Lab's own calibration layer) works at all: a stable bias is a learnable bias.

### 9.2 Temperature biases

Recurrent mechanisms in 2 m temperature error, all lead- and regime-dependent ⚑:

- **Nocturnal stable boundary layers:** models systematically struggle with strong radiational-cooling inversions — commonly too-warm minima under clear calm conditions because parameterized turbulence over-mixes warm air downward. Affects daily-low markets more than highs, but morning-inversion erosion timing also shapes the daily high.
- **Diurnal cycle amplitude and timing:** errors in mixed-layer growth, entrainment, and cloud cover skew the _timing_ and level of the afternoon maximum — directly the Lab's settlement variable.
- **Cloud and radiation errors:** a missed stratus deck or an over-predicted cirrus shield translates directly into multi-degree max-temperature error; this is a leading day-of failure mode.
- **Soil moisture and land surface:** dry-biased soil pushes highs warm via Bowen-ratio shifts; irrigated or urban surfaces are poorly represented.
- **Snow cover edges** (Chicago, NYC winters): misplaced snow lines produce large, spatially coherent temperature busts.

### 9.3 Precipitation biases

Documented for completeness (temperature markets are the Lab's V1 target, but convection gates temperature): parameterized-convection models exhibit too-frequent light precipitation ("drizzle bias") and poor diurnal convection timing ⚑; convection-allowing models improve structure and timing but suffer the **double penalty** in point verification (§17.1). For Miami and Austin summers, whether afternoon convection fires _before or after_ the daily max is a bracket-deciding event that global models handle poorly and HRRR handles better ⚑.

### 9.4 Seasonal and regime dependence

Biases are conditional: warm-season vs. cold-season error regimes differ in magnitude and sign; transition seasons mix regimes; extreme tails (heat waves, cold outbreaks) have their own error structure, with models commonly under-amplifying extremes toward their own climate ⚑ — consequential for tail brackets, where the market's and the model's tail behavior diverge most. Any Lab bias model must therefore be at minimum season-stratified, and effective sample size per stratum collapses accordingly ([[Effective Sample Size]]).

### 9.5 Geographic mechanisms mapped to the five Lab cities

- **Phoenix (KPHX):** desert extreme-heat regime; dry-airmass diurnal amplitude is large and models under-resolve urban fabric and irrigation; monsoon-season (Jul–Sep) convection/outflow can cap highs unpredictably; UHI strongly affects _minima_; airport siting vs. urban core matters ⚑.
- **New York (KNYC — Central Park):** coastal gradient plus intense urban canopy plus a **park-interior station under tree canopy** — a famously idiosyncratic site whose micro-siting matters at bracket resolution; sea-breeze penetration caps summer highs; grid cells mixing land and water smear the signal ⚑.
- **Chicago (KMDW):** lake-breeze regime — Lake Michigan's cold water can slash a forecast high by many degrees if the breeze arrives early; snow-cover edges in winter; Midway's urban siting runs warmer than O'Hare ⚑.
- **Miami (KMIA):** maritime tropical regime with _narrow_ temperature climatology — brackets are tight, so degree-scale sea-breeze/convection timing errors dominate; daily-max variance is small, raising the premium on calibration over raw skill ⚑.
- **Austin (KAUS):** continental-subtropical; dryline and cold-front timing; summer heat domes with soil-moisture feedback; CT timezone settlement subtlety already logged as F3.

The general point: **the five cities were implicitly chosen across distinct error regimes** (desert, urban-coastal, lake-effect, maritime-tropical, continental-subtropical), so pooling across cities without stratification mixes different error-generating processes — an A1-relevant fact for inference design.

### 9.6 Representativeness: grid cell vs. station

A model's "2 m temperature at KNYC" is an area-average diagnostic over a cell (9–25 km for global models) interpolated to a point, over model terrain and model land cover that differ from reality. The gap between grid truth and station truth is not model _error_ strictly — it is **representativeness mismatch**, and it is the first thing post-processing removes. Implication: raw model values downloaded at station coordinates are _not yet forecasts of the settlement variable_; MOS/NBM/station-calibrated products are. The reference ladder's "NWS-derived model" rung already respects this; any future raw-model rung must include an explicit station-mapping layer, and that layer is a modeling decision to be registered, not an implementation detail.

### 9.7 How forecasters compensate

Operationally, bias is fought in layers: (i) MOS-style regression per station; (ii) NBM's rolling decaying-average bias correction against observations ⚑; (iii) human forecaster pattern knowledge ("HRRR too warm here under southeast flow") applied in the gridded forecast editor (§12); (iv) reforecast-calibrated products where long fixed-version archives exist. The Lab's edge hypothesis space lives largely in the residual: regime-conditional errors that _linear, unconditional, or slowly-adapting_ corrections leave behind — and that markets may or may not price.

### 9.8 Error correlation structure — the inference-relevant fact

Forecast errors are correlated along every axis the Lab's inference must respect. **Across models** (shared observations, assimilation heritage, physics lineages — §17.5): the effective number of independent forecasters in any multi-model comparison is far below the nominal count. **Across days** (synoptic regimes persist for days–weeks): a heat-dome week yields five Phoenix city-days whose errors share one cause; naive day-counting overstates evidence, the core [[Effective Sample Size]] concern already embedded in the city-day doctrine. **Across cities** (large-scale patterns span the CONUS): a continental airmass event correlates Chicago, Austin, and NYC errors on the same date, so the ~150 city-days/month are not 150 independent draws even across space. **Across leads** (a busted day-3 forecast usually busts day-2 and day-1 in attenuated form): lead-time curves are smooth functions of shared error, not independent measurements per lead. None of this is pathology — it is the physics — but it fixes the statistical ground rules: block/cluster-aware uncertainty estimates, regime stratification, and conservative effective-NN N accounting are not refinements to be added later; they are what makes any model-vs-market comparison at these sample sizes mean anything. This subsection exists to hand A1 its weather-specific requirements explicitly: **A1's inference framework must price spatial (cross-city), temporal (cross-day), and structural (cross-model) error correlation, and this document is the physical justification for why.**

---

## 10. Forecast Verification

This document defers verification theory wholesale to [[Forecast Verification]] and [[Proper Scoring Rules and Calibration - Technical Reference]]; here, only the model-facing summary needed to read the NWP literature.

- **Deterministic:** ME (bias), MAE, RMSE; for events, contingency-table scores. Consistent-scoring-function subtlety: which point summary a center's product represents (mean/median/mode) determines the fair error metric ([[Forecast Verification]] §2).
- **Probabilistic:** Brier score and decomposition (reliability/resolution/uncertainty), log score, **CRPS** (the meteorological standard for full-distribution temperature verification — and the natural score for bracket-ladder-integrated forecasts), reliability diagrams, rank histograms for ensembles, and **skill scores** against climatology (BSS, CRPSS).
- **Operational culture:** centers verify against both analyses (model-flavored; flattering) and station observations (independent; the Lab's standard). Headline "model X beats model Y" claims usually reference 500 hPa anomaly correlation over hemispheres ⚑ — a metric almost uncorrelated with _station bracket-probability skill in five specific cities_. The Lab must never import global-headline rankings as priors about its own micro-question without measurement; this is the model-selection analogue of "disagreement ≠ edge."

---

## 11. The National Blend of Models (NBM)

### 11.1 What it is

The NBM is the NWS's operational, nationally consistent, statistically post-processed **blend** of essentially the entire accessible model suite — U.S. deterministic and ensemble systems (GFS, GEFS, HRRR/RAP, NAM lineage, SREF/RRFS-era inputs), international models (ECMWF, CMC, and others as agreements permit ⚑), all bias-corrected against observations and combined into a single calibrated gridded product on a ~2.5 km CONUS grid, updated hourly ⚑★. Its institutional purpose: give WFO forecasters a scientifically defensible, calibrated _starting point_, replacing ad-hoc per-office model blending (§12).

### 11.2 Architecture and blending method ⚑

Mechanically (all ⚑ — the NBM's methodology documentation should be primary-source verified before load-bearing use): inputs are mapped to the common grid; each is **bias-corrected** using a decaying-average scheme against station observations and URMA (UnRestricted Mesoscale Analysis — the analysis-of-record the NBM trains toward ★, a fact with deep settlement-adjacent implications since URMA ≠ CLI settlement value); inputs are **weighted** by recent performance and combined; the blended distribution is expressed as deterministic fields _plus_ **percentile products** (e.g., 5th/10th/25th/50th/75th/90th/95th percentiles for temperature ⚑★).

### 11.3 Probabilistic products

The percentile suite is the headline for the Lab: it is an operational, freely available, hourly-updated, station-relevant **predictive distribution** for daily max/min temperature. From percentiles one can reconstruct an approximate CDF and integrate bracket probabilities directly — a full probability-ladder rung requiring zero atmospheric modeling by the Lab. Caveats: percentile-to-CDF interpolation is a modeling choice (registerable); calibration of NBM percentiles at specific stations is asserted by design but must be verified in the Lab's archive; tails beyond the outermost published percentiles require an explicit tail model — and tails are where Kalshi bracket ladders pay.

### 11.4 Known limitations ⚑

Blends inherit their members' blind spots on rare regimes; decaying-average bias correction lags regime shifts (heat-wave onsets — precisely the high-payoff bracket events); URMA-training vs. CLI-settlement mismatch injects a subtle target-variable gap; version upgrades (NBM v4.x era ⚑★) shift statistical character discontinuously.

### 11.5 Why NBM should become a key Lab rung

It is (i) the closest public object to "the calibrated consensus distribution," (ii) the actual starting point of the human NWS forecast the Lab already uses, (iii) hourly — matching market microstructure timing, and (iv) probabilistic natively. As a _reference ladder_ rung it sits naturally between the NWS-derived deterministic rung and any future Lab-built model: if a Lab model cannot beat bracket probabilities integrated from NBM percentiles, it has no business near a market. **Proposed for the roadmap: NBM percentile collection is the single highest-value non-market data stream not yet in the collection plan** — and it is not historically recoverable at full fidelity (§15.3), so it sits on the accrual clock.

### 11.6 Operational importance and institutional trajectory

The NBM's institutional weight is easy to underrate from outside. It is the designated convergence point of the NWS's forecast-process modernization: national consistency (adjacent WFOs no longer disagree across county lines by default), forecaster labor reallocation (from grid-editing routine days toward impact services), and a single calibrated substrate for downstream automation ⚑. Its trajectory has been steady version growth (v3.x → v4.x era ⚑★) with expanding elements, longer horizons, and more percentiles — and public statements of intent to make blend-first forecasting the norm ⚑. Two forward-looking Lab implications. First, **the official NWS forecast and the NBM are converging objects**: as human edits concentrate in fewer, higher-impact situations, the NWS rung's independent information relative to an NBM rung shrinks — measurable in the Lab's archive as the distribution of (NWS − NBM) differences over time, itself a publishable-grade monitoring series. Second, **NBM version upgrades are the largest single provenance risk** to a percentile-based rung: a v4→v5 change can shift tail calibration discontinuously, so the changelog discipline [D-WFM-4] and post-upgrade re-verification windows should be wired into the rung's standing methodology from day one, not retrofitted. If the Lab ever maintains exactly one model-side collector beyond the already-planned NWS forecast snapshots, it should be this one; §15's recommendations are ordered accordingly.

---

## 12. The National Weather Service Forecast Process

### 12.1 From guidance to official forecast

The official NWS forecast — the object behind the Lab's NWS-derived rung — is produced by human forecasters at 122 Weather Forecast Offices ⚑, each owning a County Warning Area. The modern workflow: the forecaster loads guidance (NBM first-guess grids since the blend era ⚑) into **GFE (Graphical Forecast Editor)** within AWIPS, edits gridded elements (temperature, PoP, sky, wind) where they believe guidance errs, and publishes to the **National Digital Forecast Database (NDFD)**, from which point-forecast products and the API responses the Lab collects are generated. Text products — including the **Area Forecast Discussion (AFD)**, where forecasters narrate their model reasoning and stated deviations from guidance — are issued alongside.

### 12.2 Issuance schedule and update dynamics ★

Standard practice: two main scheduled forecast packages daily (roughly early-morning and afternoon local time ⚑★ — exact per-WFO issuance times are a collector-design input that must be measured per office), with intermediate updates as conditions warrant. Grids may update between packages without a text issuance. **Dual-timestamp discipline is mandatory here:** an NDFD/API snapshot has an issuance time, a retrieval time, and per-element validity — conflating them corrupts latency analysis (§13).

### 12.3 Human value-added

The verification literature on human-over-guidance value is nuanced ⚑: forecaster edits add most value in (i) short leads, (ii) high-impact/unusual regimes, and (iii) known local model failure modes (lake breeze, sea breeze, inversions); at longer leads human edits increasingly track the blend. For the Lab this defines the _interpretation_ of the NWS rung: it is approximately "NBM + regime-conditional human corrections," and the AFD is free, structured-ish testimony about _when the human disagreed with the machine and why_ — a uniquely interesting future feature source (F-series candidate, V2+).

### 12.4 Relationship between raw models and the official forecast

The chain is: raw models → MOS/statistical guidance → NBM blend → human edit → NDFD official forecast → (separately) CLI settlement observation. Each arrow adds calibration and removes model idiosyncrasy. Market participants may trade off any layer; the Lab's rung structure should always name _which layer_ a probability came from — "the model says" is not a well-formed claim in this vault.

### 12.5 The Area Forecast Discussion as data

The AFD deserves its own note because it is the only place the forecast _process_ becomes text. Each WFO issues discussions (typically with each package, plus updates ⚑) containing: the forecaster's synoptic reasoning, explicit model comparisons ("the 12Z HRRR is 3 degrees warmer than the blend along the lakefront; leaned toward the cooler NBM given easterly flow"), stated confidence, and named local effects. As archive material it is: tiny (KB), textual, timestamped, and WFO-attributed. As research material it offers labels no numeric product carries — _when the human overrode the machine, in which direction, and citing what mechanism_. Candidate V2+ uses, all backlog-grade: classifying city-days by stated regime (sea-breeze / frontal / heat-dome) for stratified verification; measuring whether stated-low-confidence days coincide with wide NBM percentile spread and wide market spreads; testing whether explicit human-override days have different NWS-vs-NBM skill differentials. Collection cost is near zero and the text is imperfectly archived at update granularity elsewhere (§15.2), which is why AFDs make the archive list (§14.4, item 6) despite being a V2+ research object: cheap now, impossible later is the accrual-clock pattern in miniature.

---

## 13. Weather Models and Prediction Markets

### 13.1 The information-release clock

Weather markets differ from equity markets in one glorious respect: **the information schedule is largely public and periodic.** Model cycles (00/06/12/18Z), their staggered public dissemination (~1.5–5 h after cycle time depending on system ★), NBM hourly refreshes, NWS package issuances (twice daily local), and day-of observations (METARs at :51–:53 past each hour ⚑, 5-minute ASOS feeds) form a knowable clock of information injections. Each injection is a candidate event around which market prices should move if participants are attentive — and the Lab's snapshot cadence must be designed so that price behavior _around these times_ is resolvable. This is a direct requirement on Kalshi snapshot frequency: uniform coarse sampling aliases exactly the moments that matter.

### 13.2 Latency as the elementary information asymmetry

Between a model cycle's nominal time and full public availability lies a latency window in which no retail participant has the data; after publication, participants differ in _processing_ latency (automated GRIB parsing vs. reading a website hours later). The tradeable-in-principle asymmetries: (i) speed of ingesting new cycles/NBM refreshes; (ii) breadth (watching HRRR hourly when the market anchors on morning NWS packages); (iii) day-of observation tracking (intraday running max vs. remaining-day distribution). V1 measures whether such asymmetries even _appear_ as price-forecast divergence; nothing here licenses trading.

### 13.3 Market reaction hypotheses (open questions, not claims)

Candidate measurable phenomena for the Q-register: Do bracket prices reprice within minutes of NBM/model refreshes or drift slowly? Do markets overweight the deterministic GFS/ECMWF over ensemble/NBM distributions (a point-forecast anchoring bias)? Are tails systematically mispriced relative to NBM percentile tails? Does day-of repricing lag the observed running maximum? Each is a pre-registerable V2 study; none should be assumed. The honest prior from the microstructure literature ([[Market Microstructure]], [[Prediction Markets]]) is that thin markets can sustain sizeable divergence inside the dead zone where no one can profitably correct it — divergence ≠ edge, again.

### 13.4 Forecast revisions as signal

The _sequence_ of forecasts for a fixed target day — cycle-over-cycle revisions, "jumpiness," ensemble-spread contraction — carries information beyond the latest value (the forecast-revision literature; jump statistics ⚑). Markets may react to revisions (momentum) or to levels; distinguishing these is a natural V2 study and requires that the Lab archive **every cycle**, not just the latest — one more argument that forecast streams are accrual-clock data (§15).

### 13.5 A taxonomy of information advantage in weather markets

Organizing §13.2–§13.4 into the Lab's standard epistemics, a participant can hold at most four distinct advantage types, each with different durability and different V-stage relevance:

1. **Access latency** (having public data faster): structurally shrinking as cloud dissemination and ML inference democratize speed (§19.3); measurable in V1 as price-adjustment lag around release times; monetizable only in V3 and only if the dead zone doesn't swallow it.
2. **Breadth** (watching streams others ignore — NBM refreshes, HRRR cycles, day-of obs): the most plausible retail-scale asymmetry in thin weather markets ⚑; exactly what the Lab's multi-stream archive is built to detect.
3. **Calibration skill** (converting the same public distributions into better bracket probabilities — tail models, regime conditioning, station-specific corrections): the Lab's designated home turf (§20.2), durable because it compounds with archive length.
4. **Structural understanding** (settlement mechanics, F1/F3-class subtleties, bracket-boundary rounding): one-time informational rents that decay as markets mature but are nearly free to hold once documented — the Lab's F-findings are precisely this class.

The honest ordering of Lab effort is 4 → 3 → 2 → 1: cheapest and most durable first. Note what is _absent_: private observations, proprietary models, order-flow information — advantage classes the Lab neither has nor needs for its V1 mission, and whose absence keeps the measurement instrument honest (nothing the Lab measures depends on information the market could not, in principle, have had).

---

## 14. Research Lab Applications

### 14.1 Mapping models to Lab functions

|Lab function|Primary sources|Rationale|
|---|---|---|
|Reference ladder rung: NWS-derived (V1, existing)|NDFD/API official forecast|Already specified; calibrated, human-adjusted|
|Reference ladder rung: calibrated blend (proposed)|**NBM percentiles**|Native probabilistic; hourly; station-relevant (§11.5)|
|Future ensemble rung (V2+)|GEFS members (+ ECMWF ENS if access)|Genuine dynamical distribution; reforecast training data|
|Day-of nowcast features (V2+)|HRRR cycles + ASOS running obs|Freshest guidance inside trading window|
|Multi-model disagreement features|GFS vs. ECMWF vs. ICON vs. GDPS|Model spread as predictability signal|
|Regime stratification|Analyses (URMA/RTMA ⚑), synoptic indices|Conditioning variables for A1-compliant inference|
|Market-timing studies|All of the above + issuance timestamps|§13's event clock|

### 14.2 Feature engineering (V2+, gated)

Candidate feature families, listed for the backlog and _not_ as V1 scope: latest NBM percentile spread per city-day; cycle-over-cycle revision magnitude and direction; deterministic–ensemble-mean gap; multi-model range at the station; HRRR trend across the last kk k hourly cycles; days-since-regime-shift proxies; day-of running max vs. forecast max gap by hour. Every feature must be computable _from the archive as-of the decision timestamp_ — which is only possible if collection preserves full revision histories with dual timestamps. Feature engineering is downstream of archiving; archiving is upstream of everything.

### 14.3 Edge detection and forecast comparison

Per [[Edge Detection]], edge is population-level, cost-adjusted, out-of-sample skill against the market rung: DKL(q∥r)−DKL(q∥p)D_{\mathrm{KL}}(q\|r) - D_{\mathrm{KL}}(q\|p) DKL​(q∥r)−DKL​(q∥p) in the information formulation. Weather models enter as _candidate forecasters_ pp p on the ladder, and the ladder discipline generalizes: climatology → NWS official → NBM-integrated → ensemble-calibrated → (maybe, someday) Lab-hybrid. Each rung must beat the one below it, at the station, on bracket probabilities, before it earns attention against the market. Global headline skill (§10) buys a model nothing here.

### 14.4 Which products should be archived

Ranked by (irrecoverability × relevance ÷ cost) — the sequencing logic of Route B generalized:

1. **NBM percentiles + deterministic, 5 stations, hourly** — small, priceless, imperfectly recoverable ★.
2. **NWS official forecast snapshots (already planned)** — the existing rung's raw material.
3. **Kalshi snapshots (already planned)** — the market side; cadence informed by §13.1.
4. **GFS/GEFS station-extracted values** (2 m T, percentile-relevant members) per cycle — extract-at-collection to avoid archiving full GRIBs (§16.4).
5. **HRRR station-extracted hourly** — day-of studies.
6. **AFD text per WFO** — tiny, textual, future feature source.
7. Full GRIB regional tiles — only if storage economics permit; otherwise rely on public archives for _recoverable_ fields (§15.3).

### 14.5 A proposed future rung sequence (backlog, not commitment)

Synthesizing §6, §11, and the ladder discipline into a concrete audition order for model-side rungs beyond V1's existing pair (climatology; NWS-derived): **Rung candidate 3 — NBM-integrated**: bracket probabilities from NBM percentiles via a registered CDF-interpolation + tail convention; near-zero modeling risk, hourly cadence, the natural first extension (gated on [D-WFM-1] data existing). **Rung candidate 4 — GEFS-calibrated**: member extraction → station bias correction → EMOS-class calibration → bracket integrals; the first rung with genuine Lab modeling content, feasible once one-plus seasons of archive exist, with GEFS reforecasts ⚑★ as a training accelerant. **Rung candidate 5 — multi-stream hybrid**: NBM + GEFS + HRRR-lag features + day-of observations in a single calibrated model; the first rung that could plausibly embody advantage classes 2–3 of §13.5. Each candidate is a pre-registered forecaster in the [[Forecast Verification]] sense — registered from a date, scored from that date, compared under A1 rules — and each must beat the rung below at the station-bracket level before graduating. The sequence is deliberately ordered by _modeling risk_, not expected skill: the Lab climbs the ladder by adding one falsifiable layer at a time.

---

## 15. Data Collection Recommendations

### 15.1 The governing principle: irreversibility beats importance

Restated from the Lab's operational canon because it binds hardest here: **data that cannot be reconstructed later must be collected now; everything else can wait.** The accrual clock argument applies with full force to forecast streams — a missed NBM cycle for 2026-07-12 is gone in a way a missed climatology computation never is.

### 15.2 Recoverable vs. non-recoverable — the critical partition ★

**Generally recoverable later (lower urgency, verify per-source):** raw GFS/GEFS/HRRR GRIB2 output — archived publicly (NODD S3 buckets, NCEI archives ⚑★) with multi-year retention; ERA5 and other reanalyses; station observations (NCEI); CLI products (NWS archives ⚑ — F1 territory).

**Imperfectly or non-recoverable (accrual-clock data ★):**

- **NDFD/API official forecast snapshots at fine time resolution** — historical NDFD archives exist ⚑ but not at the Lab's desired snapshot cadence with retrieval timestamps.
- **NBM full percentile suites per hourly cycle** — archive completeness/fidelity uncertain ⚑★; treat as non-recoverable until proven otherwise.
- **Kalshi order-book/price snapshots** — categorically unrecoverable; already the Route B motivation.
- **Retrieval-time metadata itself** — _no public archive can ever supply the Lab's own dual timestamps_; as-of reconstruction ("what was knowable at time t?") requires having been there.
- **AFD intermediate updates** — text archives exist ⚑ but update-level completeness is unverified.

The partition, once verified per source (★, a bounded verification task), _is_ the collection priority order.

### 15.3 Concrete recommendations (proposed, pending Architect ratification)

- **[D-WFM-1, proposed]** Extend the collection plan with an NBM collector: hourly (or every cycle) retrieval of temperature percentiles + deterministic values for the five stations, dual-timestamped, append-only, raw payloads preserved.
- **[D-WFM-2, proposed]** All forecast collectors record: model/system name, **cycle time, issuance/publication time (if exposed), retrieval time**, model-version identifiers where available, station mapping method, and raw payload hash.
- **[D-WFM-3, proposed]** Station-extract at collection for GFS/GEFS/HRRR (values, not GRIBs) to keep storage O(KB/day); log source object keys so full fields remain recoverable from public archives if later needed.
- **[D-WFM-4, proposed]** Maintain a **model-version changelog table**: every known operational upgrade (model, assimilation, NBM version) with date and source link — the provenance spine for all longitudinal analysis.
- **[D-WFM-5, proposed]** Defer ECMWF collection until the open-data access question (★) is resolved by primary-source verification; do not architect around licensed data.

### 15.4 What not to collect

Full-resolution national GRIB archives (recoverable, enormous); radar; satellite imagery; anything without a named question or ladder rung attached. The archive is an instrument, not a hoard.

### 15.5 Cadence recommendations (proposed, ★ pending timing verification)

- **NBM:** every publication cycle if hourly collection is cheap (it is, at 5 stations); minimum viable: every 6 h aligned to synoptic cycles.
- **NWS official forecast:** existing plan governs; ensure snapshots bracket the two daily package issuances per WFO (measure actual issuance times per office for two weeks before freezing the schedule ★).
- **GFS/GEFS extracts:** once per cycle (4×/day), after verified availability time for the target-day forecast hours.
- **HRRR extracts:** hourly during the target day's local morning-through-max window at minimum; full 24×/day if trivial.
- **Kalshi snapshots:** cadence rules live in the market-collection spec; §13.1's requirement — densify around known release/issuance times — should be passed to that spec as a proposed amendment rather than duplicated here (single-home).
- **AFDs:** poll per WFO at ~15–30 min granularity or via product-feed push if available ⚑; store every distinct issuance.

### 15.6 Provenance and versioning requirements (restated as collection requirements)

Every stored forecast row carries: source system, cycle time (UTC), availability/publication time when observable, retrieval time, station mapping method + version, parser version, raw payload reference, and — via the changelog table [D-WFM-4] — resolvable model/system version. A row that cannot answer "what version of what system produced you, and when could the world first have known you?" is not evidence-grade; it is trivia.

---

## 16. Computational Considerations

### 16.1 Formats: GRIB2 and NetCDF

**GRIB2** (WMO binary, table-driven, per-message 2D fields, ~internally compressed) is the operational dissemination standard for every model in §6; **NetCDF** is the research/archive format (self-describing, multidimensional). Python stack: `cfgrib`/`eccodes` or `pygrib` for GRIB2; `xarray` as the common frame; **Herbie** ⚑ as the de-facto convenience library for locating and _partially downloading_ NOAA model output from cloud archives. The killer efficiency feature: GRIB2 messages are indexed (`.idx` sidecar files on NODD ⚑★), enabling **HTTP byte-range requests for single fields** — 2 m temperature for one cycle is a few-MB download from a multi-GB file, and station extraction reduces it to bytes stored.

### 16.2 Access paths ★

Preferred order for NOAA data: (1) **NODD cloud mirrors** (AWS S3 anonymous access ⚑★ — verify bucket names/retention per model); (2) NOMADS (rate-limited, historically fragile under load ⚑); (3) NCEI for deep archives. NBM and NDFD have dedicated distribution points ⚑★ (verify). ECCC Datamart and DWD open-data servers for GDPS/ICON. All collector implementations must respect rate limits and implement retry-with-backoff — NOMADS bans aggressive clients ⚑.

### 16.3 Storage arithmetic

Order-of-magnitude, station-extraction strategy: 5 stations × ~10 sources/cycles-streams × O(10–100) values × O(10¹–10²) bytes ≈ **KB–MB per day** — SQLite-trivial, dwarfed by Kalshi snapshots. Full-GRIB alternative: GFS alone is O(10⁰–10¹) GB/cycle ⚑ → TB/month; rejected for V1 by [D-WFM-3]. The asymmetry is the whole argument: extract-at-collection buys ~6 orders of magnitude.

### 16.4 Parsing and reliability engineering

GRIB2 parsing is the fragile joint: table versions, ensemble-member encoding, and local-use sections vary by center. Mitigations: pin `eccodes` versions; store raw payload bytes (or byte-ranges) alongside parsed values so parsing is re-runnable; unit-test parsers against golden files per model; alarm on schema drift (a new GRIB template is a provenance event). Timezone discipline: **all model times are UTC**; settlement days are local (F3, Austin CT) — the UTC↔local mapping layer must be tested at DST transitions explicitly.

### 16.5 Scheduling and reliability engineering for forecast collectors

Forecast collection differs from market collection in one structural way: **the sources are periodic but jittery**. Publication times drift by minutes to tens of minutes cycle-to-cycle ⚑; occasional cycles are late, partial, or (rarely) missing entirely; upstream maintenance windows exist. Design consequences, phrased as practices rather than directives (the Engineering Playbook owns the general patterns): poll-with-patience rather than fixed-instant fetch — attempt from the earliest plausible availability time, retry on a backoff schedule, and record _when the product actually appeared_ (the availability timestamp is itself research data for §13); treat a missing cycle as a first-class logged event with an alert (ntfy.sh per existing practice), never a silent gap, because gap structure must be distinguishable from source outage vs. collector failure at analysis time; idempotent inserts keyed on (source, cycle, station, element) so retries and catch-up runs cannot double-write the append-only store; and a small daily completeness report (expected vs. received cycles per stream) as the standing instrument check — the collector is a measurement instrument and gets instrument-validation treatment like everything else in the Lab ([[Forecast Verification]] §1.5's validation ordering applied to plumbing).

### 16.6 Bandwidth and cost envelope

At the station-extraction strategy [D-WFM-3], the entire §15.5 cadence plan consumes: byte-range GRIB requests of O(MB) per cycle across a handful of streams → **tens to low hundreds of MB/day of transfer, KB–MB/day of storage** — comfortably inside a residential connection and a laptop-class SQLite file, with no cloud spend required. The design point worth stating explicitly: the Lab's forecast-side data plan is deliberately shaped so that _cost can never be the reason collection stops_. The accrual clock's enemy is interruption; the cheapest defense is an architecture whose steady-state cost rounds to zero.

---

## 17. Common Misconceptions

### 17.1 "The highest-resolution model is always best"

False. Resolution buys realistic _structure_, not point accuracy; convection-allowing models suffer the **double penalty** (a realistic feature displaced 20 km scores worse than a smooth blur) ⚑, and at station scale a well-calibrated coarse blend (NBM) routinely beats raw 3 km output. Resolution is about representing physics, not about verification scores at points.

### 17.2 "Deterministic forecasts are more accurate than ensembles"

Category error. A deterministic run is _sharper-looking_, but the ensemble mean has lower average error at medium range, and for probability questions — the Lab's only questions — a point forecast is not even the right _type_ of object. Sharpness without calibration is confidence, not skill ([[Proper Scoring Rules and Calibration - Technical Reference]]).

### 17.3 "Ensemble spread equals forecast error"

Spread is a _forecast of_ error, valid in expectation over populations for a reliable ensemble — not a per-case guarantee, and raw operational ensembles are systematically underdispersive besides (§7.5). Per-case identification of spread with error is the ensemble analogue of grading a probability on one outcome.

### 17.4 "The official NWS forecast just copies one model"

False. The chain is blend-of-~30-inputs → bias correction → human regime-conditional edits (§12). Treating the NWS rung as "basically the GFS" misattributes its error structure and would corrupt any divergence analysis built on that assumption.

### 17.5 "Model agreement guarantees correctness"

Models share observations, assimilation heritage, and parameterization lineages; their errors are **positively correlated**, so agreement is weaker evidence than independence would suggest ⚑. Multi-model consensus can converge confidently on a shared bust (classic in cut-off lows and stable-layer events ⚑). In ladder terms: consensus tightness is a feature, not a verdict.

### 17.6 "More data (or a better model) will eventually make forecasts exact"

Lorenz closed this door (§8.2): the predictability horizon is intrinsic. All improvement is asymptotic approach to a finite wall — which is precisely why probabilistic markets on weather can exist in permanent equilibrium rather than being arbitraged to determinism.

### 17.7 "A forecast that changed was a forecast that was wrong"

Forecast revisions are the _system working_: each cycle assimilates new observations, and the optimal estimate moves. Jumpiness can indicate low predictability, but a revised forecast is not an admission of error any more than a Bayesian posterior update is — and markets (or analysts) that penalize revision per se are measuring temperament, not skill. The proper evaluation of a forecast _sequence_ is population-level scoring at each fixed lead, separately ([[Forecast Verification]]); the revision process itself is a feature stream (§13.4), not a verdict.

### 17.8 "Verification proves which model is best"

Verification estimates skill differences _with uncertainty_, on finite, autocorrelated, regime-mixed samples. City-day counts in the low hundreds resolve only large skill gaps ([[Effective Sample Size]]; [[Forecast Verification]] §17's power arithmetic); seasonal stratification shrinks strata further. "Model A beat model B last month" is, at the Lab's sample sizes, usually a statement about noise. The Lab's defense is the standing one: pre-registered comparisons, A1-governed inference, and patience denominated in city-days — the same discipline applied to models as to edge claims, because a model ranking _is_ an edge claim about forecasters.

---

## 18. Research Lab Integration

How this document supports each neighboring canonical document — references, not duplications (single-home convention):

- **[[National Weather Service]]:** that document owns the settlement chain (CLI products, F1) and the NWS _institutional_ description; this document supplies the upstream generative story — where the official forecast's information comes from (guidance → NBM → human edit, §12) — so that the NWS rung's error structure is interpretable rather than opaque.
- **[[NOAA]]:** organizational context for NCEP/EMC/NCEI/NODD; this document is the technical companion detailing what those units actually produce.
- **[[Forecast Verification]]:** owns all scoring theory. This document supplies the _objects to be scored_ and their generation-side error mechanisms; §9–§11 here explain _why_ the reliability/resolution structure that verification measures exists.
- **[[Proper Scoring Rules and Calibration - Technical Reference]]:** owns propriety and calibration theory; §7.5 and §11.3 here are its raw-material inventory — which operational products arrive pre-calibrated (NBM, by design claim) versus requiring the Lab's own calibration layer (raw ensembles).
- **[[Probability]] / [[Bayesian Statistics]]:** data assimilation (§4) is the field's grandest operational Bayesian update; ensemble forecasting (§7) is operational Monte Carlo; the epistemic/aleatoric split (§8.1) instantiates the vault's uncertainty taxonomy in a physical system.
- **[[Prediction Markets]] / [[Market Microstructure]]:** those documents own price interpretation and the dead zone; §13 here supplies the _information-arrival clock_ that market-timing analyses will condition on.
- **[[Edge Detection]]:** owns the definition of edge; §14.3 here disciplines which forecasters may even audition, via the extended ladder.
- **Market normalization (A4 scope):** bracket probabilities integrated from NBM percentiles or ensemble members give the _model side_ of every normalized comparison; the percentile-to-CDF and tail-model choices flagged in §11.3 are A4-adjacent registerable conventions.
- **[[Information Theory for Forecasting]]:** predictability limits (§8) are statements about mutual information between initial states and future states decaying with lead time; the KL formulation of edge prices exactly the information a forecaster adds over the ladder rung below.

---

## 19. Current Research Frontiers

### 19.1 The ML weather-prediction inflection

Between 2022 and 2025 machine-learned global forecasting moved from curiosity to operational reality — the fastest paradigm shift in the field since ensembles. Landmarks (all ⚑ on details):

- **FourCastNet** (NVIDIA + collaborators, 2022 ⚑): Fourier-neural-operator global model; first to show competitive-with-NWP skill at a fraction of inference cost.
- **Pangu-Weather** (Huawei, 2023, _Nature_ ⚑): 3D transformer; matched/exceeded IFS HRES on many deterministic headline metrics.
- **GraphCast** (Google DeepMind, 2023, _Science_ ⚑): graph neural network on an icosahedral mesh, 0.25°, trained on ERA5; broadly exceeded HRES deterministic scores at ~1 minute inference.
- **NeuralGCM** (Google, 2024, _Nature_ ⚑): _hybrid_ — a differentiable dynamical core with learned physics; competitive weather skill plus stable long climate runs, the strongest argument that physics+ML hybrids, not pure ML, may be the endgame.
- **GenCast** (DeepMind, 2024–2025, _Nature_ ⚑): diffusion-based **probabilistic** ML forecasting; ensemble-like samples reported to beat ECMWF ENS on most evaluated CRPS targets ⚑ — the first ML system to claim the _probabilistic_ crown, which is the Lab-relevant crown.
- **Operational adoption:** ECMWF's **AIFS** (its own ML forecasting system) declared operational alongside IFS in 2024–2025 ⚑★; ensemble AIFS variants in development/operations ⚑★. Verify current status before citing.

Structural notes: these models are (i) trained on **ERA5 reanalysis**, inheriting its biases and resolution ceiling; (ii) dependent on conventional data assimilation for initial conditions — DA is now the moat; (iii) cheap at inference, which democratizes _running_ forecasts and may compress the latency asymmetries in §13.2; (iv) still maturing on extremes, tails, and physical consistency ⚑ — exactly the regions bracket markets price.

### 19.2 Adjacent frontiers

**ML ensemble post-processing/calibration** (distributional regression networks, quantile transformers ⚑) — the frontier _most directly usable by the Lab_, since it operates on public model output at laptop scale. **ML/hybrid data assimilation** and end-to-end obs-to-forecast learning ⚑ — early. **Km-scale global modeling** (ICON/IFS at 1–5 km demonstrations ⚑) — the brute-force counterpoint.

### 19.3 Implications for Lab architecture

Three planning consequences. (1) **Provenance turbulence:** the model landscape will churn faster than any prior decade; the version-changelog discipline [D-WFM-4] is not optional. (2) **Optionality favors the calibration layer:** the Lab's durable comparative advantage cannot be running atmospheric models — it is measurement, calibration, and market comparison, layers that survive whichever generative engine wins. (3) **Cheap inference may thin the edge:** if calibrated ML distributions become ambient, weather markets may sharpen; V1's measurement mission is unaffected (divergence is measurable whether large or small), but V2+ edge priors should assume a hardening field.

### 19.4 A watchlist, not a bet

Concrete monitoring items with cheap observables, so frontier-tracking stays bounded: (i) **AIFS ensemble operational status and open-data availability** ⚑★ — if calibrated ML ensemble percentiles become freely available at station scale, they are an instant ladder-rung candidate; (ii) **RRFS cutover** replacing HRRR/RAP/NAM lineage ⚑★ — a scheduled provenance break for any short-range collector; (iii) **NBM major versions** ⚑★ — as §11.6; (iv) **GenCast-class probabilistic ML products** appearing in public pipelines ⚑; (v) **ECMWF open-data scope changes** ⚑★. Each item is a changelog-row-plus-possible-ADR event, not a re-architecture; the design defense against frontier churn was already stated (§19.3): keep the Lab's value in measurement and calibration layers that are indifferent to which engine generated the distribution.

---

## 20. Engineering Takeaways

1. **Forecasts are pipeline products, not oracle outputs.** Every number the Lab ingests is the tail of observations → QC → assimilation → integration → post-processing → (sometimes) human edit. Name the layer or the claim is ill-formed.
2. **The probabilistic layer is the Lab's layer.** Raw models make scenarios; calibration makes probabilities; markets price probabilities. The Lab competes at calibration and measurement — never at atmospheric simulation.
3. **NBM percentiles are the highest-value uncollected stream.** Hourly, probabilistic, station-relevant, imperfectly recoverable: accrual-clock data. Proposed [D-WFM-1].
4. **Extract-at-collection, preserve raw payloads, dual-timestamp everything.** KB/day instead of TB/month, with re-parseability and as-of reconstruction preserved. [D-WFM-2], [D-WFM-3].
5. **Version-stamp the world.** Model, assimilation system, NBM version, parser version: biases are stable _within_ versions and break _across_ them. [D-WFM-4].
6. **Verify specifications before dependence.** Every number in §6 is a ★ placeholder; NAM/RRFS status, ECMWF open-data scope, NBM product details, and publication timing are the priority verification queue. [D-WFM-5].
7. **Global headline skill is not station bracket skill.** Import no model rankings without local measurement; ladder discipline governs auditions.
8. **The information clock is a design input.** Snapshot cadences must resolve model-release and issuance times, or the market-reaction questions of §13 become unanswerable retroactively.
9. **Stratify by regime and city; respect effective sample size.** Five cities were five error regimes before they were five ticker series.
10. **Plan for churn.** ML models, RRFS transition, NBM upgrades: architecture should assume the forecast landscape of 2028 looks unlike 2026's, and keep the Lab's value in the layers that survive that.

---

## 21. Annotated Bibliography

> [!warning] Verification note (Invariant 3) All entries drafted from model knowledge; titles, years, venues unverified. ★ = priority tier (feeds collector design or A-series decisions). Ranked within tiers by long-term study value.

### Tier 1 — Foundational works

1. **Richardson, L.F. (1922), _Weather Prediction by Numerical Process_, Cambridge UP.** The founding document; the failure analysis (initialization, stability) remains pedagogically unmatched. Read for the shape of the problem, not methods.
2. **Lorenz, E.N. (1963), "Deterministic Nonperiodic Flow," _J. Atmos. Sci._ 20:130–141.** Chaos; the paper that makes the Lab's probabilistic framing physically mandatory. ⚑ page range.
3. **Lorenz, E.N. (1969), "The predictability of a flow which possesses many scales of motion," _Tellus_ 21:289–307 ⚑.** The intrinsic-limit argument; the deeper of the two Lorenz results for forecasting.
4. **Charney, Fjørtoft & von Neumann (1950), "Numerical Integration of the Barotropic Vorticity Equation," _Tellus_ 2:237–254 ⚑.** The first successful NWP; historically load-bearing.
5. **Kalnay, E. (2003), _Atmospheric Modeling, Data Assimilation and Predictability_, Cambridge UP.** ★ The single best one-volume technical treatment of §2–§8; the default deep-reference behind this document.
6. **Bauer, P., Thorpe, A. & Brunet, G. (2015), "The quiet revolution of numerical weather prediction," _Nature_ 525:47–55.** ★ The modern synthesis; the non-stationarity-of-skill citation.
7. **Wilks, D.S. (2019), _Statistical Methods in the Atmospheric Sciences_, 4th ed., Elsevier.** ★ The bridge text between meteorology and the Lab's statistical machinery; owns MOS, verification, and ensemble post-processing chapters.
8. **Stensrud, D.J. (2007), _Parameterization Schemes_, Cambridge UP ⚑.** Why model bias exists, mechanism by mechanism; the §9 reference.

### Tier 2 — Ensembles and predictability

9. **Leutbecher, M. & Palmer, T.N. (2008), "Ensemble forecasting," _J. Comput. Phys._ 227:3515–3539 ⚑.** ★ The canonical ensemble review: perturbations, stochastic physics, interpretation.
10. **Buizza, R. et al. (2005), "A comparison of the ECMWF, MSC, and NCEP global ensemble prediction systems," _Mon. Wea. Rev._ 133:1076–1097 ⚑.** The template for multi-ensemble comparison studies — methodologically instructive for ladder design.
11. **Palmer, T.N. (2019), "The ECMWF ensemble prediction system: looking back (more than) 25 years and projecting forward 25 years," _QJRMS_ ⚑.** History + philosophy of operational probabilism.
12. **Gneiting, T., Raftery, A.E. et al. (2005), "Calibrated probabilistic forecasting using ensemble MOS…," _Mon. Wea. Rev._ 133:1098–1118 ⚑; and Raftery et al. (2005) on BMA, _Mon. Wea. Rev._ 133:1155–1174 ⚑.** ★ The two founding ensemble-calibration papers; direct methodological ancestors of any Lab calibration layer.
13. **Zhang, F. et al. (2019), "What is the predictability limit of midlatitude weather?" _J. Atmos. Sci._ ⚑.** The modern quantification of the Lorenz wall.

### Tier 3 — Operational systems documentation ★

14. **NCEP model documentation pages (GFS, GEFS, HRRR, RAP, NAM) and EMC implementation notices.** ★ The primary sources for every §6 number; implementation notices are the version-changelog feedstock for [D-WFM-4].
15. **NWS NBM documentation (v4.x descriptions, product guides) ⚑★.** The §11 primary source; required reading before the NBM collector spec.
16. **ECMWF IFS documentation (per-cycle scientific documentation) and open-data terms ⚑★.** Settles the access question [D-WFM-5].
17. **WMO Guide to the Global Observing System / Manual on the GDPFS ⚑.** The institutional map of §3.
18. **Benjamin, S. et al. (2016), "A North American hourly assimilation and model forecast cycle: the Rapid Refresh," _Mon. Wea. Rev._ 144:1669–1694 ⚑.** RAP/HRRR lineage paper.
19. **Glahn, H.R. & Lowry, D.A. (1972), "The use of Model Output Statistics (MOS)…," _J. Appl. Meteor._ 11:1203–1211 ⚑.** The founding post-processing paper; conceptual ancestor of NBM and of the Lab's own calibration ambitions.

### Tier 4 — AI weather forecasting

20. **Lam, R. et al. (2023), "Learning skillful medium-range global weather forecasting" (GraphCast), _Science_ 382:1416–1421 ⚑.** ★ The deterministic-ML watershed.
21. **Price, I. et al. (2024/2025), "Probabilistic weather forecasting with machine learning" (GenCast), _Nature_ ⚑.** ★ The probabilistic-ML watershed — the one most relevant to a probability-trading Lab.
22. **Kochkov, D. et al. (2024), "Neural general circulation models for weather and climate" (NeuralGCM), _Nature_ ⚑.** The hybrid thesis.
23. **Pathak, J. et al. (2022), "FourCastNet…," arXiv ⚑.** Historical first mover.
24. **Bi, K. et al. (2023), "Accurate medium-range global weather forecasting with 3D neural networks" (Pangu-Weather), _Nature_ 619:533–538 ⚑.** The result that forced operational centers to respond.
25. **ECMWF AIFS documentation/announcements ⚑★.** Operational-status ground truth for §19.1.

### Tier 5 — Post-processing, verification bridges, and market-adjacent

26. **Gneiting, T. & Raftery, A.E. (2007), "Strictly proper scoring rules, prediction, and estimation," _JASA_ 102:359–378.** Owned by [[Proper Scoring Rules and Calibration - Technical Reference]]; listed here as the bridge every model comparison in this document ultimately stands on.
27. **Hamill, T.M. et al. (2013), "NOAA's second-generation global medium-range ensemble reforecast dataset," _BAMS_ ⚑; and GEFSv12 reforecast documentation ⚑★.** Reforecasts are the training-data key for serious calibration work; these are the primary descriptions.
28. **Vannitsem, S., Wilks, D.S. & Messner, J.W., eds. (2018), _Statistical Postprocessing of Ensemble Forecasts_, Elsevier ⚑.** ★ The one-volume treatment of the layer the Lab actually competes in; the practical companion to entries 12 and 19.
29. **Hamill, T.M. (2001), "Interpretation of rank histograms for verifying ensemble forecasts," _Mon. Wea. Rev._ 129:550–560 ⚑.** The cautionary classic on over-reading ensemble diagnostics; pairs with §17.3.
30. **Murphy, A.H. (1993), "What is a good forecast? An essay on the nature of goodness in weather forecasting," _Wea. Forecasting_ 8:281–293.** Consistency/quality/value; the conceptual frame under §14.3's insistence that quality claims and value claims are different claims.

---

> [!info] Single most important takeaway **A weather forecast is not a fact about the future; it is the output of a specific, versioned, biased, latency-bound industrial pipeline — and every layer of that pipeline (raw model, ensemble, blend, human edit) is a different forecaster that must be named, archived with dual timestamps, and graded on populations like any other.** The Lab's advantage will never come from running the atmosphere; it comes from measuring, at the station and bracket level, what each layer of this pipeline knows that the market hasn't priced — and the data required to ever answer that question is accruing (or failing to accrue) right now.

_— End of document. E4 pending Architect verification per Invariant 3._