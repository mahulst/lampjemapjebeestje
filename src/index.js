import './main.css';

import logoPath from './logo.svg';
const { App } = require('./App.elm');

var app = App.embed(document.getElementById('root'), logoPath);

var ol = require('openlayers');
var map, base_layers, overlay_layers;


createMap({"layers": [{"path": "base", "name": "Base", "visible": true}, {"path": "trees", "name": "Trees", "visible": true}], "zoom_range": [7, 20], "extents": [52.292, 5.5405, 52.275, 5.5129]})


function createMap(config) {

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
        controls: ol.control.defaults({
            attributionOptions: ({
                collapsible: false
            })
        }).extend([new ol.control.ScaleLine()]),
        view: new ol.View({
            center: (new ol.geom.Point([5.52579, 52.28488])).transform('EPSG:4326', 'EPSG:3857').getCoordinates(),
            zoom: 17,
        })
    });

    // var layerSwitcher = new ol.control.LayerSwitcher();
    // map.addControl(layerSwitcher);

    addVectorLayers({
        "layers": [
            {
                "source": "Grid.json",
                "z-index": 0,
                "name": "Grid",
                "visible": false
            },
            {
                "source": "Tents and buildings.json",
                "z-index": 2,
                "name": "Tents and buildings",
                "visible": true
            },
            {
                "source": "Field names.json",
                "z-index": 2,
                "name": "Field names",
                "visible": true
            },
            {
                "source": "Campers.json",
                "z-index": 2,
                "name": "Campers",
                "visible": true
            },
            {
                "source": "Available from early buildup.json",
                "z-index": 1,
                "name": "Available from early buildup",
                "visible": false
            },
            {
                "source": "Emergency services route.json",
                "z-index": 2,
                "name": "Emergency services route",
                "visible": false
            },
            {
                "source": "Evacuation route.json",
                "z-index": 2,
                "name": "Evacuation route",
                "visible": false
            },
            {
                "source": "Team:Logistics.json",
                "z-index": 2,
                "name": "Team:Logistics",
                "visible": false
            },
            {
                "source": "Team:NOC.json",
                "z-index": 3,
                "name": "Team:NOC",
                "visible": false
            },
            {
                "source": "Power -- APPROXIMATE.json",
                "z-index": 2,
                "name": "Power -- APPROXIMATE",
                "visible": false
            },
            {
                "source": "Water -- APPROXIMATE.json",
                "z-index": 2,
                "name": "Water -- APPROXIMATE",
                "visible": false
            },
            {
                "source": "Sewage -- APPROXIMATE.json",
                "z-index": 2,
                "name": "Sewage -- APPROXIMATE",
                "visible": false
            }
        ],
        "styles": {
            "Team:NOC": {
                "team-noc ... labels": {
                    "text-color": "blue",
                    "selectable": false,
                    "z-index": 4
                },
                "team-noc ... datenklos ... dk-and-label": {
                    "text-selectable": false,
                    "line-color": "cyan",
                    "text-color": "blue",
                    "polygon-fill": "cyan",
                    "z-index": 4,
                    "line-width": 1
                },
                "team-noc ... cables ... copper": {
                    "line-color": "black",
                    "z-index": 3,
                    "line-width": 3
                },
                "team-noc ... cables ... fibre-single-mode": {
                    "line-color": "green",
                    "z-index": 3,
                    "line-width": 3
                },
                "team-noc ... switch-in-tent": {
                    "polygon-fill": "magenta",
                    "line-color": "magenta",
                    "z-index": 4,
                    "line-width": 1
                }
            },
            "Power -- APPROXIMATE": {
                "infrastructure ... sketch ... power ... aluminium_4x120": {
                    "line-color": "red",
                    "line-width": 3
                },
                "infrastructure ... sketch ... power ... aluminium_4x050": {
                    "line-color": "red",
                    "line-width": 3
                },
                "infrastructure ... sketch ... power ... aluminium_4x095": {
                    "line-color": "red",
                    "line-width": 3
                },
                "objects ... power terminal": {
                    "polygon-fill": "orange",
                    "line-color": "black",
                    "z-index": 5,
                    "line-width": 5
                },
                "infrastructure ... sketch ... power ... aluminium_4x070": {
                    "line-color": "red",
                    "line-width": 3
                },
                "infrastructure ... sketch ... power ... aluminium_4x150": {
                    "line-color": "red",
                    "line-width": 3
                }
            },
            "Campers": {
                "terrain ... camper spot": {
                    "line-color": "#800080",
                    "z-index": 0,
                    "line-width": 2
                }
            },
            "Team:Logistics": {
                "team-logistics ... sketch": {
                    "text-color": "black",
                    "line-color": "black",
                    "selectable": false,
                    "line-width": 2
                },
                "team-logistics ... trash ... labels": {
                    "text-color": "black",
                    "selectable": false
                },
                "team-logistics ... trash": {
                    "line-color": "black",
                    "line-width": 2
                }
            },
            "Available from early buildup": {
                "meta ... restrictions ... early buildup": {
                    "line-color": "yellow",
                    "z-index": 0,
                    "line-width": 3
                }
            },
            "Emergency services route": {
                "routes ... R03_calamiteitenroute": {
                    "line-color": "red",
                    "selectable": false,
                    "line-width": 5
                }
            },
            "Water -- APPROXIMATE": {
                "infrastructure ... sketch ... water ... pe090": {
                    "line-color": "blue",
                    "line-width": 3
                },
                "infrastructure ... sketch ... water ... pe080": {
                    "line-color": "blue",
                    "line-width": 3
                },
                "infrastructure ... sketch ... water ... pe110": {
                    "line-color": "blue",
                    "line-width": 3
                },
                "infrastructure ... sketch ... water ... pe040": {
                    "line-color": "blue",
                    "line-width": 3
                },
                "infrastructure ... sketch ... water ... pe063": {
                    "line-color": "blue",
                    "line-width": 3
                }
            },
            "Tents and buildings": {
                "tents ... tarps": {
                    "line-color": "blue",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... temporary toilet": {
                    "line-color": "red",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... radio tower": {
                    "line-color": "#c06000",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... portacabin": {
                    "line-color": "#000000",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... gate": {
                    "line-color": "#c06000",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... portacabin ... labels": {
                    "text-color": "black",
                    "selectable": false
                },
                "tents ... tents": {
                    "line-color": "magenta",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... utility": {
                    "line-color": "red",
                    "z-index": 3,
                    "line-width": 2
                },
                "team-power ... generator ... tank": {
                    "line-color": "orange",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... labels": {
                    "text-color": "black",
                    "selectable": false
                },
                "tents ... tents ... labels": {
                    "text-color": "black",
                    "selectable": false
                },
                "team-power ... generator ... generator": {
                    "line-color": "orange",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... toilet": {
                    "line-color": "red",
                    "z-index": 3,
                    "line-width": 2
                },
                "tents ... tarps ... labels": {
                    "text-color": "black",
                    "selectable": false
                },
                "objects ... buildings": {
                    "line-color": "red",
                    "z-index": 3,
                    "line-width": 2
                },
                "objects ... buildings ... container": {
                    "line-color": "#000000",
                    "z-index": 3,
                    "line-width": 2
                },
                "team-power ... generator ... labels": {
                    "text-color": "black",
                    "selectable": false
                },
                "objects ... buildings ... container ... labels": {
                    "text-color": "black",
                    "selectable": false
                }
            },
            "Grid": {
                "meta ... grid ... legend": {
                    "text-color": "black",
                    "line-color": "black",
                    "selectable": false,
                    "line-width": 1
                },
                "meta ... grid": {
                    "text-color": "black",
                    "line-color": "black",
                    "selectable": false,
                    "line-width": 1
                }
            },
            "Field names": {
                "terrain ... fields ... labels": {
                    "text-color": "black",
                    "selectable": false
                }
            },
            "Sewage -- APPROXIMATE": {
                "infrastructure ... sketch ... sewage ... pers_pe090mm": {
                    "line-color": "lightbrown",
                    "line-width": 3
                },
                "infrastructure ... sketch ... sewage ... pers_pe160mm": {
                    "line-color": "lightbrown",
                    "line-width": 3
                },
                "infrastructure ... sketch ... sewage ... vrijverval_pvc315": {
                    "line-color": "brown",
                    "line-width": 3
                },
                "objects ... sewer hole": {
                    "polygon-fill": "brown",
                    "line-color": "brown",
                    "z-index": 5,
                    "line-width": 5
                },
                "infrastructure ... sketch ... sewage ... vrijverval_pvc250": {
                    "line-color": "brown",
                    "line-width": 3
                },
                "infrastructure ... sketch ... sewage ... vrijverval_pvc200": {
                    "line-color": "brown",
                    "line-width": 3
                }
            },
            "Evacuation route": {
                "safety ... evacuation point": {
                    "line-color": "darkgreen",
                    "selectable": false,
                    "line-width": 1
                },
                "safety ... escape route": {
                    "line-color": "darkgreen",
                    "selectable": false,
                    "line-width": 3
                },
                "safety ... escape route ... arrow lines": {
                    "polygon-fill": "darkgreen",
                    "selectable": false
                }
            }
        }
    });


    // The <canvas> element doesn't seem to get sized correctly
    // on page load, which causes vector element hover to break.
    // Update the size after a small delay.
    setTimeout(function () {
        map.updateSize();
    }, 50);
}

function addVectorLayers(layer_data) {
    layer_data.layers.map(function (index, layer) {
        var vectorSource = new ol.source.Vector({
            url: 'vector/' + layer.source,
            format: new ol.format.GeoJSON()
        });

        var vectorLayer = new ol.layer.Vector({
            title: layer.name,
            source: vectorSource,
            visible: layer.visible,
            updateWhileAnimating: true,
            updateWhileInteracting: true
        });
        vectorLayer.setZIndex(layer['z-index']);
        overlay_layers.getLayers().push(vectorLayer);
    });

}




map.on('singleclick', function (evt) {
    var lonlat = ol.proj.transform(evt.coordinate, 'EPSG:3857', 'EPSG:4326');
    console.log(lonlat);
    openDialog();
});

function openDialog() {
    app.ports.openDialog.send("Hello, world!");
}
