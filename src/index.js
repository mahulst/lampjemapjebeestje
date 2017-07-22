import './main.css';

import { App } from './App.elm';

var app = App.embed(document.getElementById('root'));

var ol = require('openlayers');
var map, base_layers, overlay_layers;


createMap();


function createMap() {

    base_layers = new ol.layer.Group({
        title: 'Base Layers',
        layers: [
            new ol.layer.Tile({title: "OSM", type: 'base', source: new ol.source.OSM()}),
        ]
    });

    overlay_layers = new ol.layer.Group({
        title: 'Overlays', layers: []
    });

    map = new ol.Map({
        layers: [base_layers, overlay_layers],
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


    function openDialog() {
      app.ports.openDialog.send("test");
    }


    setTimeout(function () {
        map.updateSize();
    }, 50);
}
