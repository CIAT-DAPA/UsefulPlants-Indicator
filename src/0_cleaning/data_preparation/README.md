
# Data Preparation 

## Description

This part of the code was designed to read, clean and integrate specifically three sources of biodiversity data: Genesys-PGR, GBIF.org and the CWR Database.

This code is divided in three subprograms that can be run independently and refers to three different phases of the data preparation:

### Normalize: 

- transform each data source to a unique format with the attributes of interest.
- normalize taxa using the GBIF species API https://www.gbif.org/developer/species
- select records that belongs to the listed target taxa.
- select records identified at species level or lower.
- makes integration by interpreting the different values from the sources to common standard values such country code, type (G or H), latitude and longitude.
- ignores records with geospatial issues tagged from source.
- export un-useful records with the tag of the issue found on it.


### Nativeness

Marks the record as native or cultivated according to the country on with it's documented and the list of taxa their contries on which they are native.

### Mazenisizer

Generate outputs for facilitate the use of the date in Maxent, and counts for GAP analysis.

## Use

### Install Java

Install Java verison 8 or higher as recommended in the Oracle Website according to your OS.


https://www.java.com/en/download/help/download_options.xml


### Obtain the distributable version

For obtaining the distributable JAR files you have two options:

1. Download from the following links and jump to _Prepare working directory section_

[maxenisizer-jar-with-dependencies.jar](https://ciat-dapa.github.io/UsefulPlants-Indicator/downloads/maxenisizer-jar-with-dependencies.jar)

[nativeness-jar-with-dependencies.jar](https://ciat-dapa.github.io/UsefulPlants-Indicator/downloads/nativeness-jar-with-dependencies.jar)

[normalizer-jar-with-dependencies.jar](https://ciat-dapa.github.io/UsefulPlants-Indicator/downloads/normalizer-jar-with-dependencies.jar)

2. Build by your own using Maven using the following instructions.

#### Install Maven

Install Maven version 3.5.0 or higher following instructions in https://maven.apache.org/install.html. Configure installation in system PATH is recommended.

#### Generate executable JAR using Maven

##### Select code folder

Select the project folder on which the `data_preparation` code is

```cd UsefulPlants-Indicator/src/0_cleaning/data_preparation```

##### Build the code and make the distributable JARs

In one single line, build the code using Maven with the `package` build phase:

```mvn package```

Example running deployment command:

![image](https://user-images.githubusercontent.com/3705866/48435493-a9f80500-e74a-11e8-82e0-0edc0732716e.png)

Sucess deployment:

![image](https://user-images.githubusercontent.com/3705866/48435609-ef1c3700-e74a-11e8-88f9-073d753f0126.png)

##### Check JAR files

Check in the `target` folder the generation of the three JAR files

```cd UsefulPlants-Indicator/src/0_cleaning/data_preparation/target```

This three JAR files will be copied in the working folder

```
target/
├── maxenisizer-jar-with-dependencies.jar
├── nativeness-jar-with-dependencies.jar
├── normalizer-jar-with-dependencies.jar
```

### Prepare working directory

The working directory is location in disk on which you want to run the `data_preparation`. In this step, the idea is to achieve the the following directory structure and files:


```
working/
├── inputs/
│   ├── cwr.csv
│   ├── gbif.csv
│   └── genesys.csv
├── resources
│   ├── centroids.csv
│   ├── nativeness.csv
│   └── taxa.csv
├── config.properties
├── maxenisizer-jar-with-dependencies.jar
├── nativeness-jar-with-dependencies.jar
├── normalizer-jar-with-dependencies.jar
└── run.bat

```

### Organize inputs data

Decompress the source input files in order to organize the input folder

- decompress `gbif.zip`
- decompress `genesys.zip`
- decompress `cwr.zip`

The `input` folder should look like this:

```
working/
├── inputs/
    ├── cwr.csv
    ├── gbif.csv
    └── genesys.csv
```


### Organize resource data


The `resource` folder should look like this:

```
working/
├── resources/
    ├── centroids.csv
    ├── nativeness.csv
    └── taxa.csv
```

### Organize files for execution

Organize the `.jar` files you got in the previous section _Obtain the distributable version_.

For windows users, there is an additional file `run.dat` that will run the `.jar` files in the correct order.

The excutable files hould look like this:

```
working/
├── maxenisizer-jar-with-dependencies.jar
├── nativeness-jar-with-dependencies.jar
├── normalizer-jar-with-dependencies.jar
└── run.bat
```

### Configure

In the file `config.properties` you can configure input files to determinate where they should be read from and output file to determinate where they should be exported to:

The deafult configuration in the file ins the following, and all the properties in this file are required.


```Properties
data.gbif=inputs/gbif.csv
data.genesys=inputs/genesys.csv
data.cwr=inputs/cwr.csv
resource.nativeness=resources/nativeness.csv
resource.targettaxa=resources/taxa.csv
resource.centroids=resources/centroids.csv
file.normalized=outputs/normalized.csv
file.native=outputs/native.csv
path.counts=outputs/gap_analysis
path.raw=outputs/parameters/occurrences/raw
file.taxonfinder.summary=outputs/taxonfinder.csv
file.counts.summary=outputs/counts.csv
file.data.trash=outputs/trash.csv
file.taxa.matched=temp/taxa_matched.csv
file.taxa.unmatched=temp/taxa_unmatched.csv
```

The description for each of the properties is the following

|Property|Description|
|---|---|
|data.gbif| Source file of GBIF.org data|
|data.genesys| Source file of Genesys-PGR data|
|data.cwr| Source file of CWR data|
|resource.nativeness| List of taxa and their countries where they are native|
|resource.targettaxa| List of taxa of the study|
|resource.centroids| List of the places centroids in different administrative levels|
|file.normalized| Output file for the normalization phase |
|file.native| Output file for the nativeness phase|
|path.counts| Output folder for the counts for the maxenisizer phase|
|path.raw| Output folder for the records for the maxenisizer phase|
|file.taxonfinder.summary| Output summary file of the counts of taxa that matched and didn't match with the GBIF Species API|
|file.counts.summary| Output summary of all count by specie|
|file.data.trash| Output of records that weren't useful and the tagged issue|
|file.taxa.matched| Output of original taxa that matched the GBIF Species API, if you don't delete it manually, then this file is reused in each run to avoid massive call to GBIF services.|
|file.taxa.unmatched| Output of original taxa that didn't match the GBIF Species API, if you don't delete it manually, then this file is reused in each run to avoid massive call to GBIF services.|


### Run

Using java command

```
java -jar normalizer-jar-with-dependencies.jar
java -jar nativeness-jar-with-dependencies.jar
java -jar maxenisizer-jar-with-dependencies.jar
```

Fow Windows users, just need to execute the `run.bat` file, and it will run in the right order.
