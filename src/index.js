import './main.css';

import { App } from './App.elm';

var app = App.embed(document.getElementById('root'));

var ol = require('openlayers');
var map, base_layers, overlay_layers;


createMap();


function createMap() {
  var styleCache = {};
  var defaultStyle = new ol.style.Style({
    fill: new ol.style.Fill({
      color: [250,250,250,1]
    }),
    stroke: new ol.style.Stroke({
      color: [220,220,220,1],
      width: 1
    })
  });

  function styleFunction (feature) {
    var featureStyle =  styleCache[feature.get('name')];
    if (featureStyle) {
      return [featureStyle];
    }
    else {
      return [defaultStyle];
    }
  }

  //Holds the Polygon feature
  var polyFeature = new ol.Feature({});

  var vectorSource = new ol.source.Vector({
    features: [
      polyFeature
    ]
  });
  //A vector layer to hold the features
  var vectorLayer = new ol.layer.Vector({
    source: vectorSource,
    style: styleFunction
  });


  base_layers = new ol.layer.Group({
        title: 'Base Layers',
        layers: [
            new ol.layer.Tile({title: "OSM", type: 'base', source: new ol.source.OSM()}),
          vectorLayer
        ]
    });

    map = new ol.Map({
        layers: [base_layers],
        target: 'map',
        controls: [],
        view: new ol.View({
            center: (new ol.geom.Point([5.52579, 52.28488])).transform('EPSG:4326', 'EPSG:3857').getCoordinates(),
            zoom: 17,
        })
    });

    map.on('singleclick', function (e) {
      map.forEachFeatureAtPixel(e.pixel, function (feature) {
        var zoneName = feature.get('name');

        openDialog(zoneName);
      });
    });

    function addFeature(coords, colour, name) {
      var feature = new ol.Feature({
        geometry: new ol.geom.Polygon([
          coords
        ])
      });
      feature.set('name', name);
      if(colour) {
        colour = '#' + colour;
        var style = new ol.style.Style({
          fill: new ol.style.Fill({
            color: colour ,// + colour, // || 'ccc',
            weight: 1
          }),
          stroke: new ol.style.Stroke({
            color: colour ,// + colour, // || 'ccc',
            width: 1
          })
        });
        styleCache[name] = style;

      }
      feature.getGeometry().transform('EPSG:4326', 'EPSG:3857');

      vectorSource.addFeature(feature);
    }

    function openDialog(name) {
      app.ports.openDialog.send(name);
    }

    setTimeout(function () {
      app.ports.setZones.subscribe(function(zones) {
        zones.map(function (zone) {
          var coords = zone.coordinates.map(function (c) {
            return [c.longitude, c.latitude]
          });
          addFeature(coords, zone.colour, zone.name);
        });
      });

        map.updateSize();
    }, 50);
}


