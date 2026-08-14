# Calibration

MATLAB implementation of the car-following model calibration framework distributed with the paper:

> V. Punzo, Z. Zheng, M. Montanino, **About calibration of car-following dynamics of automated and human-driven vehicles: Methodology, guidelines and codes**, *Transportation Research Part C: Emerging Technologies*, 128, 103165, 2021.  
> https://doi.org/10.1016/j.trc.2021.103165

The calibration code estimates car-following model parameters through a genetic algorithm, using a selectable goodness-of-fit (GOF) function and one or more observed leader-follower trajectories. After calibration, the code simulates the calibrated model, evaluates all available GOFs and stores calibration reports, validation reports and trajectory figures.

## Folder structure

```text
Calibration/
└── Source/
    ├── MAIN.m
    ├── ImportTrajectoryData.m
    ├── ObjFuncValue.m
    ├── Optimization.m
    ├── SetupData.m
    ├── SetupModel.m
    ├── Simulation.m
    └── Data/
        ├── setup.txt
        ├── ASTAZERO/
        ├── JIANG/
        ├── NAPOLI/
        └── NGSIM/
```

Run the code with `Calibration/Source/` as the MATLAB current folder.

## Requirements

- MATLAB
- the toolbox providing the genetic algorithm function `ga`
- Parallel Computing Toolbox only if parallel calibration is enabled

No minimum MATLAB release is specified in the original package.

## Quick start

### 1. Select the dataset

Edit:

```text
Source/Data/setup.txt
```

The file contains two values:

```text
Project:    NAPOLI
Experiment: Exp
```

`Project` identifies the dataset folder. The package includes:

- `NAPOLI`
- `JIANG`
- `NGSIM`
- `ASTAZERO`

The second value is read by the MATLAB code as the `Database` variable and selects the corresponding subfolder, currently `Exp` in the bundled datasets.

### 2. Configure the calibration experiment

Edit:

```text
Source/Data/<PROJECT>/<DATABASE>/config.txt
```

For example:

```text
ModelID:    2
VehicleID:  0
GOF:        0
PopSize:    100
Parallel:   0
NumCPUs:    2
```

The fields are:

| Field | Meaning |
|---|---|
| `ModelID` | car-following model to calibrate |
| `VehicleID` | trajectory ID, comma-separated IDs, or `0` |
| `GOF` | GOF ID, comma-separated IDs, or `0` |
| `PopSize` | genetic-algorithm population size |
| `Parallel` | `0` for serial execution, `1` for parallel execution |
| `NumCPUs` | number of workers requested when `Parallel=1` |

### 3. Check `AllVehicleIDs` when using `VehicleID=0`

`VehicleID=0` does **not** scan the folder automatically. It uses the `AllVehicleIDs` array defined near the beginning of `Source/MAIN.m`.

Set that array consistently with the selected dataset before running all trajectories. The IDs documented in the source are:

```text
NAPOLI:    1:9
JIANG:     [101,102,103,104,105,171,263,305,341,416]
NGSIM:     [607,705,770,797,978,1506,1593,1597,1649,1700,1754,3222]
ASTAZERO:  1:8
```

If one or more explicit IDs are provided in `config.txt`, `AllVehicleIDs` is not used.

## Car-following models

The MATLAB source contains implementations for:

| Model ID | Model |
|---:|---|
| `1` | Intelligent Driver Model (IDM) |
| `2` | Gipps model |
| `3` | Linear controller with Constant Time Headway (CTH) |
| `4` | Linear controller with sigmoid formulation |
| `5` | Optimal Velocity Model (OVM) |
| `6` | Full Velocity Difference Model (FVDM) |
| `999` | custom model |

Calibration requires a parameter-bound file at:

```text
Source/Data/<PROJECT>/<DATABASE>/Bounds/Model Class <ModelID>/parameters.txt
```

The bundled datasets provide parameter bounds for model classes `1`-`4`; the ASTAZERO dataset also contains an example `Model Class 999` custom formulation.

### Custom model

For `ModelID=999`, the corresponding bounds folder must contain:

```text
parameters.txt
model.txt
```

`parameters.txt` defines parameter lower and upper bounds. `model.txt` contains the MATLAB model formulation read by the calibration code. The formulation must return:

- `a`: acceleration used to update the simulated state;
- `success`: `1` if the simulation can continue, `0` if it must stop.

The original implementation expects the custom model formulation in `model.txt` as a single text line.

## Vehicle selection

`VehicleID` can be configured as:

```text
607
```

for a single trajectory,

```text
607,705,770
```

for multiple trajectories, or:

```text
0
```

for all IDs listed in `AllVehicleIDs` in `MAIN.m`.

## Goodness-of-fit functions

`GOF` selects the objective function used by the genetic algorithm. Multiple IDs can be comma-separated. `GOF=0` runs the calibration for all 29 GOFs.

