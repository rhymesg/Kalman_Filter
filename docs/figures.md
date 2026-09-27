# Generate Chapter Figures

Generate a current-code counterpart of each simulation figure in the [chapter](https://doi.org/10.5772/intechopen.80600), retaining figure numbers 1-5, 8, and 9. Results use the supplied version 1.0.3 equations and settings; they are not fitted to the paper's historical curves.

## Commands

From the repository root, generate all seven simulation figures:

```bash
matlab -batch "generate_figures"
```

Generate only Figure 5:

```bash
matlab -batch "generate_figures(5)"
```

Choose a subset, output directory, and random seed:

```bash
matlab -batch "generate_figures([3 4 5], 'figures/tracking', 17)"
```

The default output directory is `figures/` beside `generate_figures.m`, and the default seed is 0. Custom relative directories are interpreted from the caller's working directory; the default `figures/` tree is gitignored.

Each selected number produces `figure-NN.png` at 150 dpi, `figure-NN.pdf`, and `figure-NN.json`. The JSON records the figure number, source, seed, generator, MATLAB version, and execution baseline; repeated calls overwrite that figure's files.

## Figure map

| Chapter figure | Content | Source |
|---|---|---|
| 1 | Linear-KF estimation errors for two Monte Carlo runs | [KF.m](../examples/KF.m), six error panels |
| 2 | Linear-KF x-position and x-velocity RMSE versus estimated uncertainty | [KF.m](../examples/KF.m), uncertainty plot |
| 3 | Moving sensor and target trajectories | [EKF_1.m](../examples/EKF_1.m), trajectory plot |
| 4 | True and estimated target x-position and x-velocity | [EKF_1.m](../examples/EKF_1.m), state plot |
| 5 | Target-tracking RMSE versus estimated uncertainty | [EKF_1.m](../examples/EKF_1.m), uncertainty plot |
| 8 | Terrain contour representation with [display adjustments and grid-index axes](terrain-referenced-navigation.md#terrain-lookup-and-update) | [EKF_2.m](../examples/EKF_2.m), contour plot |
| 9 | Terrain-navigation x/y RMSE | [EKF_2.m](../examples/EKF_2.m), error plot |

The linear-KF script also produces a true/estimated-state plot that has no chapter figure number; it is not exported by this entry point. Figures 6-7 are explanatory diagrams and are excluded from this simulation exporter.

## Reproducibility and paper differences

- Each requested simulation group runs once, with its random stream reset to the requested seed. A figure generated alone uses the same samples as that figure in a complete export in the same environment.
- Figure numbers select exports; the underlying original script may calculate and draw other figures in its group before they are closed.
- The author reports that later source corrects a paper equation. The [release history and independent checks](limitations.md#correction-history) distinguish that correction history from currently verifiable source observations; the exact historical correction is not identified.
- Changed equations/settings and different random draws can change the curves. Use the current source as the execution baseline; do not change it merely to reproduce a printed plot.
- The exporter runs without visible figure windows and restores the random state and default visibility afterward. The supplied scripts still close existing figures, so use a separate batch process.

## Preserve an export's provenance

The JSON does not identify an exact source/data snapshot or toolbox version. When sharing or archiving outputs, keep the following alongside the PNG, PDF, and JSON files:

- The repository URL, `git rev-parse HEAD` output, and `git status --short` output identifying local changes.
- A copy of the actual `generate_figures.m` and entire `examples/` directory, including `DEM.mat`; a commit alone does not capture modified or untracked files.
- MATLAB's `ver` output, which lists MATLAB and installed toolbox versions, plus [LICENSE](../LICENSE) and [CITATION.cff](../CITATION.cff).

After generating figures in the default directory, capture the environment from the same MATLAB installation:

```bash
matlab -batch "ver" > figures/environment.txt
```

## Verification

The exporter and its tests have not been executed in MATLAB in this environment. Syntax and source-preservation checks do not establish successful rendering or visual fidelity.

Run the [figure integration checks](../tests/integration/examples/README.md) to exercise all exports, individual selection, duplicate requests, readable files, and same-seed consistency:

```bash
matlab -batch "addpath('tests/integration/examples'); verify_figures"
```

Inspect the resulting plots on a MATLAB-equipped system before using them in a publication. Follow the [citation guidance](../README.md#citation) when sharing or adapting the figures.
