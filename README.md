### geojson2csv
This R Script reads a geojson file (either .json or .geojson) and creates a csv file containing Region ID and Region Name, which is used in the process below.
  
# Guide to downloading maps from GADM in preparation for making cartograms
![Cartogram Prep Flowchart](Images/17.png?raw=true "Cartogram Preparation Flowchart")
This is the process for preparing map data to generate cartograms.

## Table Of Contents
- [Step 1: Download map from GADM](#step-1-download-map-from-gadm)
- [Step 2: Process map in Mapshaper](#step-2-process-map-in-mapshaper)
  * [Step 2.1: Simplification](#step-21-simplification)
  * [Step 2.2: Projection](#step-22-projection)
  * [Step 2.3: Export](#step-23-export)
- [Step 3: Generate CSV and JSON file](#step-3-generate-csv-and-json-file)
    + [Errors?](#errors)
- [Optional: What if I need to remove regions?](#optional-what-if-i-need-to-remove-regions)

## Step 1: Download map from GADM
First, visit https://gadm.org/download_country_v3.html and select the country. Click on "Shapefile", which will download a zip file.

## Step 2: Process map in Mapshaper
Then, visit https://mapshaper.org/ and import the zip file.
Click on the correct layer (which should be `gadm36_[country]_**1**`), as seen in the image below:

![Mapshaper Layer Selection](Images/1.png?raw=true "Mapshaper Layer selection")

### Step 2.1: Simplification
Click on console (upper right corner) and type the following command to find out the total number of vertices.
```
$ -simplify 100% stats
```

![Mapshaper Simplify Stats](Images/2.png?raw=true "Mapshaper Simplify Stats")

The *unique coordinate locations* tells you the number of vertices. Use the following equation to calculate the percentage required.
> [percentage] = 100 * [desired no. of vertices] / [unique coordinate locations]

So, if you would like 20,000 verticies, then the percentage will be 100 * 20,000 / 1,317,405 ≈ **1.5**

Then, type the following command to execute the simplification, replacing `[percentage]` with the required percentage:
```
$ -simplify [percentage]% stats
```

![Mapshaper Simplify](Images/3.png?raw=true "Mapshaper Simplify")

### Step 2.2: Projection
You will need to know the desired projection for this map. Then, type the following command to project the map, replacing `[spatial_reference]` with your chosen spatial reference system:
```
$ -proj +init=EPSG:[spatial_reference]
```
Check to make sure that the map is projected correctly.

![Mapshaper Projection](Images/4.png?raw=true "Mapshaper Projection")

### Step 2.3: Export
Then, export the map using the following command, replacing `[country_name]` accordingly.
```
$ -o format=geojson bbox precision=0.1 [country_name]_map.json
```
## Step 3: Generate CSV and JSON file
Open `geojson2csv.r` in RStudio. Rename `file_name` accordingly. Then, click on source. In the console, it should say "Exported [country]_data.csv".

![R Script](Images/11.png?raw=true "R Script")

You will be able to find `[country]_data.csv` in your folder. Edit it using a text editor of spreadsheet program, but make sure that you save in the csv format. You can fill in the `Region Data` column with any data, such as population.

![CSV file](Images/13.png?raw=true "CSV File")

After saving, you now have your **`[country]_processedmap.json` and `[country]_data.csv` files** ready to use to generate cartograms!

![Files](Images/16.png?raw=true "Files")

#### Errors?
> If you do not have the rgdal package installed, install it using `install.packages("rgdal")`.

> If you encounter "Error in ogrListLayers(dsn = dsn) : Cannot open data source", check that the file_name is correct, and that the json file and R script are in the same folder. Also, make sure that you click Session --> Set Working Directory --> To Source File Location.

## Optional: What if I need to remove regions?
If you need to remove regions, like a small island territory that has a population of 4 people, then perform the following step between `Step 2.2: Projection` and `Step 2.3: Export`.

You should know the name of the region which you would like to remove. Then, in mapshaper's console, type in the following command, replacing `[region_name]` accordingly:
```
$ filter 'NAME_1 != "[region_name]"'
```

If successful, you should see the following message: "[filter] Retained XX of XX features"

![Mapshaper Filter](Images/15.png?raw=true "Mapshaper Filter")
