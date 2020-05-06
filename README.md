# Y-STR Kit 

## About
Y-STR Kit will analyse .BAM raw data file or VCF files and outputs in HTML file format with all Y-STR values. It supports build 37 (hg19). If you are selecting VCF file, it must have SNPs/indels and all confident sites (not just the variants). Currently supports FTDNA 111 Y-STR Markers. Pre-built binaries are available in [releases](https://github.com/fiidau/Y-STR_Kit/releases/latest).

The tool provides the following output,
- Y-STR_Report.html - *Output HTML Report*
- bam_chrY.vcf.gz - *VCF output with Indels, SNPs and all confident sites.*

## Usage
Extract the download and click 'Y-STR Kit UI.exe'. Select the .BAM or VCF file and click ' Analysis'. After clicking ''Execute', a command prompt will automatically open and start executing series of commands. After a few minutes to several hours, the output will be available inside a subfolder called 'out'.

## Configuration Guide
[Y-STR_Kit_Guide.pdf](Y-STR_Kit_Guide.pdf)

## License
- Source in this repository - MIT License
- Genome Analysis Tool Kit -  Non commercial License.
- Cygwin - GNU GPL v3 

## References:

- *Li H.*, Handsaker B.*, Wysoker A., Fennell T., Ruan J., Homer N., Marth G., Abecasis G., Durbin R. and 1000 Genome Project Data Processing Subgroup (2009) The Sequence alignment/map (SAM) format and SAMtools. Bioinformatics, 25, 2078-9. [PMID: 19505943]*
- *McKenna A, Hanna M, Banks E, Sivachenko A, Cibulskis K, Kernytsky A, Garimella K, Altshuler D, Gabriel S, Daly M, DePristo MA (2010). The Genome Analysis Toolkit: a MapReduce framework for analyzing next-generation DNA sequencing data. Genome Res. 20:1297-303. [Pubmed]*

## Change Log 
Version 1.1
- Bug Fix - Unable to load BAM from folders with spaces fixed.

Version 1.0
- FTDNA 111 Y-STR Markers
