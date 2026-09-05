# Auditory stochastic resonance during standing

MATLAB and R research code for analysing centre-of-pressure (CoP), surface
electromyography (EMG), muscle-to-sway coherence and intermuscular coherence
during quiet standing with rhythmic auditory stimulation and white noise.

The study investigated whether sub-threshold auditory noise could modify
postural control while healthy young adults stood with their eyes closed on
hard or compliant surfaces.

## Associated research

The directly associated peer-reviewed conference abstract is:

> N. B. Singh, F. Riner, N. König and W. R. Taylor, “Can auditory stochastic
> resonance enhance standing balance?”, *XXVI Congress of the International
> Society of Biomechanics*, Brisbane, Australia, 2017.

The abstract is available in the
[ISB 2017 abstract book](https://isbweb.org/images/conferences/isb-congresses/2017/ISB2017-Full-Abstract-Book.pdf).

The source export also contains a later manuscript entitled *Can auditory
stochastic resonance modify intermuscular coherence during standing? A
proof-of-concept validation study*. No journal article, DOI or public preprint
for that manuscript was found during this release review, so it is not cited as
a publication. The manuscript itself is not included in this code repository.

## Release scope

This public release contains the study entry points, custom processing helpers,
statistical scripts and two development checks. It deliberately excludes raw or
processed participant data, generated figures and tables, manuscripts,
presentations, R workspaces, archives, and bundled copies of external toolboxes.

The repository is therefore a reviewed source-code record, not a self-contained
reproduction package. The later manuscript states that raw data cannot be made
public because of participant privacy and institutional ethics restrictions,
but may be requested from the corresponding author.

## Experimental labels used by the code

- `S01_notrigger` — eyes closed, hard surface
- `S02_notrigger` — eyes closed, compliant surface
- `S03_neutral` — eyes closed, compliant surface and 1 Hz stimulation
- `S03_auditory` — the same task with auditory white noise
- `S03_vibratory` — vibratory-noise condition retained in parts of the code
- `S04_notrigger` — additional no-trigger condition retained in parts of the code

The later manuscript describes 30 healthy young adults. The 2017 conference
abstract describes 26 recruited participants, indicating that the analysis
cohort or study version changed. Confirm the intended cohort and exclusions
before reproducing any reported result.

## Repository layout

- `SR_1_DataProcess.m` — trial-level CoP/EMG loading and feature extraction
- `SR_2_CoPEMG.m` and `SR_2_interEMG.m` — coherence pooling
- `SR_3_PooledFinalCOP.m` and `SR_3_PooledFinalEMG.m` — final coherence plots
- `SR_4_TimeVaryingCoherence*.m` — experimental time-varying analysis
- `01_Functions/` — study-authored processing, pooling and plotting helpers
- `02_Statistic_analysis/` — MATLAB preparation and R mixed-effects analyses
- `03_UnitTest/` — two development checks using synthetic/example signals

The filenames suggest a nominal order, but the exported entry points do not
currently form an uninterrupted executable pipeline. Read
[`RELEASE_REVIEW.md`](RELEASE_REVIEW.md) before configuring a working copy.

## Requirements

- MATLAB, including Signal Processing Toolbox functions used by the selected
  analyses
- R and the packages listed in `R-packages.txt`
- [NeuroSpec](https://github.com/dmhalliday/NeuroSpec) for spectral and pooled
  coherence routines
- [FieldTrip](https://www.fieldtriptoolbox.org/) for the power-line filtering
  routine called by `emgbandpass.m`
- [spm1d for MATLAB](https://spm1d.org/DocumentationMatlab.html) for the
  preparation plots that call `spm1d.plot`
- [Biomechanical ToolKit](https://biomechanical-toolkit.github.io/docs/) only if
  starting from C3D files rather than the expected converted MAT files

External projects are not vendored here. See `DEPENDENCIES.md` for details.

## Reproducibility status

The release has been checked for participant datasets, generated results,
compiled binaries, oversized files and obvious credentials. MATLAB and R were
not available in the release environment, and the private study data were not
used, so the complete scientific workflow has not been executed.

Known execution and analysis concerns are documented in
[`RELEASE_REVIEW.md`](RELEASE_REVIEW.md). They were not silently fixed because
several affect cohort selection, transformations, model interpretation or
published outputs.

## Citation

If this code supports your work, cite the ISB 2017 conference abstract above.
`CITATION.cff` provides machine-readable metadata.

## Licence

No open-source licence has been selected for the study-authored code. Until the
copyright holders add one, default copyright restrictions apply. External
dependencies remain governed by their own licences.

## Contact

For questions about this code release, contact Yong Kuk Kim.
