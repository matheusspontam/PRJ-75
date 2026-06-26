# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Academic project (ITA, PRJ-75): preliminary design of an antiship missile equivalent to the Exocet/MM40 class (70 km range, Mach 0.9, solid propulsion). It is **not** a software project — it is a collection of engineering reports (LaTeX) plus the MATLAB/Simulink code and data that produced each report's results. There is no build system, package manager, test suite, or CI. "Running" the code means opening MATLAB and executing scripts; "building" means compiling LaTeX.

The README.md is in Portuguese and is the authoritative overview of intent per report. Reports are written in LaTeX; the integrated final report (`05_`) is in English.

## Layout

Five numbered stages, each self-contained with `report/` (LaTeX + PDF), `code/`, and `results/`:

1. `01_Relatorio_1_Dimensionamento_Propulsao_Solida/` — preliminary sizing & solid propulsion
2. `02_Relatorio_2_Guiamento_Massa_Ponto/` — point-mass horizontal guidance (two MANSUP cases)
3. `03_Relatorio_3_DATCOM_6DOF/` — aerodynamic database (DATCOM), CG/inertia, 6DOF dynamics
4. `04_Relatorio_4_Autopilotos/` — attitude & acceleration autopilots (root-locus design)
5. `05_Projeto_Integrado_Final/` — consolidated report, HTML presentation, oral-exam prep

Stages are sequential: each consumes outputs of the previous one. The aerodynamic database `M_aed.mat` is generated in stage 3 and **copied** into the `code/` folders of stages that need it — the same data file is intentionally duplicated across stages, not shared by reference.

## MATLAB code conventions

The 6DOF and autopilot code follows a fixed data-flow pattern. Understanding it is the key to reading any of the stage-3/4 scripts:

- `DadosMissil.m` returns a struct **`D`** holding all missile parameters.
- `DadosCGInercia(D)` takes `D` and returns it augmented with CG and inertia fields.
- `DadosControle.m` adds autopilot/control parameters.
- `CondLanc*.m` (`CondLanc.m`, `CondLanc6DOF.m`) returns a launch-condition struct **`C`**.
- `M_aed.mat` is the aerodynamic coefficient database, loaded with `load M_aed.mat` and consumed by the Simulink models (referenced via `D.Cmap`).
- Simulink models (`.slx` / `.mdl`) are run from a driver script via `sim('Model.slx')`; results are post-processed by a `Salva*`/`Save*` script into a struct **`S`**, then plotted by a `plot*`/`Plot*` script and saved to `.mat`.

So a typical single-run script is: build `D` → augment with CG/inertia/control → build `C` → `load M_aed.mat` → `sim(...)` → save → plot.

### Stage entry points (run these in MATLAB)

- Stage 1: `01_.../code/dimensionamento_exocet.m`, then validate range/velocity in `SimX.mdl`
- Stage 2: `02_.../code/simulink_delivery/run_mansup_cases.m` (calls `run_mansup_case(1)` and `(2)`; driver `cd`s to its own folder via `mfilename('fullpath')`)
- Stage 3 aero: `03_.../code/01_Aerodinamica_RunDatcom2/run_exocet_datcom.m` → `Coef2Mat.m` / `DATCOMreader.m` convert DATCOM `coeficientes.dat` into `M_aed.mat`; figures via `export_exocet_aero_plots_en.m`
- Stage 3 dynamics: `03_.../code/02_Dinamica6DOF/VooUnico.m` (single 6DOF flight)
- Stage 4: `04_.../code/ProjRLocus_antiship.m` — adapted from the course's `ProjRLocus.m`; produces `autopiloto.mat` / `autopiloto_antiship.mat` and figures. `FTransDin.m`, `calcula_coef.m`, `DadosControle.m`, `Autopiloto.slx` are kept from the course materials.

### Gotchas

- **Hardcoded Windows paths**: several scripts contain absolute paths like `C:\Users\mathe\...` for figure output dirs (e.g. `VooUnico.m`, the `outdir` in plot scripts). These will break on this macOS checkout — update or override the output directory before running.
- `Misdat.exe` (stage 3) is the DATCOM runner kept for the local Windows workflow; it cannot run on macOS. The committed `coeficientes.dat` / `M_aed.mat` are the already-generated outputs, so DATCOM does not need re-running to use downstream stages.
- Several `.m` files are duplicated across stages (`DadosMissil.m`, `DadosCGInercia.m`, `atmosisa.m`, `M_aed.mat`) — they are per-stage copies and may differ between stages. Edit the copy inside the stage you are working on, not a sibling.

## LaTeX reports

Each `report/` has `main.tex` including files from `sections/`. Build with the standard toolchain (`latexmk -pdf main.tex` or `pdflatex` ×2). Build artifacts (`*.aux`, `*.log`, `slprj/`, `*.slxc`, `*.asv`) are gitignored.
