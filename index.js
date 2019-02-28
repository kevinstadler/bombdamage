import {Map, View} from 'ol';
import {defaults, ScaleLine} from 'ol/control.js';
import TileLayer from 'ol/layer/Tile';
import TileWMS from 'ol/source/TileWMS';
import {OSM, XYZ} from 'ol/source.js';
import BingMaps from 'ol/source/BingMaps.js';
import {fromLonLat, transformExtent, get as getProjection} from 'ol/proj';
import {register} from 'ol/proj/proj4';
import proj4 from 'proj4';

proj4.defs("EPSG:31256","+proj=tmerc +lat_0=0 +lon_0=16.33333333333333 +k=1 +x_0=0 +y_0=-5000000 +ellps=bessel +towgs84=577.326,90.129,463.919,5.137,1.474,5.297,2.4232 +units=m +no_defs");
register(proj4);
var mgi = getProjection('EPSG:31256');
mgi.setExtent([-523057.16, 162621.12, 61288.27, 431698.18]);

var layers = {};

layers['osm'] = new TileLayer({
  source: new OSM()
});

layers['bombenschadenogd'] = new TileLayer({
  source: new TileWMS({
    attributions: 'Stadt Wien - <a href="https://www.data.gv.at/katalog/dataset/stadt-wien_webmapservicewmsgeoserverwien">https://data.wien.gv.at</a> <a href="https://creativecommons.org/licenses/by/3.0/at/deed.de">(CC BY 3.0 AT)</a>',
    crossOrigin: 'anonymous',
    params: {
      'LAYERS': 'BOMBENSCHADENOGD',
      'FORMAT': 'image/jpeg',
      'SRS': 'EPSG:31256'
    },
    url: 'https://data.wien.gv.at/daten/wms?version=1.1.1',
    projection: 'EPSG:31256'
  })
});

layers['genflwidmungogd'] = new TileLayer({
  source: new TileWMS({
    attributions: 'Stadt Wien - <a href="https://www.data.gv.at/katalog/dataset/stadt-wien_webmapservicewmsgeoserverwien">https://data.wien.gv.at</a> <a href="https://creativecommons.org/licenses/by/3.0/at/deed.de">(CC BY 3.0 AT)</a>',
    crossOrigin: 'anonymous',
    params: {
      'LAYERS': 'GENFLWIDMUNGOGD',
      'FORMAT': 'image/jpeg',
      'SRS': 'EPSG:31256'
    },
    url: 'https://data.wien.gv.at/daten/wms?version=1.1.1',
    projection: 'EPSG:31256'
  })
});

layers['genflwogd'] = new TileLayer({
  source: new TileWMS({
    attributions: 'Stadt Wien - <a href="https://www.data.gv.at/katalog/dataset/stadt-wien_webmapservicewmsgeoserverwien">https://data.wien.gv.at</a> <a href="https://creativecommons.org/licenses/by/3.0/at/deed.de">(CC BY 3.0 AT)</a>',
    crossOrigin: 'anonymous',
    params: {
      'LAYERS': 'GENFLWOGD',
      'FORMAT': 'image/jpeg',
      'SRS': 'EPSG:31256'
    },
    url: 'https://data.wien.gv.at/daten/wms?version=1.1.1',
    projection: 'EPSG:31256'
  })
});

layers['bing'] = new TileLayer({
  source: new BingMaps({
    key: "AnzJ8GUrq-Q-tkdVYWFWs-3H9pIyykpZBwnLXyGTXDA8WV6-1kg-veWxC9XBpMAt",
    imagerySet: "Aerial",
    maxZoom: 19
  })
});

var overlays = {};

overlays['average'] = new TileLayer({
  source: new XYZ({
    url: "data/webtiles/{z}/{x}/{-y}.png",
    attributions: 'Bomb damage overlay derived from data provided by the City of Vienna <a href="https://creativecommons.org/licenses/by/3.0/at/deed.de">(CC BY 3.0 AT)</a>',
    minZoom: 10,
    maxZoom: 17
  })
})

var map = new Map({
  target: 'map',
  controls: defaults().extend([new ScaleLine()]),
  view: new View({
    projection: 'EPSG:31256',
    center: fromLonLat([16.3725, 48.208889], 'EPSG:31256'),
    extent: [-5495.46, 334255.26, 9716.12, 349453.096],
    maxZoom: 16, // OSM's maxZoom is 19
    minZoom: 6,
    zoom: 8
  }),
  layers: [
    layers['bing'],
    overlays['average']
  ]
});

var baseLayerSelect = document.getElementById('base-layer');

baseLayerSelect.onchange = function() {
  var layer = layers[baseLayerSelect.value];
  if (layer) {
    layer.setOpacity(1);
    map.getLayers().setAt(0, layer);
  }
};


var legendEntries = ["red", "yellow", "blue", "green"];
var legendColors = ["#ff8000", "#ff0", "#05f", "#0f0"];
var drawLegend = function() {
  for (var i = 0; i < legendEntries.length; i++) {
    var el = document.getElementById(legendEntries[i]);
    el.style.backgroundColor = legendColors[i];
    el.style.opacity = opacitySlider.value;
  }
}

var opacitySlider = document.getElementById('opacity-slider');

opacitySlider.oninput = function() {
  map.getLayers().item(1).setOpacity(this.value);
  drawLegend();
}

// set initial opacity
opacitySlider.oninput();

var lightenOverlay = document.getElementById('lighten-overlay');

lightenOverlay.onchange = function() { // source-over vs lighter
  var compositionMode = "source-over";
  if (this.checked) {
    compositionMode = "lighter";
  }
  map.getLayers().item(1).on("precompose", function(evt) { evt.context.globalCompositeOperation = compositionMode });
  map.getLayers().item(1).changed();
};

//var overlayLayerSelect = document.getElementById('overlay-layer');
// overlayLayerSelect.onchange = function() {
//   var layer = overlays[overlayLayerSelect.value];
//   if (layer) {
//     layer.setOpacity(opacitySlider.value);
//     map.getLayers().setAt(1, layer);
//   }
// };

//vektordaten: https://www.data.gv.at/katalog/dataset/stadt-wien_flchenmehrzweckkartevektordatenwien
