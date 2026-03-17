# Photonic Ising Machine

Code and supporting data for experiments related to a fully integrated quantum-dot laser Ising machine, including a hardware-in-the-loop Max-Cut solver and optical-routing cost/constraint functions.

## Repository Structure

### Root-level files
- `README.md`: project overview, environment notes, and usage guidance.
- `LICENSE`: MIT License.
- `QD_laser_Ising_solver.m`: main MATLAB script for running a photonic Ising optimization loop with a source measure unit (SMU) over GPIB.

### `Max-cut/`
- `G22.mat`: benchmark graph data file for Max-Cut experiments.
- `G67.mat`: benchmark graph data file for Max-Cut experiments.
- `J_150x150_square_lattice.mat`: large lattice-style coupling/graph data for Max-Cut-style Ising tests.

> Note: `.mat` files are MATLAB binary data containers. Their exact variables are read at runtime in MATLAB.

### `Optical routing/`
- `F_cost.m`: computes total path-length cost by summing road occupancies for five paths.
- `F_road.m`: computes conflict penalty when more than one path uses the same road.
- `F_balance.m`: computes load-balancing penalty to keep five paths with similar total lengths.
- `F_enter.m`: enforces source/destination port entry constraints for each path.
- `F_unit.m`: enforces node-level unit constraints on a manually indexed mesh topology.
- `mesh_map.mat`: mesh topology/support data for routing experiments.

## File-by-file Functional Notes

### 1) `QD_laser_Ising_solver.m`
This is the main experimental script. It:
1. Clears existing instrument handles.
2. Loads graph data (`xx.mat`, expected to contain `Problem.A`).
3. Builds Ising/Max-Cut terms from the adjacency matrix.
4. Runs an iterative stochastic update with Robbins-Monro style decay.
5. Uses measured laser/photodetector nonlinearity as the activation function via real hardware I/O.
6. Tracks cut value and energy over iterations.
7. Plots optimization traces and prints final metrics.

Important placeholders (`**`) must be replaced before execution:
- `alpha`, `beta`, `r1`, `r2`
- `I_min`, `I_max`, `P_lo`, `P_hi`

### 2) `Optical routing/F_cost.m`
Returns the objective cost equal to total occupied roads across five candidate routes (`xA` to `xE`). Also returns per-route length details.

### 3) `Optical routing/F_road.m`
Returns a penalty based on pairwise overlap of route occupancy vectors. If two routes choose the same road index, the penalty increases.

### 4) `Optical routing/F_balance.m`
Returns a balancing penalty so the five routes have similar lengths. The function scales each route length against total load and squares deviations.

### 5) `Optical routing/F_enter.m`
Builds per-path target vectors on port-connected roads and penalizes deviations. This enforces each route to activate only its own source and destination port roads.

### 6) `Optical routing/F_unit.m`
Applies topology constraints at H/V nodes using a hard-coded road-index mapping table (`build_node_eq4_table`).
- H nodes: flow conservation style penalty.
- V nodes: crossing consistency penalty.

The function also prepares debug output structures.

### 7) Data files (`*.mat`)
- Store benchmark graph and mesh data consumed by scripts/functions.
- These are not source code files and are expected to be loaded from MATLAB.

## Environment Requirements

## MATLAB
- MATLAB with basic matrix functionality.
- Instrument Control Toolbox (required for `gpib`, `instrfind`, `fopen/fclose` on instruments).

## Hardware (for `QD_laser_Ising_solver.m`)
- A GPIB-accessible SMU matching command style in the script (e.g., Keithley-like SCPI/TSP usage).
- Correct GPIB board index and instrument address (currently `gpib('ni', 0, 26)`).
- Photodetector responsivity calibration and laser LI calibration values.

## Optional workflow
- For purely algorithmic simulation, you can replace hardware I/O sections with a software nonlinearity model.

## Quick Start

1. Open MATLAB and set working directory to repository root.
2. Prepare graph input file expected by the solver:
   - either provide `xx.mat` with `Problem.A`,
   - or adapt `QD_laser_Ising_solver.m` to load one of the files under `Max-cut/`.
3. Fill all placeholder parameters in `QD_laser_Ising_solver.m`.
4. Verify instrument connectivity and address.
5. Run:
   ```matlab
   QD_laser_Ising_solver
   ```

For optical routing objective experiments, call the functions in `Optical routing/` from your own optimization driver with binary occupancy vectors of equal length.

## Practical Notes
- Keep all path vectors (`xA`...`xE`) aligned to `numel(mesh.roads)`.
- `F_enter` assumes each IN/OUT port connects to exactly one road.
- `F_unit` relies on fixed road numbering; if mesh indexing changes, update `build_node_eq4_table` accordingly.
- Keep all comments and documentation in English for consistency.

