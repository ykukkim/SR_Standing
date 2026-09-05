# External dependencies

Large or externally maintained toolboxes are intentionally not copied into this
repository. Install compatible versions separately and add only the required
directories to the MATLAB path.

- [NeuroSpec](https://github.com/dmhalliday/NeuroSpec) — `sp2a2_R2_mt`,
  `pool_scf`, `pool_scf_out` and plotting routines used for coherence analysis.
  The source export contained a mixture of NeuroSpec 2.0-era and later files,
  including a 16 MB DPSS data file. Select and record one upstream version.
- [FieldTrip](https://www.fieldtriptoolbox.org/) — `ft_preproc_dftfilter`, called
  by the EMG preprocessing helper to reduce 50 Hz power-line interference.
  Follow FieldTrip's setup instructions rather than recursively adding every
  subdirectory.
- [spm1d for MATLAB](https://spm1d.org/DocumentationMatlab.html) — plotting used
  by `02_Statistic_analysis/Matlab/SRprep00_CoPFrequencyPlot.m`.
- [Biomechanical ToolKit](https://biomechanical-toolkit.github.io/docs/) —
  required only for the archived C3D-to-MAT conversion route. The released
  analysis entry point expects already converted MAT files.

The MATLAB scripts also use functions from MathWorks toolboxes, including
filter design, power spectral density, coherence, wavelet and statistics
functions. Exact MATLAB/toolbox versions were not recorded in the export.

The R analysis uses the packages listed in `R-packages.txt`. No lockfile was
present, so the original package versions cannot be reconstructed from the
source export alone.
