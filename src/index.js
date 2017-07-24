import './main.css';

import { App } from './App.elm';

var app = App.embed(document.getElementById('root'));

var ol = require('openlayers');
var map, base_layers, overlay_layers;


createMap();


function createMap() {
  //Holds the Polygon feature
  var polyFeature = new ol.Feature({
    geometry: new ol.geom.Polygon([
      [
      ]
    ])
  });
  polyFeature.getGeometry().transform('EPSG:4326', 'EPSG:3857');

  var vectorSource = new ol.source.Vector({
    features: [
      polyFeature
    ]
  });
  //A vector layer to hold the features
  var vectorLayer = new ol.layer.Vector({
    source: vectorSource
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

    map.on('singleclick', function (evt) {
      var lonlat = ol.proj.transform(evt.coordinate, 'EPSG:3857', 'EPSG:4326');

      openDialog();
    });

    function addFeature(coords, colour) {
      var feature = new ol.Feature({
        geometry: new ol.geom.Polygon([
          coords
        ])
      });
      var style = new ol.style.Style({
        fill: new ol.style.Fill({
          color: '#' + colour || 'ccc',
          weight: 1
        }),
        stroke: new ol.style.Stroke({
          color: '#' + colour || 'ccc',
          width: 1
        })
      });
      feature.setStyle(style);
      feature.getGeometry().transform('EPSG:4326', 'EPSG:3857');

      vectorSource.addFeature(feature);
    }

    function openDialog() {
      app.ports.openDialog.send("TestZone3");
    }

    setTimeout(function () {
      app.ports.setZones.subscribe(function(zones) {
        zones.map(function (zone) {
          var coords = zone.coordinates.map(function (c) {
            return [c.longitude, c.latitude]
          });
          addFeature(coords, zone.colour);
        });
      });

        map.updateSize();
    }, 50);
}


