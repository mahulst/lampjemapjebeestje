import './main.css';

import { App } from './App.elm';

var app = App.embed(document.getElementById('root'));

var ol = require('openlayers');
var map, base_layers, overlay_layers;


createMap();


function createMap() {
  var firetowers = [
    [5.52579, 52.28488],
    [5.52679, 52.28488]
  ];

  var iconStyle = new ol.style.Style({
    image: new ol.style.Icon(/** @type {olx.style.IconOptions} */ ({
      anchor: [0.5, 158],
      anchorXUnits: 'fraction',
      anchorYUnits: 'pixels',
      src: '/ft.png',
      scale: 0.5
    }))
  });
  var features = [];
  firetowers.map(function (towerCoords) {
    var iconFeature = new ol.Feature({
      geometry:  new ol.geom.Point(ol.proj.transform(towerCoords, 'EPSG:4326', 'EPSG:3857'))
    });
    iconFeature.setStyle(iconStyle);
    features.push(iconFeature);
  });

  var vectorSourceIcon = new ol.source.Vector({
    features: features
  });

  var vectorLayerIcon = new ol.layer.Vector({
    source: vectorSourceIcon
  });


  var styleCache = {};
  var defaultStyle = new ol.style.Style({
    stroke: new ol.style.Stroke({
      color: [0,0, 0,1],
      width: 3
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
          vectorLayer,
          vectorLayerIcon
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
            color: [255,255, 255,1],
            width: 6
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


