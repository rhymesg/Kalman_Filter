# Implementation and chapter reference

Reference for the current examples and the [tutorial chapter](https://doi.org/10.5772/intechopen.80600). Use the [chapter citation](../README.md#citation) when applying the methods.

## Correction history

The [File Exchange history](https://www.mathworks.com/matlabcentral/fileexchange/68262-introduction-to-kalman-filter-and-its-applications) records source updates to equations and simulation settings. [Provenance](provenance.md) identifies the imported source; the [figure exporter](figures.md) runs the current examples.

## Linear KF process covariance

[KF.m](../examples/KF.m) uses `Q = B*diag(sig_acc.^2)*B'`. A shared acceleration sample drives both position and velocity increments, giving covariance blocks `dt^4*Sigma/4`, `dt^3*Sigma/2`, and `dt^2*Sigma`.

For one axis with `dt = 1` and acceleration standard deviation `0.3`, the position–velocity cross covariance is `0.045`. Retain these off-diagonal terms when translating the model.

## Target-tracking Jacobian

For elevation `atan2(z,rho)`, with `rho = hypot(x,y)`, the height derivative is `rho/(rho^2+z^2)`. [EKF_1.m](../examples/EKF_1.m) uses this derivative and wraps both angular innovations with `atan2(sin(y),cos(y))`.

The observation Jacobian requires positive horizontal range and total range. Initial covariance is `diag(sig_init.^2)`, matching all six configured state standard deviations.

## Settings that differ from the chapter

| Example setting | Chapter | Source |
|---|---|---|
| Tracking process standard deviation | `5` | `0.5` per velocity-state component |
| Tracking initial velocity covariance | `0.1^2` | zero by default |
| Terrain initial position standard deviation | `50` | `20` per axis |
| Terrain interpolation | cubic spline | cubic estimator lookup, spline contour |

## Output and input contracts

`x_RMSE` includes both bias and variance; `P_diag` records the final Monte Carlo trial's covariance diagonal. Each script uses `(I-K*H)*P` for covariance correction, clears the calling workspace, and opens figures.

[Terrain lookup requirements](terrain-referenced-navigation.md#terrain-input-contract) specify the valid DEM neighborhood. [Integration checks](../tests/integration/examples/README.md) exercise example outputs, shared-noise covariance, per-state initialization, and the tracking Jacobian.
