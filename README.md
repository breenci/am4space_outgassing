# am4space_outgassing
Note: This reposistry is in the early stages of development

## Project Outline
Additive manufacturing (AM) offers substantial benefits to astronomical instrumentation design, particularly in optimizing geometry for reduced mass and heat transfer applications.  However, uncertainty over material properties can hinder its usage.  

This project, a part of the wider UKATC AM4Space research program, seeks to characterize the outgassing properties of structural materials in a way which is useful to design engineers.

This reposistry contains the MATLAB code used to capture and store data, calculate outgassing results, and visualise results.

## Publications

A discription of our experimental method and first results were presented at the [2022 SPIE conference](https://www.spiedigitallibrary.org/conference-proceedings-of-spie/12188/121882I/Outgassing-properties-of-additively-manufactured-aluminium/10.1117/12.2627331.full?SSO=1)

The same experimental methods was used to analyse outgassing rates of samples created using wire arc additive manufacturing (WAAM). These result were presented at the SPIE 2023 Optics and Photonics conference. A conference paper is in preparation. The usage example below relates to this work.

## Usage

An example of the raw experimental output file can be seen in the file `OG_data/raw_ouput_examples/20230803_131526_WAAM1_Cube.txt`. This file contains the raw data from a single measurement of a WAAM sample. The measurement captures chamber pressures and temperatures over the duration of the measurement. Temperature is measured using a thermocouple at 4 locations on each chamber. See the 2022 SPIE paper for more details on the experimental setup.

Outgassing rates are calculated using the MATLAB script `outgassing.m`. This script takes the raw data file for the sample plus a background measurement as inputs. The background measurement is used to remove the effects of outgassing from the chamber itself. The background measurement should be taken with the chamber empty. The script outputs a .mat file containing the outgassing rates for the duration of the measurement as well as identifying information for the sample, and specific outgassing rates at 1hr and 10hrs. It also plots the outgassing rates, temperature, and pressure over time.

The folder `OG_data/SPIE_paper_data/` contains the output files for the two experimental runs for the WAAM samples. The script `plot_outgassing.m` can be used to recreate the plot shown in the SPIE paper. It also displays the average outgassing rate at 1hr and 10hrs for each sample.

## File Naming Convention

Filenames should be in the following format:

YYYYMMDD_HHMMSS_sample-info_operator.txt

where sample info is any information about the specific measurement and operator is the operator intials. Sample info should be in the following format:

MATERIAL-ID-GEOMETRY-OTHER

For a reference measurement sample info can simply be:

REF

Examples:

20240117_132130_REF_CB.txt

20240221_090415_SICAPRINT-02-LATTICE_CB.txt

