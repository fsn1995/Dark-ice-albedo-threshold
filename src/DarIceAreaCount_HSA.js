/*
This script is used to generate the dark ice area of the Greenland in the summer (June, July, August) of a specific year.
The dark ice area is defined as the area with albedo < 0.451 or 0.431.
The albedo is calculated from the visible and near-infrared bands of the harmonized satellite data including Landsat 4/5/7/8, Sentinel 2.
The output is exported to Google Drive due to the computation limitation of Earth Engine.


Shunan Feng
shunan.feng@envs.au.dk
*/

/**
 * Intial parameters
 */

var yearOfInterest = 2019; // year of interest

var date_start = ee.Date.fromYMD(yearOfInterest, 6, 1);
var date_end = ee.Date.fromYMD(yearOfInterest, 9, 1);

var roi = 'GrIS'; // region of interest
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
var elevation = ee.Image('OSU/GIMP/DEM').select('elevation').updateMask(greenlandmask);
var iceMask = elevation.lt(2000); // ice mask is defined as elevation < 2000 m and ice mask = 1

/*
prepare harmonized satellite data
*/

// Function to get and rename bands of interest from OLI.
function renameOli(img) {
  return img.select(
    ['SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'QA_PIXEL', 'QA_RADSAT'], // 'QA_PIXEL', 'QA_RADSAT'
    ['Blue',  'Green', 'Red',   'NIR',   'QA_PIXEL', 'QA_RADSAT']);//'QA_PIXEL', 'QA_RADSAT';
}
// Function to get and rename bands of interest from ETM+, TM.
function renameEtm(img) {
  return img.select(
    ['SR_B1', 'SR_B2', 'SR_B3', 'SR_B4', 'QA_PIXEL', 'QA_RADSAT'], //#,   'QA_PIXEL', 'QA_RADSAT'
    ['Blue',  'Green', 'Red',   'NIR',   'QA_PIXEL', 'QA_RADSAT']); // #, 'QA_PIXEL', 'QA_RADSAT'
}
// Function to get and rename bands of interest from Sentinel 2.
function renameS2(img) {
  return img.select(
    ['B2',   'B3',    'B4',  'B8',  'QA60', 'SCL', QA_BAND],
    ['Blue', 'Green', 'Red', 'NIR', 'QA60', 'SCL', QA_BAND]
  );
}

/* RMA transformation */
var rmaCoefficients = {
  itcpsL7: ee.Image.constant([-0.0084, -0.0065, 0.0022, -0.0768]),
  slopesL7: ee.Image.constant([1.1017, 1.0840, 1.0610, 1.2100]),
  itcpsS2: ee.Image.constant([0.0210, 0.0167, 0.0155, -0.0693]),
  slopesS2: ee.Image.constant([1.0849, 1.0590, 1.0759, 1.1583])
}; // #rma

function oli2oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR'])
            .toFloat();
}

function etm2oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR'])
    .multiply(rmaCoefficients.slopesL7)
    .add(rmaCoefficients.itcpsL7)
    .toFloat();
}
function s22oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR'])
    .multiply(rmaCoefficients.slopesS2)
    .add(rmaCoefficients.itcpsS2)
    .toFloat();
}

function imRangeFilter(image) {
  var maskMax = image.lte(1);
  var maskMin = image.gt(0);
  return image.updateMask(maskMax).updateMask(maskMin);
}


/* 
Cloud mask for Landsat data based on fmask (QA_PIXEL) and saturation mask 
based on QA_RADSAT.
Cloud mask and saturation mask by sen2cor.
Codes provided by GEE official.
*/

// This example demonstrates the use of the Landsat 8 Collection 2, Level 2
// QA_PIXEL band (CFMask) to mask unwanted pixels.

function maskL8sr(image) {
  // Bit 0 - Fill
  // Bit 1 - Dilated Cloud
  // Bit 2 - Cirrus
  // Bit 3 - Cloud
  // Bit 4 - Cloud Shadow
  var qaMask = image.select('QA_PIXEL').bitwiseAnd(parseInt('11111', 2)).eq(0);
  var saturationMask = image.select('QA_RADSAT').eq(0);

  // Apply the scaling factors to the appropriate bands.
  // var opticalBands = image.select(['Blue', 'Green', 'Red', 'NIR']).multiply(0.0000275).add(-0.2);
  // var thermalBands = image.select('ST_B.*').multiply(0.00341802).add(149.0);

  // Replace the original bands with the scaled ones and apply the masks.
  return image.select(['Blue', 'Green', 'Red', 'NIR']).multiply(0.0000275).add(-0.2)
      // .addBands(thermalBands, null, true)
      .updateMask(qaMask)
      .updateMask(saturationMask);
}

