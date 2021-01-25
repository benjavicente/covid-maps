"""
Código para filtrar y modificar los archivos de mapas.

Genera el archivo `data/maps/comunas_sin_simbolos.topo.json`.
"""

import json
import re


class Map:
    def __init__(self, path: str):
        self._data = json.load(open(path))

    def filter_by(self, condition: 'function(e) -> bool') -> 'data':
        new_data = self._data.copy()
        new_geometries = new_data['objects']['comunas']['geometries']

        to_delete = []
        for i, e in enumerate(new_geometries):
            if not condition(e['properties']):
                to_delete.append(i)

        for i in reversed(to_delete):
            new_geometries.pop(i)

        return new_data

    def change_by(self, changer: 'function(e) -> e') -> 'data':
        new_data = self._data.copy()
        new_geometries = new_data['objects']['comunas']['geometries']

        for i, e in enumerate(new_geometries):
            new_geometries[i] = changer(e)

        return new_data


mdata = Map('../data/maps/comunas.topo.json')


def remove_special_simbols(old_string: str) -> str:
    # TODO: use a module?
    simbols = "ÁÉÍÓÚáéíóúÑñÜú"
    replace = "AEIOUaeiouNnUu"
    new_string = ""
    for sb in old_string:
        if sb not in simbols:
            new_string += sb
        else:
            new_string += replace[simbols.index(sb)]
    return new_string


def simplify_properties(element):
    new_element = element.copy()
    new_element['properties']['NOM_COM_'] = \
        remove_special_simbols(element['properties']['NOM_COM'])

    if new_element['properties']['REGION']:
        new_element['properties']['REGION'] = re.sub(
            "Regi[oó]n (?:del?)?",
            "",
            remove_special_simbols(element['properties']['REGION'])
        ).strip()
    return new_element


json.dump(
    mdata.change_by(simplify_properties),
    open('../data/maps/comunas_sin_simbolos.topo.json', 'w')
)


# Lo siguiente se puede hacer directamente en Vega

## Se filtran las islas
# islands = ['Isla de Pascua', 'Juan Fernández']
# json.dump(
#     mdata.filter_by(lambda e: e['NOM_COM'] not in islands),
#     open('../data/maps/comunas_sin_islas.topo.json', 'w')
# )

## Se filtran dejando solo la regíon metropolitana
# name = 'Región Metropolitana de Santiago'
# json.dump(
#     mdata.filter_by(lambda e: e['REGION'] == name),
#     open('../data/maps/region_metropolitana.topo.json', 'w')
# )
