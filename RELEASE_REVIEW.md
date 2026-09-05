# Pre-release review

The following points were found during static inspection. They are documented
instead of being silently changed because several could alter the participant
set, transformations, model specification or reported outputs.

## High-priority execution and scientific points

1. **The numbered scripts do not currently form a complete pipeline.**
   `SR_1_DataProcess.m` has the EMG-EMG and CoP-EMG output accumulation and
   confidence-limit saves commented out. `SR_2_CoPEMG.m` nevertheless expects
   `coherence.csv` and `copemgcoherencecl.mat`; `SR_2_interEMG.m` expects an
   Excel workbook and EMG-EMG MAT files. Establish which historical entry point
   generated the manuscript inputs before treating the numbering as executable.
2. **The CoP spectra save loop references the wrong structure.** At the end of
   `SR_1_DataProcess.m`, `window_index` is taken from the unpopulated
   `MatrixTableemgspectra` instead of the populated `MatrixTablecopspectra`.
   Consequently, the intended CoP spectra files are not written by this export.
3. **The time-varying computation is not self-contained.**
   `SR_4_TimeVaryingCoherenceCompute.m` relies on workspace variables such as
   `emgByCondition` and `DIR_destPath`, uses undefined `seg_size` and `Fs`, and
   therefore cannot run from a clean MATLAB session as written.
4. **Missing data can bias the time-varying average.** Participants without a
   condition are skipped, but accumulated coherence is divided by the total
   number of participants. Short signals also leave zero-filled segments that
   are retained in the average. Count valid observations per condition and
   segment explicitly.
5. **Two final plotting scripts reference undefined axes.**
   `SR_3_PooledFinalCOP.m` sets `ax1.YLim` before assigning an axes handle, and
   `SR_3_PooledFinalEMG.m` assigns `ax1 = gca` but then sets ticks through the
   undefined variable `ax`.
6. **Cohort definitions require provenance.** `SR_2_CoPEMG.m` removes 11 named
   participant IDs as an extreme coefficient/low-sway group. The later
   manuscript describes 30 participants and 20 SR responders, whereas the 2017
   conference abstract describes 26 recruited participants. Record which cohort
   and exclusion rule produced each reported analysis.

## Reproducibility and interpretation points

7. **Paths are machine-specific.** MATLAB and R entry points contain ETH network
   paths and personal macOS paths. The R Windows branches in the CoP scripts do
   not define every later-used input path. Move configuration to explicit input
   arguments or one local configuration file.
8. **Recursive path setup creates ambiguous function resolution.** Several
   helper filenames are duplicated between the main and statistical folders,
   while scripts call `addpath(genpath(pwd))`. MATLAB may therefore select a
   different implementation depending on path order.
9. **Several analysis branches are manually disabled.** For example,
   `SR_2_interEMG.m` runs only `caseno = 1`, while other comparison branches
   remain unreachable unless edited. Record each enabled branch as part of the
   analysis configuration.
10. **Broad exception handlers hide root causes.** Some MATLAB `catch` blocks
    print a generic participant/condition message and continue, without the full
    exception or a structured exclusion record.
11. **Window and frequency settings are embedded in scripts.** Different files
    switch manually among 0.5, 1 and 2 second windows and hard-coded frequency
    vectors. Confirm that processing, pooling and plotting use matching settings.
12. **R dependencies are not locked.** `pacman::p_load` can install missing
    packages at runtime, and no `renv` lockfile was present. Package updates can
    alter model, plotting or spreadsheet behaviour.
13. **Outlier removal and inferential annotations differ by script.** Tukey
    1.5-IQR filtering is applied to some CoP/EMG analyses but commented out in
    others. Some figures annotate ordinary t-tests even though the tabulated
    analysis uses participant-level mixed-effects models. Align exclusions and
    figure annotations with the prespecified statistical analysis.

## Validation performed for this release

- Restricted the release to study source code and documentation.
- Excluded participant data, generated outputs, manuscripts, R workspaces,
  compiled binaries, archives and bundled third-party projects.
- Checked the staged files for oversized artefacts and obvious credential
  patterns.
- Checked `CITATION.cff` as YAML and checked the Git index for whitespace errors.

MATLAB, R and private study data were not available in the release environment,
so these checks do not constitute regeneration of the conference or manuscript
results.