// This example demonstrates the use of the Landsat 4, 5, 7 Collection 2,
// Level 2 QA_PIXEL band (CFMask) to mask unwanted pixels.

function maskL457sr(image) {
  // Bit 0 - Fill
  // Bit 1 - Dilated Cloud
  // Bit 2 - Unused
  // Bit 3 - Cloud
  // Bit 4 - Cloud Shadow
  var qaMask = image.select('QA_PIXEL').bitwiseAnd(parseInt('11111', 2)).eq(0);
  var saturationMask = image.select('QA_RADSAT').eq(0);

  // Apply the scaling factors to the appropriate bands.
  // var opticalBands = image.select('SR_B.').multiply(0.0000275).add(-0.2);
  // var thermalBand = image.select('ST_B6').multiply(0.00341802).add(149.0);

  // Replace the original bands with the scaled ones and apply the masks.
  return image.select(['Blue', 'Green', 'Red', 'NIR']).multiply(0.0000275).add(-0.2)
      // .addBands(thermalBand, null, true)
      .updateMask(qaMask)
      .updateMask(saturationMask);
}


/**
 * Function to mask clouds using the Sentinel-2 QA band
 * @param {ee.Image} image Sentinel-2 image
 * @return {ee.Image} cloud masked Sentinel-2 image
 * archived after updating to Cloud Score+
 */
// function maskS2sr(image) {
//   var qa = image.select('QA60');

//   // Bits 10 and 11 are clouds and cirrus, respectively.
//   var cloudBitMask = 1 << 10;
//   var cirrusBitMask = 1 << 11;
//   // 1 is saturated or defective pixel
//   var not_saturated = image.select('SCL').neq(1);
//   // Both flags should be set to zero, indicating clear conditions.
//   var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
//       .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

//   // return image.updateMask(mask).updateMask(not_saturated);
//   return image.updateMask(mask).updateMask(not_saturated).divide(10000);
// }

/**
 * Function to mask clouds using the Cloud Score+
 */
// Cloud Score+ image collection. Note Cloud Score+ is produced from Sentinel-2
// Level 1C data and can be applied to either L1C or L2A collections.
var csPlus = ee.ImageCollection('GOOGLE/CLOUD_SCORE_PLUS/V1/S2_HARMONIZED');

// Use 'cs' or 'cs_cdf', depending on your use case; see docs for guidance.
var QA_BAND = 'cs'; // I find'cs' is better than 'cs_cdf' because it is more robust but may mask out more clear pixels though

// The threshold for masking; values between 0.50 and 0.65 generally work well.
// Higher values will remove thin clouds, haze & cirrus shadows.
var CLEAR_THRESHOLD = 0.65;

function maskS2sr(image) {
  // 1 is saturated or defective pixel
  var not_saturated = image.select('SCL').neq(1);
  return image.updateMask(image.select(QA_BAND).gte(CLEAR_THRESHOLD))
              .updateMask(not_saturated)
              .divide(10000);
}

// // narrow to broadband conversion
function addVisnirAlbedo(image) {
  var albedo = image.expression(
    '0.7963 * Blue + 2.2724 * Green - 3.8252 * Red + 1.4143 * NIR + 0.2053',
    {
      'Blue': image.select('Blue'),
      'Green': image.select('Green'),
      'Red': image.select('Red'),
      'NIR': image.select('NIR')
    }
  ).rename('visnirAlbedo');
  return image.addBands(albedo).copyProperties(image, ['system:time_start']);
}
// function addNDSI(image) {
//   // var indice = image.normalizedDifference(['Green', 'SWIR1']).rename('NDSI');
//     return image.normalizedDifference(['Green', 'SWIR1']).rename('NDSI');
//   }

/* get harmonized image collection */

