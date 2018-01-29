# Aichi13
Project Management of the Aich13 Indicators for non-cultivated plant species with economical use

## Fucntions documentation standard

```r
# Function description
# @param (type) parameter description
# @return (type) result description
```

## File names standard
* lower case
* no spaces, only underlines

## File structure

```
src/
├── 0_cleaning/
├── 1_modeling/
│   ├── 1_1_maxent/
|   │   ├── calibration
|   │   ├── run
|   │   └── evaluation
│   └── 1_2_alternatives
|       ├── ca50
|       ├── gdm
|       └── convexhull
├── 2_gap_analysis/
│   ├── ex_situ/
|   │   ├── ca50_g
|   │   ├── srs
|   │   ├── grs
|   │   ├── ers
|   │   └── fps
│   └── in_situ/
|       ├── grs
|       ├── ers
|       └── fps
└── 3_indicator/

```

## Git branching

* **master**: only for releases, don't touch!
* **develop**: current development, changes to share with the team
* **issue##**: your current resolving issue, document first the issue

## Variables sources

| Variable |  Name | Source |
| ------------- | ------------- |------------- | 
|elevation | [SRTM 90m Digital Elevation Data](http://srtm.csi.cgiar.org/) | CGIAR|
|bioclimatic variables |   [WorldClim Version2](http://worldclim.org/version2) | WordlClim|
|solar radiation| [WorldClim Version2](http://worldclim.org/version2) | WordlClim|
|wind speed| [WorldClim Version2](http://worldclim.org/version2) | WordlClim|
|water vapor pressure| [WorldClim Version2](http://worldclim.org/version2) | WordlClim|

## Data files

| Folder  | File|  Description |
| ------------- | ------------- | ------------- |
| WEP  | WEP.csv  | World Economic Plants databse |
| GBIF  | gbif.zip |GBIF download of Plantae from 1950 to date |
| GENESYS  | genesys_zip | GENESYS Original occurrence records   |
| CWR| cwr.zip  |Crop Wild Relatives database of CIAT   |
| COUNTRY  | countryISO.csv  |Country names, ISO 3166-1 alpha-3 and alpha-2  |


## Modeling parameters

**Principal modeling**: maxent2

**Alternative modeling**: CA50

**Resolution**: 2.5 arc minutes

K=5 mean as final evaluation

## Modeling evaluation

AUC mean >= 0.7

SDAUC < 0.15

ASD15 <= 10%

CAUC >= 0.4


