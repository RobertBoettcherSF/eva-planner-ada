# EVA Planner Ada

EVA Planner Ada is an independent Ada analogue of exploration-planning ideas:
one EVA, two walkers, stations and points of interest on an invented
south-pole-like map, walk times (including slope), walkback limits, science
coverage, a small as-flown clock, and a browser splash and console.

It is not a NASA product, not a fork of
[nasa/aegis](https://github.com/nasa/aegis), and not an official planning tool.
The site and heights are invented for this first slice; they are not lunar
mission data.

## Try the page

Version **0.2.0**. Open the splash (title and two walkers on the path) and the
console (map, timeline, coverage, and walkback) here:

[https://raw.githack.com/RobertBoettcherSF/eva-planner-ada/main/dist/index.html?v=2](https://raw.githack.com/RobertBoettcherSF/eva-planner-ada/main/dist/index.html?v=2)

JavaScript draws frames and lays out the console tables. The map and walkers
run in Ada compiled to WebAssembly. Table numbers are the same ones the native
program prints.

## What you will see

Two walkers loop lander → East Ridge → South Bench → West Notch → lander.
The sample EVA totals **11 940** seconds of planned time (about 3 hours
19 minutes) at 0.4 m/s with slope stretch. Science coverage is **5 of 6**
goals (Collect fines at Fine Soil is outside the 150 m radius). All four
stations are inside the 2000 m walkback to the lander.

## Native Linux program

```bash
gprbuild -p -P eva_plan.gpr
./bin/eva_plan_driver
```

The driver prints the timeline, coverage, and walkback tables, then an
as-flown comparison (the sample adds 120 seconds to Ridge photos and finishes
late).

## For engineers

Named bounds live in `Eva_Plan.Config` (4 stations, 8 points of interest,
16 activities, 6 goals, 2 crew). Packages: `Types`, `Geometry`, `Model`,
`Timeline`, `Terrain`, `Science`, `Execution`, and `Viz` (`SPARK_Mode` off on
Viz). Contracts use `Assertion_Policy (Check)` on the native build. A SPARK
proof pass is still later work; this tree is not a certification claim.

Rebuild the browser page with `tools/build-wasm.sh` (needs a WebAssembly Ada
toolchain). Scaffolding stays out of the visitor page itself.
