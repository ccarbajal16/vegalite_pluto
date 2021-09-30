# Activamos nuestros paquetes requeridos
using VegaLite, VegaDatasets, JSON, CSVFiles

huanuco = JSON.parsefile("data\\dist_huanucof.json")
d = VegaDatasets.VegaJSONDataset(huanuco, "data\\dist_huanucof.json")

# Generando nuestro primer mapa 

mapa1= @vlplot(
    :geoshape,
    title = "Distritos de Huánuco",
    width = 640, 
    height = 360,
    data = {
    values = d,
    format = {
        type = :topojson,
        feature = :gj
        }
    },
    projection = {
        type = :mercator
    },
)

# Insertando puntos de centros poblados al mapa

dat_pop = load("data/ccpp_huanuco.csv")

mapa2= @vlplot(
    width = 640,
    height = 360,
    title = "Centros Poblados del Departamento de Huánuco"
) +
@vlplot(
    mark = {
        :geoshape,
        fill = :lightgray,
        stroke = :white
    },
    data = {
        values = d,
        format = {
            type = :topojson,
            feature = :gj
        }
    },
    projection = {type = :mercator}
) +
@vlplot(
    :circle,
    data = dat_pop,
    projection = {type = :mercator},
    longitude = "X_COORD:q",
    latitude = "Y_COORD:q",
    size = {value = 6},
    color = {value = :blue}
)

# Creación de filtros a nuestros datos de origen, emplearemos el paquete Query.jl

using Query

load("data/ccpp_huanuco.csv") |> @filter(_.NOMCAT02 == "CIUDAD") |> save("data/ccpp_huanuco_capitales.csv")

load("data/ccpp_huanuco.csv") |> @filter(_.CLASIF02 == "URBANO") |> save("data/ccpp_huanuco_urbano.csv")

# Definición de los nuevos datos generados

cp_cap = load("data/ccpp_huanuco_capitales.csv")
cp_urb = load("data/ccpp_huanuco_urbano.csv")

# Incorporando datos filtrados junto con su legenda
mapa3 = @vlplot(
    width = 640,
    height = 360,
    title = "Principales Centros Poblados del Departamento de Huánuco"
) +
@vlplot(
    mark = {
        :geoshape,
        fill = :darkgrey,
        stroke = :white
    },
    data = {
        values = d,
        format = {
            type = :topojson,
            feature = :gj
        }
    },
    projection = {type = :mercator}
) +
@vlplot(
    :circle,
    data = dat_pop,
    projection = {type = :mercator},
    longitude = "X_COORD:q",
    latitude = "Y_COORD:q",
    size = {value = 6},
    color = {
        "NOMBPV02:n",
        scale = {range = ["purple", "yellow", "green", "brown", "#1d65b7", "#cc992a", "#81ea24", "#afb5e4", "#e0b4f0", "#a8e7ea", "#577599"]},
        legend = {title = "Provincias"}
    },
    opacity = {value = 0.5}
) +
@vlplot(
    :circle,
    data = cp_cap,
    projection = {type = :mercator},
    longitude = "X_COORD:q",
    latitude = "Y_COORD:q",
    size = {
        "TOT_POB99:q",
        legend = {title = "Población"}
    },
    color = {value = :red}
) +
@vlplot(
    data = cp_cap,
    mark = {
        type = :text,
        dy = -10,
        xOffset = -7,
        font = :serif,
        fontSize = 10,
        fontWeight = :bold,
        fontStyle = :normal
    },
    longitude = "X_COORD:q",
    latitude = "Y_COORD:q",
    text = "NOMCCPP02:n",
    color = {value = :black},
    opacity = {value = 0.9}
)

# Guaramos nuestro resultado final en un archivo tipo SVG.
save("img/map3_huanuco.svg", mapa3)

