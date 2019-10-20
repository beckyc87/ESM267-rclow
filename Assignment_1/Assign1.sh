#Becky Clow

#Goal of script
	#uses GDAL/OGR tools to create a Santa Barbara county subset of a MODIS satellite image
	#OGR to cut out SB and reproject into NAD83 CA Albers
	#GDAL reproject and cut tiff

# shows the commands being run
	#
set -x

#create an output folder
	# -p limits overwriting if already exists
mkdir -p output

#look at the shapefile information
ogrinfo -al -so tl_2018_us_county/tl_2018_us_county.shp

#reproject counties raster shapefile into NAD83 CA Albers
	#input = tl_2018_us_county.shp; output =output/Albers_counties.shp
ogr2ogr -t_srs EPSG:3310 output/Albers_counties.shp tl_2018_us_county/tl_2018_us_county.shp

#check that the projection in CA Albers
ogrinfo -al -so output/Albers_counties.shp

#Clip counties shapefile to only SB county
	#input = output/Albers_counties.shp; output = output/SB_county.shp
ogr2ogr -where "name='Santa Barbara'" output/SB_county.shp output/Albers_counties.shp

#Now reproject amd clip the Tiff MODIS file to CA Albers and SB county

#Reproject MODIS Tiff file using gdalwarp into CA Albers
	#input = MODIS/crefl2_A2019257204722-2019257205812_250m_ca-south-000_143.tif; output = output/MODIS_Albers.tif
gdalwarp -t_srs EPSG:3310 MODIS/crefl2_A2019257204722-2019257205812_250m_ca-south-000_143.tif output/MODIS_Albers.tif

#cut and crop MODIS file to SB_county.shp
	#format -> -cutline Input.shp -crop_to_cutline -dstalpha Input.tif Output.tif
	#Input.shp = roi SB county; Input.tif = thing to be cut; Output.tif = File cut MODIS output
gdalwarp -cutline output/SB_county.shp -crop_to_cutline -dstalpha output/MODIS_Albers.tif output/SB_County_Final.tif