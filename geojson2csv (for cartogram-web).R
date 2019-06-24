library(rgdal)

# Note: This R script is optimised for maps from GADM

# CHANGE GEOJSON FILE NAME HERE
file = "aus_map.json"

# CHANGE NAME OF THE REGION NAME PROPERTY HERE
# IF MAP FROM GADM, DON'T CHANGE
nameproperty = "STATE_NAME"


########################################################################################

# Imports json file
cat("Loading geojson file ........ \n")
feature_collection <- readOGR(dsn = file, stringsAsFactors = FALSE)

file_name = gsub("\\..*$", '', file)

if((is.null(feature_collection$name[1]) == FALSE || is.null(feature_collection$NAME_1[1]) == FALSE || is.null(eval(parse(text = paste0("feature_collection$", nameproperty, "[1]")))) == FALSE) == FALSE){
  cat("Error: Unable to find region name property. Please check the geojson file and amend the variable \"nameproperty\".")
}else{
  if(is.null(feature_collection$NAME_0[1]) == FALSE){
    country = feature_collection$NAME_0[1]
    cat("\nImported ", file, ": map data for ", country, "\n", sep = '')
    rm(country)
  }else{
    cat("\nImported map data from ", file,"\n", sep = '')
  }
  
  # Finds "NAME_1" property for each region and saves it as region_name
  if(is.null(feature_collection$name[1]) == FALSE){
    region_name = feature_collection$name
  }else if(is.null(feature_collection$NAME_1[1]) == FALSE){
    region_name = feature_collection$NAME_1
  }else{
    eval(parse(text = paste0("region_name = feature_collection$", nameproperty)))
  }
  
  # Creates blank vectors for the region order, region id and region data (Region order is a temp vector)
  region_order = seq(1, length(feature_collection), 1)
  region_id = rep('', length(feature_collection))
  region_data = rep('', length(feature_collection))
  
  # Creates data frame 
  df = data.frame(region_order, region_id, region_data, region_name)
  colnames(df) = c("Region.Order", "Region.Id", "Region.Data", "Region.Name")
  
  # Sorts data frame according to region name and makes sure that region id will also follow that order
  df = df[order(region_name),]
  df$Region.Id = as.character(seq(1, length(feature_collection), 1))
  df = df[order(df$Region.Order),]
  region_id = df$Region.Id
  df$Region.Order = NULL
  df = df[order(df$Region.Name),]
  
  # Creates cartogram_id property
  feature_collection@data$cartogram_id = region_id

  # Finds "HASC_1" property, extracts the region abbreviation and saves in the data frame
  if(is.null(feature_collection$HASC_1[1]) == FALSE){
    region_abbreviation = feature_collection$HASC_1
    region_abbreviation = gsub("^.*\\.", '', region_abbreviation)
    df$Region.Abbrievation = region_abbreviation
    rm(region_abbreviation)
  }
  
  # Finds "GID_0" property for the 1st region (i.e. country acronym) and saves it as country
  if(is.null(feature_collection$GID_0[1]) == FALSE){
    country_gid = feature_collection$GID_0[1]
    country_gid = tolower(country_gid)
    # Exports the csv file. Automatically names file as "[country acronym]_data".csv
    write.csv(df, file = paste(country_gid, "_data.csv", sep = ''), row.names=FALSE)
    cat("Exported", paste(country_gid, "_data.csv", sep = ''), "\n")
    jsonfile = paste(country_gid, "_processedmap.json", sep = '')
    rm(country_gid)
  }else{
    write.csv(df, file = paste(file_name, "_data.csv", sep = ''), row.names=FALSE)
    cat("Exported", paste(file_name, "_data.csv", sep = ''), "\n")
    jsonfile = paste(file_name, "_processedmap.json", sep = '')
  }
  if (file.exists(jsonfile)) {
    file.remove(jsonfile)
  }
  cat("Exporting geojson file ........ \n")
  writeOGR(feature_collection, dsn = jsonfile, layer="", driver="GeoJSON")
  cat("Exported", jsonfile, "\n")
  
  if (is.null(feature_collection@bbox) == FALSE){
    bbox = paste(feature_collection@bbox[1],feature_collection@bbox[2],feature_collection@bbox[3],feature_collection@bbox[4],sep=", ")
    jsontxt = readLines(jsonfile)
    jsontxt[3] = paste("\"bbox\": [", bbox  , "],", sep = ' ')
    file.remove(jsonfile)
    writeLines(jsontxt, jsonfile, sep = "\n")
    cat("Added in bbox information.\n")
    rm(bbox)
    rm(jsontxt)
  }else{
    cat("Error: geojson file does not contain bbox information. Cartogram generator requires bbox information.\n")
  }
  
  # Removes variables
  rm(df, region_data, region_id, region_name, jsonfile, region_order)
}
rm(feature_collection, file_name, file, nameproperty)
cat("\nAll done.\n")
