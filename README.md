# Kalman_Filter

## Overview

MATLAB tutorial examples of the Kalman filter (KF) and extended Kalman filter (EKF) for INS/GNSS navigation, target tracking, and terrain-referenced navigation (TRN, also called terrain-aided navigation).

These are the authors' implementations accompanying the **peer-reviewed tutorial chapter** [*Introduction to Kalman Filter and Its Applications*](https://www.intechopen.com/chapters/63164), with source and terrain data available directly in this repository. See the [chapter citation](#citation), [implementation map](#algorithms-and-source), and [provenance](docs/provenance.md).

The accompanying tutorial chapter has received **over 500 citations** on [Google Scholar](https://scholar.google.com/citations?view_op=view_citation&hl=en&user=8b6KtGYAAAAJ&citation_for_view=8b6KtGYAAAAJ:hC7cP41nSMkC).

For implementations in Python, C++, or other languages, follow the [KF equations](docs/kalman-filter.md), [EKF update procedure](docs/extended-kalman-filter.md), and [terrain measurement model](docs/terrain-referenced-navigation.md).

## Method

Predict the state and covariance with a motion model, then correct them using measurements. The linear KF uses position/velocity observations; the EKFs linearize angle/range or terrain-height observations around the current estimate.

### Algorithms and source

| Method and application | Chapter | Implementation and runnable example | Technical reference |
|---|---|---|---|
| Linear KF: inertial/GNSS position and velocity | Sections 2.2-2.3, Eqs. (3)-(18) | [KF.m](examples/KF.m) | [Kalman filter](docs/kalman-filter.md) |
| EKF: angle/range target tracking | Sections 3.2-3.3.1, Eqs. (23)-(32) | [EKF_1.m](examples/EKF_1.m) | [Extended Kalman filter](docs/extended-kalman-filter.md) |
| EKF: terrain-referenced navigation | Sections 3.2, 3.3.2, Eqs. (33)-(40) | [EKF_2.m](examples/EKF_2.m) | [Terrain navigation](docs/terrain-referenced-navigation.md) |

## Examples

Run commands from the repository root with MATLAB and Statistics and Machine Learning Toolbox (`normrnd`). The shell commands use `matlab -batch` (R2019a or later); the terrain example uses the included [DEM.mat](examples/DEM.mat).

Generate current-code versions of all seven simulation figures as PNG and PDF files:

```bash
matlab -batch "generate_figures"
```

Generate one figure, such as Figure 5:

```bash
matlab -batch "generate_figures(5)"
```

See the [figure map and export options](docs/figures.md) for Figures 1-5, 8, and 9, seeds, and output metadata. The exporter uses the current equations and simulation settings.

Run the seeded introductory INS/GNSS example without opening figure windows:

```bash
matlab -batch "set(groot,'defaultFigureVisible','off'); main; disp(x_RMSE(:,end))"
```

In an interactive MATLAB session, select the repository root as the current folder and enter `main` to see the plots. The scripts clear their calling workspace and close existing figures; save work before running them.

See [Examples](examples/README.md) for the two EKF commands, outputs, seeds, and terrain-data conventions.

## Implementation scope

Each script contains its model, simulation, filter updates, and plotting code. Current source includes covariance and measurement corrections, with [settings and numerical assumptions](docs/implementation-notes.md) documented for adaptation.

### Checks

Run the focused [example and figure checks](tests/integration/examples/README.md):

```bash
matlab -batch "addpath('tests/integration/examples'); verify_examples; verify_figures"
```

These check example outputs, deterministic reruns, terrain loading, and figure export.

## Citation

For academic attribution, please acknowledge this repository when adapting its code or examples.

If you use or adapt these methods or examples, please cite:

> Youngjoo Kim and Hyochoong Bang. “Introduction to Kalman Filter and Its Applications.” In *Introduction and Implementations of the Kalman Filter*. IntechOpen, 2018. [doi:10.5772/intechopen.80600](https://doi.org/10.5772/intechopen.80600).

Machine-readable software and chapter metadata are in [CITATION.cff](CITATION.cff).

## License and provenance

The [license](LICENSE) specifies the copyright and redistribution conditions. Citation requests are separate from those license conditions.

See [provenance](docs/provenance.md) for source-distribution and dataset details, and [implementation notes](docs/implementation-notes.md) for model and numerical choices.
