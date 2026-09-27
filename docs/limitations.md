# Known Limitations and Chapter Differences

This reference separates the supplied implementation's behavior from the printed [chapter](https://doi.org/10.5772/intechopen.80600). The repository preserves the original filtering equations and settings; these observations are not corrections applied to the source.

## Correction history

The author reports that a paper equation was corrected in later source and that resulting plots can differ from the paper. The [File Exchange history](https://www.mathworks.com/matlabcentral/fileexchange/68262-introduction-to-kalman-filter-and-its-applications) records a typo fix in version 1.0.1 and revised equations and simulation settings in version 1.0.3, without identifying the equation.

This repository uses the supplied version 1.0.3 as its execution baseline. The [figure exporter](figures.md) preserves that source's numerical methods instead of tuning them to match the 2018 figures; the specific historical correction remains unidentified.

The observations below are independent checks of the supplied snapshot, not an identification of the correction the author recalls.

## Linear KF process covariance

[KF.m](../examples/KF.m) uses the block-diagonal `Q` printed in Eqs. (6) and (17). For acceleration noise shared by the position and velocity increments, however, the chapter's expression $B\Sigma_a B^T$ gives

$$
Q=\begin{bmatrix}
\tfrac14\Delta t^4\Sigma_a & \tfrac12\Delta t^3\Sigma_a\\
\tfrac12\Delta t^3\Sigma_a & \Delta t^2\Sigma_a
\end{bmatrix},
$$

which has nonzero position-velocity cross covariance. The code and the expanded matrix in the chapter omit those off-diagonal blocks, even though the simulated acceleration sample drives both increments.

For one axis at `dt = 1` and acceleration standard deviation `0.3`, the omitted cross covariance is `0.045`. Reusing this noise model requires deciding whether to preserve the teaching example or model the shared noise consistently.

## Target-tracking Jacobian

In [EKF_1.m](../examples/EKF_1.m), the elevation row sets `H(2,3) = 1/norm(pp(1:2))`, matching the printed Eq. (28). For the implemented elevation $\operatorname{atan2}(z,\rho)$, where $\rho=\sqrt{x^2+y^2}$, differentiation instead gives

$$
\frac{\partial h_{elevation}}{\partial z}=\frac{\rho}{\rho^2+z^2}.
$$

At relative position `(3, 4, 12)`, the supplied expression gives `0.2`; the analytic derivative and a centered finite-difference check give approximately `0.0295858`. This expression appears in both the supplied snapshot and printed equation; it does not establish which historical correction the author recalls.

The same script subtracts measured and predicted angles without wrapping to a principal interval. Its Jacobian also divides by horizontal range and range without handling singular geometries.

## Settings that differ from the chapter

| Example | Printed chapter | Supplied version 1.0.3 |
|---|---|---|
| Target tracking: process standard deviation | `5`, text following Eq. (29) | `sig_pro = [0.5; 0.5; 0.5]` |
| Target tracking: initial velocity covariance | `0.1^2` on each velocity diagonal, Eq. (32) | zero, from `sig_init(4) = 0` |
| Terrain navigation: initial position standard deviation | `50` per axis, Eqs. (39)-(40) | `sig_init = [20; 20]` |
| Terrain navigation: interpolation | “cubic spline,” Section 3.3.2 | `'cubic'` in the estimator; `'spline'` only in contour plotting |

The [source distribution's release notes](https://www.mathworks.com/matlabcentral/fileexchange/68262-introduction-to-kalman-filter-and-its-applications) describe version 1.0.3 as revising equations and simulation settings. These differences and unspecified original random seeds prevent claiming exact reproduction of the chapter's plots.

## Interpretation and operational limits

- Zero instantaneous velocity columns in the target tracker's measurement Jacobian do not alone establish that velocity is unobservable over time; the state transition couples position and velocity.
- `x_RMSE` measures root mean squared errors including bias. `P_diag` stores the last Monte Carlo run's covariance diagonal, which can vary across EKF runs.
- All scripts use the simple covariance correction `(I-K*H)*P`; they do not enforce symmetry or positive semidefiniteness numerically.
- [Terrain lookups](terrain-referenced-navigation.md#boundaries-and-limitations) have no map-boundary or invalid-value handling.
- Scripts clear the calling workspace and close figures; the code is not packaged as a reusable filter function.
- [Integration checks](../tests/integration/examples/README.md) cover execution and packaging, not mathematical correctness, tuning quality, or the safety of real navigation applications.
