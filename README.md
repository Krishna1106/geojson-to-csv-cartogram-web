# Guide to processing maps from GADM to make cartograms
![Cartogram Prep Flowchart](Images/main.png?raw=true "Cartogram Preparation Flowchart")
This is the process for preparing map data to generate cartograms.

## Table Of Contents
- [Step 1: Download map from GADM](#step-1-download-map-from-gadm)
- [Step 2: Process map in Mapshaper](#step-2-process-map-in-mapshaper)
  * [Step 2.1: Projection](#step-21-projection)
  * [Step 2.2: Simplification](#step-22-simplification)
  * [Step 2.3: Clipping](#step-23-clipping)
  * [Step 2.4: Export](#step-24-export)
- [Step 3: Generate CSV and JSON file](#step-3-generate-csv-and-json-file)
    + [Errors?](#errors)
- [Optional: What if my map is NOT from GADM?](#optional-what-if-my-map-is-not-from-gadm)
- [Optional: What if I need to remove regions?](#optional-what-if-i-need-to-remove-regions)

## Step 1: Download map from GADM
First, visit https://gadm.org/download_country_v3.html and select the country. Click on "Shapefile", which will download a zip file.

## Step 2: Process map in Mapshaper
Then, visit https://mapshaper.org/ and import the zip file.
Click on the correct layer (which should be `gadm36_[country]_1`), as seen in the image below:

![Mapshaper Layer Selection](Images/jpn1.png?raw=true "Mapshaper Layer selection")

### Step 2.1: Projection
You will need to know the desired projection for this map. Then, click on console (upper right corner) and type the following command to project the map, replacing `[spatial_reference]` with your chosen spatial reference system:
```
$ -proj +init=EPSG:[spatial_reference]
```
Check to make sure that the map is projected correctly.

![Mapshaper Projection](Images/jpn2.png?raw=true "Mapshaper Projection")

### Step 2.2: Simplification
Type the following command to find out the total number of vertices.
```
$ -simplify 100% stats
```

![Mapshaper Simplify Stats](Images/jpn3.png?raw=true "Mapshaper Simplify Stats")

The *unique coordinate locations* tells you the number of vertices. Use the following equation to calculate the percentage required.
> [percentage] = 100 * [desired no. of vertices] / [unique coordinate locations]

So, if you would like 50,000 verticies, then the percentage will be 100 * 50,000 / 1,317,405 ≈ **4**

Then, type the following command to execute the simplification, replacing `[percentage]` with the required percentage:
```
$ -simplify [percentage]% stats
```

![Mapshaper Simplify](Images/jpn4.png?raw=true "Mapshaper Simplify")

### Step 2.3: Clipping
Now, type in the following command to download the SVG file.
```
$ -o format=svg
```
![SVG Export](Images/jpn5.png?raw=true "SVG Export")

Open the SVG file in Inkscape and check whether the bounding box is sufficiently tight. If yes, proceed to [Step 2.4: Export](#step-24-export). If not, continue the following steps.
![Inkscape](Images/jpn6.png?raw=true "Inkscape")

As we can see here, ...

In Mapshaper, type the following command:
```
$ info
```
You will see a bunch of information pop up. Scroll to the **correct layer** (make sure it is the right one!) and copy the `bounds` information.

![Info](Images/jpn7.png?raw=true "Info")
![Info](Images/jpn8.png?raw=true "Info")

Then, type the following command (Note that there are only 2 spaces):
```
$ -clip remove-slivers bbox=[paste bounds here]
```
For example, for Japan, we would get this:
```
$ -clip remove-slivers bbox=-819424.5537347307,-198081.9783434747,2375994.3457566854,2224098.3370094863
```
Before pressing enter, you need to edit the command. `-clip` will remove everything that is outside the specified bbox. The bbox is in the format `xmin, ymin, xmax, ymax`. Since the extra space is in the right side of the map, we need to reduce xmax. We can check what to reduce it to by placing our cursor over the map. Place your cursor to the rightmost edge which you wish to retain. Read the x value, give a bit of allowance, and put it in the command, replacing the old value.

![Clip](Images/jpn9.png?raw=true "Clip")

For example, we would change it to this:
<pre>
$ -clip remove-slivers bbox=-819424.5537347307,-198081.9783434747,<b>1220000</b>,2224098.3370094863
</pre>
Then, download the SVG file and check the bounding box again. Repeat as necessary. Once it is satisfactory, proceed to the next step.
```
$ -o format=svg
```

![Inkscape](Images/jpn10.png?raw=true "Inkscape")

### Step 2.4: Export
Export the map using the following command, replacing `[country_name]` accordingly.
```
$ -o format=geojson bbox precision=0.1 [country_name]_map.json
```
## Step 3: Generate CSV and JSON file
Open `geojson2csv.r` in RStudio. Make sure that the GeoJSON file which you just downloaded is in the same folder as `geojson2csv.r`. Rename `file_name` accordingly. Then, click on source. In the console, it should say "Exported [country]_processedmap.json" and "Exported [country]_data.csv".

![R Script](Images/11.png?raw=true "R Script")

You will be able to find `[country]_data.csv` in your folder. Here, you should check whether the region names are accurate. Open the csv file using a text editor or spreadsheet program, and make sure that you save in the csv format subsequently. Fill in the `Region.Data` column with something other than population.

![CSV file](Images/13.png?raw=true "CSV File")

After saving, you now have your **`[country]_processedmap.json` and `[country]_data.csv` files** ready to use to generate cartograms!

![Files](Images/16.png?raw=true "Files")

Please proceed to the [Add Map Guide](https://github.com/jansky/cartogram-web/blob/master/doc/addmap/addmap.md) to continue the process.

#### Errors?
> If you do not have the rgdal package installed, install it using `install.packages("rgdal")`.

> If you encounter "Error in ogrListLayers(dsn = dsn) : Cannot open data source", check that the file_name is correct, and that the json file and R script are in the same folder. Also, make sure that you click Session --> Set Working Directory --> To Source File Location.

## Optional: What if my map is NOT from GADM?


## Optional: What if I need to remove regions?
If you need to remove regions, like a small island territory that has a population of 4 people, then perform the following step between `Step 2.2: Projection` and `Step 2.3: Export`.

You should know the name of the region which you would like to remove. Then, in mapshaper's console, type in the following command, replacing `[region_name]` accordingly:
```
$ filter 'NAME_1 != "[region_name]"'
```

If successful, you should see the following message: "[filter] Retained XX of XX features"

![Mapshaper Filter](Images/15.png?raw=true "Mapshaper Filter")
