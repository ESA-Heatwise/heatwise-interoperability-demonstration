# Heatwise Interoperability Demonstration

This repository contains the source for the technical note that showcases the software deliverables produced by High-resolution Enhanced Analysis Tool for Urban Hyperspectral and Infrared Satellite Evaluation (HEATWISE)
and their adherence to interoperability standards.
All software is provided as Earth Observation Application Package (EOAP) as described by the [OGC Best Practice for Earth Observation Application Package](http://www.opengis.net/doc/BP/eoap/1.0).
An EOAP consists of a Common Workflow Language (CWL) document which describes the inputs, outputs and processing steps of the software, with software made available in a container image referenced
in the CWL document.

Heatwise is part of the European Space Agency's (ESA) [Sentinel Users Preparation](https://sup.apex.esa.int/en) (SUP) programme.

## Installation

To run the demonstration, the project must first be installed.
The technical note uses [pixi](https://pixi.prefix.dev/latest/) to manage packages and tools.
Everything used in this demonstration, including the tools in @tbl-tools are installed with the pixi environment.

Make sure you are using [`pixi run`](https://pixi.prefix.dev/latest/reference/cli/pixi/run/#pixi-run) or have the environment activated (e.g., using [`pixi shell`](https://pixi.prefix.dev/latest/reference/cli/pixi/shell/)) to run any of the scripts or commands listed in this technical note.

The demonstration itself activates the environment using [`pixi shell-hook`](https://pixi.prefix.dev/latest/reference/cli/pixi/shell-hook/) to avoid lauching a new cell.

First, clone the git repository and navigate to it:

```bash
git clone https://github.com/ESA-Heatwise/heatwise-interoperability-demonstration
cd heatwise-interoperability-demonstration
```

The remaning steps assume that they are performed from within the root of the repository.

To install the pixi environment, run

```bash
pixi install --all
```

Finally, activate it

```bash
pixi shell
```

## Staging

The demonstration requires input datasets on which to run the processors.
Each of the HEATWISE software products comes with its own example input data.

The inputs are staged by cloning the source code repositories, containing the example inputs.
This is automated by a script `stage.sh`,

```bash
which stage.sh
```

and available as a [pixi task](https://pixi.prefix.dev/latest/getting_started/#tasks). The demonstration is set up by running:

```bash
pixi run stage
```

This populates the `software`, `application-packages` and `inputs` directories under the project root. Later, outputs of the processors will be collected in the `outputs` directory.

```bash
tree -n -L 1 {software,inputs,application-packages}
```

## Rendering

This technical note is implemented using the [Quarto](https://quarto.org/) framework. Using Quarto, the same content can be rendered in different formats.

In the following, instructions are given to render the demonstration as Jupyter Notebooks for interactive demonstration as well as website and PDF formats.
Quarto is based on `pandoc` and supports a number of [further output formats](https://quarto.org/docs/output-formats/all-formats.html). Rendering to other formats may require additional steps not documented here.

> Please note that you must have followed the installation and staging instructions before rendering.

The supported render targets are available as `pixi` tasks. See `pixi.toml` for the corresponding quarto commands.

### Website

This generates a HTML website in the `_site` directory.

```{.bash}
pixi run render-website
```

For development you may prefer to use

```{.bash}
pixi run preview
```

to start a live server that updates with changes to the source files.

### PDF

This generates a single PDF document in the `_book_pdf` directory.

```bash
pixi run render-pdf
```


### Notebooks


This command generates a Jupyter Notebook to demonstrate interoperability of each of the software products. This configuration does not render the rest of the documentation (like these instructions).
The notebooks will be avaiable in the `_notebooks` directory.

```bash
pixi run render-notebooks
```

The Jupyter server can be started using:

```bash
pixi run show-notebooks
```
.

## Cleanup

Staged software, inputs and outputs can be cleared using the `clean` command.
You will have to run `stage` again as described above to render the documentation or perform the demonstration.

> Please note that this command will delete any processing outputs! Use with care.

```bash
pixi run clean
```

The rendered documentation can be cleared with the `clean-docs` command.

```bash
pixi run clean-docs
```
