# Photonic Ising Machine

Code and supporting data for experiments related to KAUST-IPL's paper “_A Fully Integrated Quantum-Dot Laser Ising Machine_", including a hardware-in-the-loop Max-Cut solver and optical-routing cost/constraint functions.

## Repository Structure

### Root-level files
- `README.md`: project overview, environment notes, and usage guidance.
- `LICENSE`: MIT License.
- `QD_laser_Ising_solver.m`: main MATLAB script for running a photonic Ising optimization loop with a source measure unit (SMU) over GPIB.

### `Max-cut/`
- `G22.mat`: benchmark graph data file for G22 Max-Cut experiments.
- `G67.mat`: benchmark graph data file for G67 Max-Cut experiments.
- `J_150x150_square_lattice.mat`: large lattice-style coupling/graph data for Max-Cut-style Ising tests.

> Note: `.mat` files are MATLAB binary data containers. Their exact variables are read at runtime in MATLAB.

### `Optical routing/`
- `F_cost.m`: computes total path-length cost by summing road occupancies for five paths.
- `F_road.m`: computes conflict penalty when more than one path uses the same road.
- `F_balance.m`: computes load-balancing penalty to keep five paths with similar total lengths.
- `F_enter.m`: enforces source/destination port entry constraints for each path.
- `F_unit.m`: enforces node-level unit constraints on a manually indexed mesh topology.
- `mesh_map.mat`: mesh topology/support data for routing experiments.

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

