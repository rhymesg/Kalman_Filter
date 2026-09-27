# Example Integration Checks

Check the boundary between repository entry points, the original simulation scripts, and their bundled terrain data. These checks have not yet been run in MATLAB; see [verification status](../../../docs/provenance.md#verification-status).

## Run

From the repository root, with the [MATLAB requirements](../../../README.md#installation) installed:

```bash
matlab -batch "addpath('tests/integration/examples'); verify_examples"
```

The driver disables visible figures, uses seed 0 with Twister, and runs from the system temporary directory. Separate function workspaces contain the original scripts' `clear` calls; cleanup restores the working directory, path, random state, and figure-visibility default.

The scripts still close existing figures; use the separate batch process above. The checks use the bundled data without manual preparation.

## Scenarios and acceptance

| Scenario | Failure caught | Pass condition |
|---|---|---|
| Direct linear KF | Broken script execution or output layout | Documented dimensions, finite estimates, nonnegative RMSE, valid covariance diagonal, and analytically derived truth endpoint |
| Root `main.m` | Wrong default example or seed | Estimates equal those of the directly seeded KF run |
| Target-tracking EKF | Broken example execution | Same output checks with its own trajectory endpoint |
| Terrain EKF called directly from outside its folder | Missing or working-directory-dependent DEM load | Script succeeds with included data and satisfies its output checks |

Endpoint tolerances cover floating-point roundoff in deterministic truth propagation; covariance diagonals permit a negative roundoff margin of `1e-12`. No statistical accuracy threshold or paper-result reproduction is asserted.

The terrain input is the unchanged [DEM.mat](../../../examples/DEM.mat) from the original bundle; see [provenance](../../../docs/provenance.md). Scientific caveats are documented separately in [limitations](../../../docs/limitations.md).

## Figure exports

Run the separate export check from the repository root:

```bash
matlab -batch "addpath('tests/integration/examples'); verify_figures"
```

`verify_figures` writes outputs to a temporary directory and removes it afterward. It checks the seven simulation figures, Figure 2 alone with a duplicate request, and rejection of a diagram request.

- Every requested figure must have a nonblank readable PNG, a PDF signature, and matching figure-number metadata.
- A single-figure request must not export unrelated figures; duplicates must generate only one set of files.
- Figure 2's pixels must match between all-figure and individual export with the same seed and environment.
- Requests for a non-simulation figure must be rejected before creating an output directory.

These checks are currently unrun in MATLAB. File-readability checks do not replace visual review, validate every plotted curve, or assert equality with the paper's figures.
