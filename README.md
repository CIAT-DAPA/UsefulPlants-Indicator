# An indicator of the conservation status of useful wild plants

Project Management and method code for "Comprehensiveness of conservation of useful wild plants: an operational indicator for biodiversity and sustainable development targets"

Khoury CK, Amariles D, Soto JS, Diaz MV, Sotelo S, Sosa CC, Ramírez-Villegas J, Achicanoy HA, Velásquez-Tibatá J, Guarino L, León B, Castañeda-Álvarez NP, Dempewolf H, Wiersema JH, and Andy Jarvis (2018). Comprehensiveness of conservation of useful wild plants: an operational indicator for biodiversity and sustainable development targets. Ecological Indicators. Under review.

Khoury CK, Amariles D, Soto JS, Diaz MV, Sotelo S, Sosa CC, Ramírez-Villegas J, Achicanoy HA, León B, and JH Wiersema (2018). Data for the calculation of an indicator of the comprehensiveness of conservation of useful wild plants. Data in Brief. Under review.

Funding: Research at the International Center for Tropical Agriculture was funded by the Biodiversity Indicators Partnership, an initiative supported by UN Environment, the European Commission and the Swiss Federal Office for the Environment. The funder played no role in study design; in the collection, analysis and interpretation of data; in the writing of the report; or in the decision to submit the article for publication.

**Project Website** https://ciat.cgiar.org/usefulplants-indicator/. 

## Functions documentation standard

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
|   │   └── fcs
│   └── in_situ/
|       ├── grs
|       ├── ers
|       └── fcs
└── 3_indicator/

```

## Git branching

* **master**: only for releases, don't touch!
* **develop**: current development, changes to share with the team
* **issue##**: your current resolving issue, document first the issue

## Data files

| Folder  | File|  Description |
| ------------- | ------------- | ------------- |
| WEP  | WEP.csv  | World Economic Plants database (USDA ARS GRIN-GLOBAL Taxonomy https://npgsweb.ars-grin.gov/gringlobal/taxon/taxonomysearcheco.aspx) |
| GBIF  | gbif.zip |GBIF download of Plantae from 1950 to date (https://www.gbif.org/) |
| GENESYS  | genesys_zip | GENESYS Original occurrence records from genebanks (genebank accession records) https://www.genesys-pgr.org/welcome   |
| CWR| cwr.zip  |Crop Wild Relatives database of Global CWR Project (https://www.cwrdiversity.org/checklist/cwr-occurrences.php)   |
| COUNTRY  | countryISO.csv  |Country names, ISO 3166-1 alpha-3 and alpha-2  |

## Modeling variables sources

| Variable |  Name | Source |
| ------------- | ------------- |------------- | 
|elevation | [SRTM 90m Digital Elevation Data](http://srtm.csi.cgiar.org/) | CGIAR|
|bioclimatic variables |   [WorldClim Version2](http://worldclim.org/version2) | WordlClim|
|solar radiation| [WorldClim Version2](http://worldclim.org/version2) | WordlClim|
|wind speed| [WorldClim Version2](http://worldclim.org/version2) | WordlClim|
|water vapor pressure| [WorldClim Version2](http://worldclim.org/version2) | WordlClim|


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