// Define function to prepare OLI2 images.
function prepOli2(img) {
  var orig = img;
  img = renameOli(img);
  img = maskL8sr(img);
  img = oli2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_9'));
}
// Define function to prepare OLI images.
function prepOli(img) {
  var orig = img;
  img = renameOli(img);
  img = maskL8sr(img);
  img = oli2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_8'));
}
// Define function to prepare ETM+ images.
function prepEtm(img) {
  var orig = img;
  img = renameEtm(img);
  img = maskL457sr(img);
  img = etm2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_7'));
}
// Define function to prepare TM images.
function prepTm(img) {
  var orig = img;
  img = renameEtm(img);
  img = maskL457sr(img);
  img = etm2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_4/5'));
}
// Define function to prepare S2 images.
function prepS2(img) {
  var orig = img;
  img = renameS2(img);
  img = maskS2sr(img);
  img = s22oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'SENTINEL_2'));
}


var colFilter = ee.Filter.and(
  ee.Filter.bounds(aoi),
  ee.Filter.date(date_start, date_end),
  ee.Filter.calendarRange(6, 8, 'month')
);

var s2colFilter =  ee.Filter.and(
  ee.Filter.bounds(aoi),
  ee.Filter.date(date_start, date_end),
  ee.Filter.calendarRange(6, 8, 'month')
  // ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 50)
);

var oli2Col = ee.ImageCollection('LANDSAT/LC09/C02/T1_L2') 
              .filter(colFilter) 
              .map(prepOli2)
              .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo'])
var oliCol = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2') 
              .filter(colFilter) 
              .map(prepOli)
              .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo'])
var etmCol = ee.ImageCollection('LANDSAT/LE07/C02/T1_L2') 
            .filter(colFilter) 
            .filter(ee.Filter.calendarRange(1999, 2020, 'year')) // filter out L7 imagaes acquired after 2020 due to orbit drift
            .map(prepEtm)
            .select(['visnirAlbedo']); // # .select(['totalAlbedo']) or  .select(['visnirAlbedo']);
var tmCol = ee.ImageCollection('LANDSAT/LT05/C02/T1_L2') 
            .filter(colFilter) 
            .map(prepTm)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo']);
var tm4Col = ee.ImageCollection('LANDSAT/LT04/C02/T1_L2') 
            .filter(colFilter) 
            .map(prepTm)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo']);
var s2Col = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') 
            .linkCollection(csPlus, [QA_BAND])
            .filter(s2colFilter) 
            .map(prepS2)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo']);

var landsatCol = oliCol.merge(etmCol).merge(tmCol).merge(tm4Col).merge(oli2Col);
var multiSat = landsatCol.merge(s2Col); // Sort chronologically in descending order.
 
var minAlbedo = multiSat.min().updateMask(iceMask);

/*
Count the areas of dark ice using different thresholds:
albedo < 0.451 or 0.431
And export the results to Google Drive
*/
var darkIce451Area = ee.Image.pixelArea().mask(minAlbedo.lt(0.451)).reduceRegion({
    reducer: ee.Reducer.sum(),
    geometry: aoi,
    scale: 30,
    maxPixels: 1e13
    });
var darkIce431Area = ee.Image.pixelArea().mask(minAlbedo.lt(0.431)).reduceRegion({
    reducer: ee.Reducer.sum(),
    geometry: aoi,
    scale: 30,
    maxPixels: 1e13
    });

// Create a feature collection with the results
var featureCollection = ee.FeatureCollection([
    ee.Feature(null, { darkIce451Area: darkIce451Area.get('area') }),
    ee.Feature(null, { darkIce431Area: darkIce431Area.get('area') })
]);

// Convert the feature collection to a table
var table = ee.FeatureCollection(featureCollection).flatten();

// Export the table to Google Drive
Export.table.toDrive({
    collection: table,
    description: 'DarkIceAreas_' + yearOfInterest,
    fileFormat: 'CSV',
    folder:'HSA'
});

// Export the minimum albedo image to Google Drive
Export.image.toDrive({
    folder: 'HSA',
    image: minAlbedo,
    description: 'HSA_minAlbedo_' + yearOfInterest,
    scale: 500,
    region: aoi,
    crs: 'EPSG:3413',
    maxPixels: 1e13
});