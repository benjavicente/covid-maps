"use strict";

const scales = ["log", "linear"];

const data = [
  "poblacion",
  "casos_activos",
  "casos_activos_pobl",
  "casos_totales",
  "casos_totales_pobl",
  "positividad",
  "paso_a_paso",
];

// https://vega.github.io/vega/docs/schemes/
const colors = ["orangered", "blues", "yellowgreenblue", "yelloworangered"];

const maps = {
  continental: ["Continental", "Continental e Islas"],
  islands: ["Isla de Pascua", "Juan Fernandez"],
  regions: [
    "La Araucania",
    "Los Lagos",
    "Los Rios",
    "Aysen del Gral. Ibanez del Campo",
    "Antofagasta",
    "Atacama",
    "Libertador Bernardo O'Higgins",
    "Coquimbo",
    "Valparaiso",
    "Bio-Bio",
    "Maule",
    "Metropolitana de Santiago",
    "Magallanes y Antartica Chilena",
    "Arica y Parinacota",
    "Tarapaca",
  ],
  get all() {
    return [].concat(this.continental, this.islands, this.regions);
  },
};

const vis = {
  _element: undefined,
  _spec: undefined,
  _base_spec: undefined,
  _view: undefined,
  _should_restart: true,
  _should_call_api: false,
  _options: {
    mode: "vega-lite",
    renderer: "svg",
    dowloadFileName: "mapaCovid",
    actions: {
      export: true,
      editor: true,
      source: true,
      compiled: true,
    },
    i18n: {
      SVG_ACTION: "Guardar como SVG",
      PNG_ACTION: "Guardar como PNG",
      SOURCE_ACTION: "Vega JSON",
      COMPILED_ACTION: "Vega-Lite JSON",
      EDITOR_ACTION: "Abrir en editor externo",
    },
  },
  // Region
  _region: "Continental",
  get region() {
    return this._region;
  },
  set region(new_region) {
    this.setRegion(new_region);
  },
  setRegion(new_region) {
    if (maps.all.includes(new_region)) {
    }
    this._region = new_region;
    this._should_restart = true;
    return this;
  },
  // Escala
  _scale: "linear",
  get scale() {
    return this._scale;
  },
  set scale(new_scale) {
    this.setScale(new_scale);
  },
  setScale(new_scale) {
    if (scales.includes(new_scale)) {
      this._should_restart = true;
      this._scale = new_scale;
    } else {
      console.error("escala inválida:", new_data);
    }
    return this;
  },
  // Valor
  _data: "casos_totales",
  get data() {
    return this._data;
  },
  set data(new_data) {
    this.setData(new_data);
  },
  setData(new_data) {
    if (data.includes(new_data)) {
      this._data = new_data;
      this._should_restart = true;
    } else {
      console.error("dato inválido", new_data);
    }
    return this;
  },
  // Alto
  _height: 1200,
  auto_height: true,
  get height() {
    return this._height;
  },
  set height(new_height) {
    this.setHeight(new_height);
  },
  setHeight(new_height) {
    this._height = new_height;
    this._should_call_api = true;
    return this;
  },
  // Ancho
  _width: 400,
  get width() {
    return this._width;
  },
  set width(new_width) {
    this.setWidth(new_width);
  },
  setWidth(new_width) {
    this._width = new_width;
    this._should_call_api = true;
    return this;
  },
  // Fondo
  _background: "white",
  get background() {
    return this._background;
  },
  set background(new_background) {
    this.setBackground(new_background);
  },
  setBackground(new_background) {
    this._background = new_background;
    this._should_call_api = true;
    return this;
  },
  // Color
  _color: "orangered",
  get color() {
    return this._color;
  },
  set color(new_color) {
    this.setColor(new_color);
  },
  setColor(new_color) {
    if (colors.includes(new_color)) {
      this._color = new_color;
      this._should_restart = true;
    } else {
      console.error("color inválido", new_color);
    }
    return this;
  },
  init(element_id, spec) {
    this._base_spec = spec;
    this._spec = spec;
    this._element = document.getElementById(element_id);
  },
  update() {
    if (this._should_restart) {
      this._updateSpec();
      vegaEmbed(this._element, this._spec, this._options).then((response) => {
        this._view = response.view;
        this._should_restart = false;
      });
    } else if (this._view != undefined && this._should_call_api) {
      this._updateWithAPI();
    }
    return this;
  },
  _updateWithAPI() {
    this._view.background(this.background);
    this._view.height(this.height);
    this._view.width(this.width);
    this._view.runAsync().then((_response) => {
      console.log("updated");
    });
  },
  // Cambiar todos los parámetros
  _updateSpec() {
    // Se hace una copia del spec original y se actualizan los datos
    var spec = JSON.parse(JSON.stringify(this._base_spec));
    spec.transform = spec.transform.concat(this._getFilters());
    spec.width = this.width;
    spec.background = this.background;
    spec.encoding.fill.field = this.data;
    spec.encoding.fill.title = readable(this.data);
    spec.encoding.fill.scale.type = this.scale;
    spec.encoding.fill.scale.scheme.name = this.color;
    if (this.auto_height) {
      if (this._region == "Continental") {
        spec.height = spec.width * 4;
      } else {
        spec.height = spec.width;
      }
    } else {
      spec.height = this.height;
    }
    // Se guarda el nuevo spec
    this._spec = spec;
    this._should_call_api = false;
  },
  _getFilters() {
    var filters = [];
    if (this._region == "Continental") {
      filters.push(
        "(datum.n != 'Isla de Pascua') && (datum.n != 'Juan Fernandez')"
      );
    } else if (maps.regions.includes(this._region)) {
      filters.push(`datum.region == '${regionScape(this._region)}'`);
      filters.push(
        "(datum.n != 'Isla de Pascua') && (datum.n != 'Juan Fernandez')"
      );
    } else if (maps.islands.includes(this._region)) {
      filters.push(`datum.n == '${regionScape(this._region)}'`);
    }
    return filters.map((e) => {
      return { filter: e };
    });
  },
};

/// Helpers

// Robin Hartmann - https://stackoverflow.com/a/35970894
function getJSON(url, callback) {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", url, true);
  xhr.responseType = "json";
  xhr.onload = () => {
    var status = xhr.status;
    if (status === 200) {
      callback(null, xhr.response);
    } else {
      callback(status, xhr.response);
    }
  };
  xhr.send();
}

function regionScape(region) {
  return region.replaceAll("'", "\\'");
}

function readable(text) {
  var new_text = text.replaceAll("_", " ");
  new_text = new_text[0].toUpperCase() + new_text.slice(1);
  return new_text;
}

function createOptions(id, options, on_change) {
  var select = document.getElementById(id);
  select.onchange = (e) => {
    on_change(e.target.value);
  };
  options.forEach((option) => {
    var option_element = document.createElement("option");
    option_element.value = option;
    option_element.text = readable(option);
    select.appendChild(option_element);
  });
}

/// On load

document.addEventListener("DOMContentLoaded", () => {
  getJSON("map.vl.json", (_e, spec) => {
    const params = new URLSearchParams(window.location.search);
    vis.init("map", spec);
    params.forEach((value, key) => {
      if (key in vis) {
        vis[key] = value;
      }
    });
    vis.update();
    createOptions("color_options", colors, (v) => vis.setColor(v).update());
    createOptions("map_options", maps.all, (v) => vis.setRegion(v).update());
    createOptions("data_options", data, (v) => vis.setData(v).update());
  });
});
