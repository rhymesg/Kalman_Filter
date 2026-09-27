# Kalman_Filter

## Overview

MATLAB tutorial examples of the Kalman filter (KF) and extended Kalman filter (EKF) for INS/GNSS navigation, target tracking, and terrain-referenced navigation (TRN, also called terrain-aided navigation).

These are the authors' implementations accompanying the **peer-reviewed tutorial chapter** [*Introduction to Kalman Filter and Its Applications*](https://www.intechopen.com/chapters/63164), with source and terrain data available directly in this repository. See the [chapter citation](#citation), [implementation map](#algorithms-and-source), and [provenance](docs/provenance.md).

The accompanying tutorial chapter has received **over 500 citations** on [Google Scholar](https://scholar.google.com/citations?view_op=view_citation&hl=en&user=8b6KtGYAAAAJ&citation_for_view=8b6KtGYAAAAJ:hC7cP41nSMkC).

Review the documented [covariance and Jacobian issues](docs/limitations.md) before adapting these examples.

## Installation

- MATLAB and Statistics and Machine Learning Toolbox are required: the scripts use [`normrnd`](https://www.mathworks.com/help/stats/normrnd.html).
- The shell commands below use [`matlab -batch`](https://www.mathworks.com/help/matlab/ref/matlabmacos.html), available from R2019a; add your MATLAB executable to PATH.
- The terrain example uses the included [DEM.mat](examples/DEM.mat).
- MATLAB execution has not yet been verified for this repository layout; Octave compatibility is not claimed.

Clone the repository:

```bash
git clone https://github.com/rhymesg/Kalman_Filter.git
```

Enter its root directory:

```bash
cd Kalman_Filter
```

## Usage

Generate current-code versions of all seven simulation figures as PNG and PDF files:

```bash
matlab -batch "generate_figures"
```

Generate one figure, such as Figure 5:

```bash
matlab -batch "generate_figures(5)"
```

See the [figure map and export options](docs/figures.md) for Figures 1-5, 8, and 9, seeds, and output metadata. Current-source results may differ from the paper's plots because later source revised equations/settings.

Run the seeded introductory INS/GNSS example without opening figure windows:

```bash
matlab -batch "set(groot,'defaultFigureVisible','off'); main; disp(x_RMSE(:,end))"
```

In an interactive MATLAB session, select the repository root as the current folder and enter `main` to see the plots. The scripts clear their calling workspace and close existing figures; save work before running them.

See [Examples](examples/README.md) for the two EKF commands, outputs, seeds, and terrain-data conventions.

## Development

Run the noninteractive [example integration checks](tests/integration/examples/README.md) from the repository root:

```bash
matlab -batch "addpath('tests/integration/examples'); verify_examples"
```

Check chapter-figure generation and export:

```bash
matlab -batch "addpath('tests/integration/examples'); verify_figures"
```

The checks exercise the entry point, example outputs, deterministic reruns, and terrain-file loading. They do not establish scientific correctness or reproduce the chapter's figures; see [verification status](docs/provenance.md#verification-status).

Report problems through the repository's [issue tracker](https://github.com/rhymesg/Kalman_Filter/issues), including the script, MATLAB/toolbox versions, seed, and error or result.

[Repository metadata](docs/repository-metadata.md) provides a suggested GitHub description and topics for maintainers.

## Algorithms and source

| Method and application | Chapter | Implementation and runnable example | Technical reference |
|---|---|---|---|
| Linear KF: inertial/GNSS position and velocity | Sections 2.2-2.3, Eqs. (3)-(18) | [KF.m](examples/KF.m) | [Kalman filter](docs/kalman-filter.md) |
| EKF: angle/range target tracking | Sections 3.2-3.3.1, Eqs. (23)-(32) | [EKF_1.m](examples/EKF_1.m) | [Extended Kalman filter](docs/extended-kalman-filter.md) |
| EKF: terrain-referenced navigation | Sections 3.2, 3.3.2, Eqs. (33)-(40) | [EKF_2.m](examples/EKF_2.m) | [Terrain navigation](docs/terrain-referenced-navigation.md) |

Each script contains its model, Monte Carlo simulation, filter updates, and plotting code; there is no separate public filter API.

## Citation

If you use or adapt these methods or examples, please cite:

> Youngjoo Kim and Hyochoong Bang. “Introduction to Kalman Filter and Its Applications.” In *Introduction and Implementations of the Kalman Filter*. IntechOpen, 2018. [doi:10.5772/intechopen.80600](https://doi.org/10.5772/intechopen.80600).

Machine-readable software and chapter metadata are in [CITATION.cff](CITATION.cff).

## License and provenance

The [license](LICENSE) specifies the copyright and redistribution conditions. Citation requests are separate from those license conditions.

See [provenance](docs/provenance.md) for source-distribution and dataset details, and [limitations](docs/limitations.md) before adapting the examples.
