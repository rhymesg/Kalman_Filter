# Extended Kalman Filter for Target Tracking

Implementation reference for [EKF_1.m](../examples/EKF_1.m), corresponding to Sections 3.2-3.3.1 of the [chapter](https://doi.org/10.5772/intechopen.80600). See [run instructions](../examples/README.md#run), [citation](../README.md#citation), and the separate [terrain EKF](terrain-referenced-navigation.md).

## Problem and model

Estimate a target's three-dimensional position and velocity from azimuth-like angle, elevation, and range measured by a moving sensor. The target follows a constant-velocity truth trajectory; the sensor moves on a horizontal circle at fixed height.

The state is $x=[p_x,p_y,p_z,v_x,v_y,v_z]^T$, propagated by `F = [I, dt*I; 0, I]`. The process covariance injects uncertainty only into the velocity components.

For relative position $q=p_{target}-p_{sensor}$ and $\rho=\sqrt{q_x^2+q_y^2}$, the implemented measurement is

$$
h(x)=\begin{bmatrix}
\operatorname{atan2}(q_x,q_y)\\
\operatorname{atan2}(q_z,\rho)\\
\lVert q\rVert
\end{bmatrix}.
$$

The first angle is measured using `atan2(x,y)`, not the commonly used `atan2(y,x)` convention. Angles and angular noise are in radians; range uses the trajectory's length unit.

## EKF procedure

1. Propagate the estimate and covariance using the linear motion model.
2. Evaluate `z_p = h(x_est(:,k))` at the predicted position relative to the sensor.
3. Form the measurement Jacobian `H` at that relative position, following the printed Eq. (28).
4. Compute `y = z - z_p`, `K = P*H'/(R+H*P*H')`, and apply the state and covariance corrections described in [the KF recursion](kalman-filter.md#prediction-and-correction).

For a general EKF, the transition and measurement matrices are the Jacobians of the nonlinear models at the current estimate, as in Eqs. (21)-(22). Here only the measurement model is nonlinear; its inherited Jacobian contains an [incorrect elevation derivative](limitations.md#target-tracking-jacobian).

## Paper-to-code map

| Chapter | Source location or symbol |
|---|---|
| Eqs. (23)-(25), (27): state and motion | `F`, `Q`, `x_true` |
| Eq. (26): relative angles and range | `p`, `pp`, `z_true`, `z_p` in `Update` |
| Eq. (28): measurement Jacobian | `H` constructed from `pp` |
| Eqs. (29)-(32): tuning and initialization | `sig_pro`, `R`, `sig_init`, `P` |
| Section 3.2: EKF recursion | `Prediction` and `Update` blocks |
| Figures 3-5 | sensor/target trajectories, sample estimates, and RMSE plots |

## Interpretation and limits

- A single measurement has no direct velocity component; velocity information can enter through dynamics and covariance coupling over successive measurements.
- Process-noise and initial-covariance settings differ from the printed chapter; see the [comparison table](limitations.md#settings-that-differ-from-the-chapter).
- Angle residuals are not wrapped, and the Jacobian is singular at zero horizontal range or zero range.
- The EKF uses local linearization and the simple covariance update; finite output alone does not establish consistency or convergence.
