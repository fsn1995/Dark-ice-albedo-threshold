/*
This script is used to batch export MODIS albedo data (MOD10A1) for ice covered areas in Greenland.
It also exports the minimum albedo of the summer season (June to August) for the year of interest.

Shunan Feng
shunan.feng@envs.au.dk
*/

/**
 * Intial parameters
 */

var yearOfInterest = 2019; // year of interest

var date_start = ee.Date.fromYMD(yearOfInterest, 6, 1);
var date_end = ee.Date.fromYMD(yearOfInterest, 9, 1);

// var roi = 'GrIS'; // region of interest
// var GrISRegion = ee.FeatureCollection("projects/ee-deeppurple/assets/GrISRegion");
// var aoi = GrISRegion.filter(ee.Filter.eq('SUBREGION1', roi)); // Greenland
var aoi = /* color: #ffc82d */ee.Geometry.Polygon(
  [[[-36.29516924635421, 83.70737243835941],
    [-51.85180987135421, 82.75597137647488],
    [-61.43188799635421, 81.99879137488564],
    [-74.08813799635422, 78.10103528196419],
    [-70.13305987135422, 75.65372336709613],
    [-61.08032549635421, 75.71891096312955],
    [-52.20337237135421, 60.9795530382023],
    [-43.41430987135421, 58.59235996703347],
    [-38.49243487135421, 64.70478286561182],
    [-19.771731746354217, 69.72271161037442],
    [-15.728762996354217, 76.0828635948066],
    [-15.904544246354217, 79.45091003031243],
    [-10.015872371354217, 81.62328742628017],
    [-26.627200496354217, 83.43179828852398],
    [-31.636966121354217, 83.7553561747887]]]); // whole greenland

// Display AOI on the map.
Map.centerObject(aoi, 4);
Map.addLayer(aoi, {color: 'f8766d'}, 'AOI');
// Map.setOptions('HYBRID');

var greenlandmask = ee.Image('OSU/GIMP/2000_ICE_OCEAN_MASK')
                      .select('ice_mask').eq(1); //'ice_mask', 'ocean_mask'
// var elevation = ee.Image('OSU/GIMP/DEM').select('elevation').updateMask(greenlandmask);
// var iceMask = elevation.lt(2000); // ice mask is defined as elevation < 2000 m and ice mask = 1

/*
prepare modis albedo data
*/
var mod10 = ee.ImageCollection('MODIS/061/MOD10A1')
                .select('Snow_Albedo_Daily_Tile')
                .filterDate(date_start, date_end)
                .filterBounds(aoi)
                .map(function(img) {
                  return img.updateMask(greenlandmask);
                });

var minAlbedo = mod10.min();

/*
Export data
*/

// batch export modis albedo data        
var batch = require('users/fitoprincipe/geetools:batch');
batch.Download.ImageCollection.toDrive(mod10, 'MOD10A1', {
  name: 'MOD10A1_{system_date}',
  scale: 500,
  region: aoi,
  type: 'uint8',
  crs: 'EPSG:3413',
});      
  
Export.image.toDrive({
  image: minAlbedo,
  description: 'MOD10A1_minAlbedo_'+yearOfInterest,
  scale: 500,
  region: aoi,
  crs: 'EPSG:3413',
  maxPixels: 1e13
});