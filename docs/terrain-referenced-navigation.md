# EKF Terrain-Referenced Navigation

Implementation reference for [EKF_2.m](../examples/EKF_2.m), corresponding to Section 3.3.2 of the [chapter](https://doi.org/10.5772/intechopen.80600). Terrain-referenced navigation (TRN), also called terrain-aided navigation (TAN), estimates horizontal position by matching elevation measurements to a digital elevation model (DEM).

See [run instructions and terrain data](../examples/README.md), [citation](../README.md#citation), and the [shared EKF procedure](extended-kalman-filter.md#ekf-procedure).

## State and observations

The state is local horizontal position $x=[x_{horizontal},y_{horizontal}]^T$, not a geodetic latitude/longitude pair. The model is

$$
x_k=x_{k-1}+u_{k-1}+w_{k-1},\qquad z_k=h(x_k)+\nu_k,
$$

where `u` is displacement per step, and `h` is terrain elevation from the DEM. The simulation creates noisy displacement inputs and elevation measurements; it does not implement raw INS, radar-altimeter, or barometric sensor processing.

`F` and `B` are identity matrices. The measurement Jacobian is the local terrain gradient:

$$
H_k=\begin{bmatrix}\partial h/\partial x & \partial h/\partial y\end{bmatrix}.
$$

## Terrain lookup and update

1. Propagate the position with noisy displacement `u_p` and increase covariance by `Q`.
2. Use `DEM_height` to interpolate the predicted terrain elevation from a local `5 x 5` neighborhood.
3. Use `DEM_grad` to estimate each gradient component with centered finite differences, sampling 5 coordinate units on either side.
4. Form the scalar elevation residual and apply the EKF correction with `H = [grad_x, grad_y]`.

`DEM_height` divides local coordinates by grid spacing 30 and selects indices with `floor`. The first matrix index is x and the second is y; its `interp2(Y, X, DEM_part, y/30, x/30, 'cubic')` call reflects that ordering.

The estimator uses the `'cubic'` method, while the contour visualization uses `'spline'` on a subsampled surface. These are [distinct MATLAB interpolation choices](https://www.mathworks.com/help/matlab/ref/interp2.html); the plotted surface is not the exact lookup evaluated by the filter.

Figure 8 uses grid-index axes (1-100), rather than the filter's local coordinates with grid spacing 30. Before spline interpolation, the script sets `z_mesh(1,1)` to the subsampled mesh minimum and then `z_mesh(1,2)` to its maximum; these display adjustments leave the `DEM` used by the filter unchanged.

## Paper-to-code map

| Chapter | Source location or symbol |
|---|---|
| Eqs. (33), (35): position propagation | `F`, `B`, `u_p`, `Prediction` |
| Eq. (34): elevation observation | `DEM_height`, `z`, `z_p` |
| Eq. (36): observation gradient | `DEM_grad` and `H` |
| Eqs. (37)-(38): noise covariance | `Q`, `R` in `settings` |
| Eqs. (39)-(40): initialization | `sig_init`, initial `x_est`, `P`; settings differ |
| Figures 8-9 | terrain contour and position-RMSE plots |

## Terrain input contract

- Each lookup requires both floored grid indices to lie between 3 and 98, inclusive, for the supplied `100 x 100` matrix. The gradient's displaced samples must also satisfy this condition.
- Keep the trajectory, initial estimates, and displaced gradient samples within the interpolation neighborhood.
- Use terrain with local height variation to supply position information for the EKF linearization.
- The bundled DEM is a local-coordinate example. See [source settings](implementation-notes.md#settings-that-differ-from-the-chapter) for initialization and interpolation choices.
