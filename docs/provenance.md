# Source Provenance and Verification

This record identifies the source of the examples, their relationship to the chapter, and the verification limits of this repository layout.

## Source distribution

- Canonical repository: [rhymesg/Kalman_Filter](https://github.com/rhymesg/Kalman_Filter).
- Original distribution: [Introduction to Kalman Filter and Its Applications, MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/68262-introduction-to-kalman-filter-and-its-applications), by Youngjoo Kim, version 1.0.3 dated January 31, 2021.
- Publication: [peer-reviewed tutorial chapter](https://www.intechopen.com/chapters/63164) ([citation](../README.md#citation)); the publisher identifies its peer-review status, and its abstract describes its tutorial purpose. The chapter's reference [5] points to the File Exchange entry.
- Import source: the supplied `kalman_examples-1.0.3` bundle, with `KF.m`, `EKF_1.m`, `EKF_2.m`, `DEM.mat`, and `license.txt`.

The local `ref/` folder holds the original bundle and paper for comparison and is gitignored. Public documentation links to the DOI and distribution rather than relying on local reference files.

## Packaging changes

| File | Change relative to the supplied bundle |
|---|---|
| [KF.m](../examples/KF.m), [EKF_1.m](../examples/EKF_1.m) | Provenance headers and figure names/tags; corrected acceleration covariance, elevation derivative, and angular innovations |
| [EKF_2.m](../examples/EKF_2.m) | Added headers and figure names/tags; resolved `DEM.mat` relative to the script, loading only `DEM` |
| [DEM.mat](../examples/DEM.mat) | Exact byte copy |
| [LICENSE](../LICENSE) | Exact copy of `license.txt`, including its original wording |
| [main.m](../main.m) | Repository entry point for the seeded linear-KF example |
| [generate_figures.m](../generate_figures.m) | Seeded chapter-number selection and PNG/PDF export with metadata |

The covariance and tracking-measurement corrections change filter results. Noise standard deviations, initialization, interpolation choices, and plotting calculations retain their supplied settings. [Known limitations](limitations.md) remain visible for users adapting the code.

The author reports an equation correction in later source; the exact historical equation has not been identified. Generated figures follow the current corrected source, with [differences from the printed plots documented explicitly](figures.md#reproducibility-and-paper-differences).

The bundle includes the terrain matrix without a separate description of its geographical origin or datum. Its SHA-256 checksum is `59d1848bbffc59f8069ebcea43a4423fde82b9a1720ec8da1eb705da96de2f68`.

## Verification status

- Source inspection and byte comparisons confirm the packaging changes listed above.
- The terrain file was read successfully as a finite `100 x 100` `uint16` matrix with values from 57 to 637.
- Paper section/equation mappings and the disclosed discrepancies were checked against the supplied PDF, including visual inspection of equations.
- Local documentation links were checked, and `CITATION.cff` was validated against the official CFF 1.2.0 schema.
- The examples, figure exporter, and integration drivers pass a MATLAB R2019a syntax check with MISS_HIT; this does not execute their MATLAB APIs or render their figures.
- Mathematical spot checks support the covariance and Jacobian corrections described in [limitations](limitations.md); they do not execute the MATLAB filters.
- No MATLAB or Octave runtime was available during repository preparation. The documented commands, [integration checks](../tests/integration/examples/README.md), and example plots have not been executed in this layout.

Record MATLAB/toolbox versions, seed, and execution results here when native verification becomes available. A passing smoke check does not imply agreement with every equation or result in the publication.
