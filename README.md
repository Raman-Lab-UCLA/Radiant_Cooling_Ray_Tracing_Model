TLDR:
First, run model_setup_file_generator_2.m, which generates the variables that define a given structure and that are used by the MRT_simulator_2.m file. Then, in MRT_simulator_2.m, load the corresponding .mat file to simulate it. 



This repository contains MATLAB scripts to define and simulate mean radiant temperature (MRT) distributions in various enclosure configurations. The workflow consists of two main steps:

1. Generate model definition using `model_setup_file_generator_2.m`.
2. Run simulation using `MRT_simulator_2.m`.

- Supporting functions in the folder:
  - `plane.m` — computes a plane’s normal and reference point from three vertices
  - `rays.m` — generates uniformly distributed ray direction vectors
  - `propagateRay_V1.m` — traces each ray through planes to compute irradiance

Step 1: Generate a Model Definition

Open and run `model_setup_file_generator_2.m` in MATLAB. This script defines planar surfaces (floor, panels, reflectors, roof, etc.) for several scenarios and saves `.mat` files containing the following variables:

- `planeNormal` – *N×3* array of normalized plane normals
- `planePoint` – *N×3* array of one reference point per plane
- `planeTemp`  – *1×N* vector of plane temperatures (°C)
- `planeReflectance` – *1×N* vector of reflectance coefficients (0–1)

You can customize the scenarios by editing the geometric definitions or temperature/reflectance arrays in the generator script.

Step 2: Run the MRT Simulation

1. Open `MRT_simulator_2.m` in MATLAB.
2. At the top of the file, modify the `load()` call to reference the desired `.mat` file:
  e.g. load('ucla_demo_cad_0p58.mat');
 
3. Run the script. It will:
   - Set up a 1×1 m measurement grid at a specified height.
   - Cast a large number of rays from each grid point.
   - Compute radiative exchange with each plane.
   - Compute and plot the mean radiant temperature (MRT) distribution.

Plots and summary figures will be saved automatically (see `saveas` calls in the script).

Customization

- **Grid resolution**: modify `PPF` (points per meter) or ray resolution (`rayRes`) in `MRT_simulator_2.m`.
- **Panel temperatures**: adjust `planeTemps` assigned in the generator or directly in the simulator.
- **Reflectance values**: edit `planeReflectance` arrays or pass as function arguments.

Long runtimes: reduce `rayRes` or grid size for faster, lower-accuracy runs.
