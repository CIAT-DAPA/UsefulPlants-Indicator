
## Description

This part of the code was designed to read, clean and integrate specifically three sources of biodiversity data: Genesys-PGR, GBIF.org and the CWR Database.

### Obtain the distributable version

1.
2.

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

The working directory is location in disk on which you want to run the `data_preparation`




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
├── resources
│   ├── centroids.csv
│   ├── nativeness.csv
│   └── taxa.csv
├── config.properties
├── maxenisizer-jar-with-dependencies.bat
├── nativeness-jar-with-dependencies.bat
├── normalizer-jar-with-dependencies.bat
├── maxenisizer-jar-with-dependencies.jar
├── nativeness-jar-with-dependencies.jar
├── normalizer-jar-with-dependencies.jar
├── run.bat

    

### Decompress data

- decompress `gbif.zip`
- decompress `genesys.zip`
- decompress `cwr.zip`

### Run

Run `run.bat`
