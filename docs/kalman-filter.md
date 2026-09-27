# Linear Kalman Filter for INS/GNSS Navigation

Implementation reference for [KF.m](../examples/KF.m), corresponding to Sections 2.2-2.3 of the [chapter](https://doi.org/10.5772/intechopen.80600). Run it using the [example instructions](../examples/README.md#run); attribution is in the [canonical citation](../README.md#citation).

## Problem and model

Estimate three-dimensional position and velocity from noisy acceleration inputs and GNSS position/velocity measurements. This simplified inertial/GNSS example omits attitude, sensor biases, Earth rotation, and coordinate-frame transformations.

The state is $x=[p_x,p_y,p_z,v_x,v_y,v_z]^T$. With zero-mean additive noise, the linear model is

$$
x_k=Fx_{k-1}+Bu_{k-1}+w_{k-1},\qquad z_k=Hx_k+\nu_k.
$$

`F = [I, dt*I; 0, I]`, `B = [0.5*dt^2*I; dt*I]`, and `H = I` implement constant-velocity propagation with acceleration input and direct position/velocity observations. `Q` and `R` specify the filter's assumed process and measurement covariance; `sig_acc_true` and `sig_gps_true` govern simulated sensor noise.

## Prediction and correction

Section 2.2 gives the recursion, also called propagation and measurement update:

$$
\hat x^-_k=F\hat x^+_{k-1}+Bu_{k-1},\qquad P^-_k=FP^+_{k-1}F^T+Q,
$$

$$
y_k=z_k-H\hat x^-_k,\quad K_k=P^-_kH^T(R+HP^-_kH^T)^{-1},
$$

$$
\hat x^+_k=\hat x^-_k+K_ky_k,\qquad P^+_k=(I-K_kH)P^-_k.
$$

MATLAB's right division in `K = P*H'/(R+H*P*H')` solves the linear system without explicitly computing an inverse. The script overwrites `P` and `x_est(:,k)` during prediction and correction.

## Paper-to-code map

| Chapter | Source location or symbol |
|---|---|
| Eq. (3): position/velocity state | `x_true`, `x_est` |
| Eqs. (5), (8)-(9): transition and input | `F`, `B` in `settings` |
| Eqs. (13), (17)-(18): observation and covariance | `H`, `Q`, `R` in `settings` |
| Eqs. (15)-(16): initial estimate and covariance | `initial guess` inside the Monte Carlo loop |
| Section 2.2: filter recursion | `Prediction` and `Update` blocks |
| Figures 1-2: errors and uncertainty | `res_x_err`, `x_RMSE`, `P_diag`, `plot results` |

## Interpretation and limits

- The true trajectory is deterministic; acceleration and GNSS samples vary across Monte Carlo runs.
- `x_RMSE` includes bias, while `sqrt(P_diag)` is the filter's predicted marginal standard deviation. Their agreement must be assessed, not assumed.
- The block-diagonal `Q` retains an inconsistency in the original covariance derivation; see [covariance limitation](limitations.md#linear-kf-process-covariance) before using it as a model for correlated position/velocity errors.
- The covariance update is the simple form shown in the chapter; it does not add numerical symmetry or positive-semidefiniteness safeguards.
