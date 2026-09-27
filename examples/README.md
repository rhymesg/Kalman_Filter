# MATLAB Examples

Run the chapter's three simulations and inspect their estimates, errors, and covariance histories. Requirements and example commands are in the [repository README](../README.md#examples).

## Run

For individually numbered chapter figures, use the root [figure exporter](../docs/figures.md). It exports the seven simulation plots using their chapter numbers.

Run these shell commands from the repository root. Each starts a fresh MATLAB process, disables visible figures, seeds the random stream, and prints the final Monte Carlo RMSE vector.

Linear KF for INS/GNSS navigation:

```bash
matlab -batch "set(groot,'defaultFigureVisible','off'); rng(0,'twister'); run('examples/KF.m'); disp(x_RMSE(:,end))"
```

EKF for angle/range target tracking:

```bash
matlab -batch "set(groot,'defaultFigureVisible','off'); rng(0,'twister'); run('examples/EKF_1.m'); disp(x_RMSE(:,end))"
```

EKF for terrain-referenced navigation:

```bash
matlab -batch "set(groot,'defaultFigureVisible','off'); rng(0,'twister'); run('examples/EKF_2.m'); disp(x_RMSE(:,end))"
```

For interactive plots, use the corresponding `rng` and `run` expressions in the MATLAB Command Window without disabling figure visibility. The scripts execute `clear`, `clc`, and `close all`; they replace variables in the calling workspace and close existing figures.

MATLAB [`run`](https://www.mathworks.com/help/matlab/ref/run.html) temporarily switches to the script's folder. The terrain script additionally resolves `DEM.mat` relative to its own file, including when invoked directly from the MATLAB path.

## Inputs and outputs

Parameters live in each script's `settings` section; the scripts accept no arguments. The direct scripts use the current random stream, while root `main.m` explicitly selects seed 0 with the Twister generator.

| Script | State | Default estimate-array size | Plots |
|---|---|---|---|
| [KF.m](KF.m) | `[px; py; pz; vx; vy; vz]` | `6 x 21 x 100` | True/estimated x position and velocity; RMSE versus covariance; two error histories |
| [EKF_1.m](EKF_1.m) | `[px; py; pz; vx; vy; vz]` | `6 x 21 x 100` | True/estimated x position and velocity; RMSE versus covariance; sensor/target paths |
| [EKF_2.m](EKF_2.m) | `[x; y]` horizontal position | `2 x 101 x 100` | Terrain contour; x/y position RMSE |

The expected shapes and plots above come from source inspection; no numerical RMSE baseline or recreated paper figure is claimed.

| Workspace variable | Meaning |
|---|---|
| `x_true` | State-by-time truth, including the initial state |
| `res_x_est` | State-by-time-by-run estimates |
| `res_x_err` | Estimates minus truth for each run |
| `x_RMSE` | Per-state root mean squared error across runs, not a centered standard deviation |
| `P_diag` | Covariance diagonal from the final Monte Carlo run; for the EKFs it is not a Monte Carlo average |

Fix the seed and record MATLAB/toolbox versions when comparing runs. Repeated runs in the same environment should agree; cross-version bitwise identity and the chapter's original random draws are not guaranteed.

## Terrain data

[DEM.mat](DEM.mat) contains a `100 x 100` `uint16` matrix named `DEM`, supplied with the original example bundle. Its values range from 57 to 637; the bundle does not document a geographic location or geodetic datum.

The code treats the first matrix index as x, the second as y, and uses grid spacing 30 in local navigation coordinates. These are not latitude/longitude degrees; see [terrain navigation](../docs/terrain-referenced-navigation.md) for interpolation and boundary constraints.

## Before adapting

Read the [model assumptions, settings, and corrections](../docs/implementation-notes.md) and [citation guidance](../README.md#citation). A successful execution checks the implementation path, not every statistical assumption.