| ID | GOF |
|---:|---|
| 1 | RMSE(S) |
| 2 | RMSE(V) |
| 3 | RMSE(A) |
| 4 | RMSE(stdV) |
| 5 | RMSPE(S) |
| 6 | RMSPE(V) |
| 7 | RMSPE(A) |
| 8 | RMSPE(stdV) |
| 9 | MAE(S) |
| 10 | MAE(V) |
| 11 | MAE(A) |
| 12 | MAPE(S) |
| 13 | MAPE(V) |
| 14 | MAPE(A) |
| 15 | U(S) |
| 16 | U(V) |
| 17 | U(A) |
| 18 | RMSPEt(S) |
| 19 | RMSPEt(V) |
| 20 | RMSPE(stdV+S) |
| 21 | NRMSE(V+S) |
| 22 | RMSPE(V+S) |
| 23 | MAPE(V+S) |
| 24 | RMSPEt(V+S) |
| 25 | U(V+S) |
| 26 | NRMSE(V+S+A) |
| 27 | RMSPE(V+S+A) |
| 28 | MAPE(V+S+A) |
| 29 | U(V+S+A) |

The complete set of GOFs is evaluated again during the validation/simulation phase, independently of the GOF selected for calibration.

## Input trajectory data

All import routines use a sampling interval of `0.1 s`.

For `NAPOLI`, `JIANG` and `ASTAZERO`, the current import routines read:

```text
Data/<PROJECT>/<DATABASE>/dataVehicles/dataVehicle<ID>.txt
```

and use:

- column 2: leader position;
- column 3: follower position;
- column 4: leader speed;
- column 5: follower speed;
- column 6: leader vehicle length.

For `NGSIM`, the importer reads:

```text
Data/NGSIM/<DATABASE>/dataVehicles/Vehicle_<ID>.txt
```

and uses:

- column 3: leader position;
- column 10: follower position;
- column 4: leader speed;
- column 11: follower speed;
- column 6: leader vehicle length.

The other columns in the NGSIM files are preserved because the distributed trajectories follow the original reconstructed-data format used by the study.

## Run the calibration

Set the MATLAB current folder to:

```text
Calibration/Source
```

and run:

```matlab
MAIN
```

`MAIN.m` performs, for each selected vehicle and calibration GOF:

1. parameter optimization using `ga`;
2. storage of the calibrated parameter vector and objective-function value;
3. simulation with the calibrated parameters;
4. evaluation of all GOFs;
5. generation of validation reports and simulation figures.

## Output

Results are written below:

```text
Source/Results/<PROJECT>/<DATABASE>/Model <ModelID>/VehicleID <VehicleID>/
```

Typical files are:

```text
Calibration_Report_Exp_<n>_<GOF>.txt
Validation_Report_CalExp_<n>_<GOF>.txt
Figures/
```

The calibration report contains the calibrated parameter vector followed by the objective-function value.

The validation report contains the GOF values obtained by simulating the calibrated model. The `Analysis/` code uses these validation reports as input.

A runtime log is also appended to:

```text
Source/log.txt
```

## Source files

| File | Role |
|---|---|
| `MAIN.m` | experiment configuration, calibration loop, validation and output generation |
| `Optimization.m` | genetic-algorithm setup and parameter estimation |
| `ObjFuncValue.m` | objective-function evaluation during calibration |
| `Simulation.m` | car-following simulation and calculation of the 29 GOFs |
| `SetupModel.m` | maps the calibrated parameter vector to the selected model |
| `SetupData.m` | prepares trajectory sets for optimization/simulation |
| `ImportTrajectoryData.m` | imports the dataset-specific trajectory format |

## Citation

Use of this code requires appropriate credit and citation of **both** methodological works associated with the repository:

> V. Punzo, Z. Zheng, M. Montanino, **About calibration of car-following dynamics of automated and human-driven vehicles: Methodology, guidelines and codes**, *Transportation Research Part C: Emerging Technologies*, 128, 103165, 2021.  
> https://doi.org/10.1016/j.trc.2021.103165

> V. Punzo, M. Montanino, **Speed or spacing? Cumulative variables, and convolution of model errors and time in traffic flow models validation and calibration**, *Transportation Research Part B: Methodological*, 91, 21-33, 2016.  
> https://doi.org/10.1016/j.trb.2016.04.012

## License

The code and accompanying data are available for **non-commercial research and educational use** under the terms of the repository [`LICENSE`](../LICENSE).

Users must retain the copyright/license notice, acknowledge the original authors and the Digital Mobility Lab | University of Naples Federico II, and cite the two works listed above in scholarly outputs based on this code.

## Digital Mobility Lab

**Digital Mobility Lab | University of Naples Federico II**  
https://digitalmobility.unina.it
