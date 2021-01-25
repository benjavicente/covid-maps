#=
Limpieza da datos para los plots

El objetivo de este código es obtener y ordenar
datos de COVID19 del ministerio de ciencia

Cada archivo se ordena por keys principales
(por ejemplo, nombre+codigo comuna o region)
y sets de datos del mismo tipo (como casos diarios).
Muchos valores se repiten, como población y region,
porlo que son omitidos en los archivos.
=#


# TODO: funcion para convertir de tipo de datos una columna
# TODO: hacer columna de aumento junto a últimos casos
# TODO: usar mejor las dependencias


begin
    using Pkg
    try
        using DataFrames
    catch ArgumentError
        Pkg.add("DataFrames")
        using DataFrames
    end
    try
        using  CSV
    catch ArgumentError
        Pkg.add("CSV")
        using  CSV
    end
    using FilePaths
end


function source_path(subpath::String)::String
    "https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/" * subpath
end


function download_dataset(sourcepath, filename, path=joinpath("data", "input"))
    download(source_path(sourcepath), joinpath(path, filename))
end


function update_datasets!()
    download_dataset("producto1/Covid-19.csv", "producto1.csv")
    download_dataset("producto8/UCI.csv", "producto8.csv")
    download_dataset("producto25/CasosActualesPorComuna.csv", "producto25.csv")
    download_dataset("producto52/Camas_UCI.csv", "producto52.csv")
    download_dataset("producto65/PositividadPorComuna.csv", "producto65.csv")
    download_dataset("producto74/paso_a_paso.csv", "producto74.csv")
end

function rename_colum!(df::DataFrame, before::String, after::String)
    if in(before, names(df))
        rename!(df, Dict(Symbol(before) => Symbol(after)))
    end
end


function rename_cols!(df::DataFrame)
    rename_colum!(df, "Poblacion", "poblacion")
    rename_colum!(df, "Codigo comuna", "codigo")
    rename_colum!(df, "codigo_comuna", "codigo")
    rename_colum!(df, "Comuna", "nombre")
    rename_colum!(df, "comuna_residencia", "nombre")
end


"Casos acumulados por comuna (producto 1)"
function make_total_cases()
    outfile = let
        df = CSV.read("data/input/producto1.csv", DataFrame)
        # TODO: varias comunas les faltan días y se eliminan
        dropmissing!(df)
        rename_cols!(df)
        df = df[:, [3, 4, 6:end - 1...]] # La última fila es la tasa
        df[!, 3:end] = convert.(Int, df[:, 3:end])
        CSV.write("data/output/casos_incremental_comunas.csv", df)
    end
    let
        # Ultimos casos
        df = CSV.read(outfile, DataFrame)
        df = df[:, [1, 2, end]]
        rename!(df, Dict(last(names(df)) => "casos_totales"))
        CSV.write("data/output/ultimos_casos_incremental_comunas.csv", df)
    end
end


"Población"
function make_population()
    let
        # Se utiliza un archivo elegido arbitrariamente
        df = CSV.read("data/input/producto1.csv", DataFrame)
        df = df[:, [3, 4, 5]]
        dropmissing!(df)
        rename_cols!(df)
        df[!, 3] = convert.(Int, df[:, 3])
        CSV.write("data/output/poblacion_por_comuna.csv", df)
    end
end


"Casos activos por comuna (producto 25)"
function make_active_cases()
    outfile = let
        # Arreglos en el archivos de comunas
        df = CSV.read("data/input/producto25.csv", DataFrame)
        dropmissing!(df)
        rename_cols!(df)
        df = df[:, [3, 4, 6:end...]]
        df[!, 3:end] = convert.(Int, df[:, 3:end])
        CSV.write("data/output/casos_activos_comunas.csv", df)
    end
    let
        # Tabla de últimos casos activos por comuna
        df = CSV.read(outfile, DataFrame)
        df = df[:, [1, 2, end]]
        rename!(df, Dict(last(names(df)) => "casos_activos"))
        CSV.write("data/output/ultimos_casos_activos_comunas.csv", df)
    end
end


"Camas UCI por region (producto 8)"
function make_uci()
    let
        df = CSV.read("data/input/producto8.csv", DataFrame)
        df = df[:, [1, 2, 4:end...]]
        CSV.write("data/output/camas_uci_regiones.csv", df)
    end
    let
        # Ultimos datos de camas UCI
        df = CSV.read("data/input/producto8.csv", DataFrame)
        df = df[:, [1, end]]
        rename!(df, ["nombre", "camas_uci"])
        CSV.write("data/output/ultimas_camas_uci_regiones.csv", df)
    end
end


"Porcentage camas UCI por región (producto 52)"
function make_uci_porcentage()
    outfile = let
        df = CSV.read("data/input/producto52.csv", DataFrame)
        df = filter(row -> row.Region != "Total", df)
        g = groupby(df, 1)
        n = names(df)[3:end]
        # Esto asume que el orden de `x` es
        # 1. Camas habilitadas
        # 2. Camas ocupadas COVID-19
        # 3. Camas ocupadas no COVID-19
        df = combine(g, n .=> (d -> round(100 * (d[2] + d[3]) / d[1]; digits=2)) .=> n)
        CSV.write("data/output/porcentage_camas_uci_regiones.csv", df)
    end
    let
        df = CSV.read(outfile, DataFrame)
        df = df[:, [1, end]]
        rename!(df, Dict(last(names(df)) => "porcentage_uci"))
        CSV.write("data/output/ultimo_porcentage_camas_uci_regiones.csv", df)
    end
end


"Positividad por comuna (producto 65)"
function make_positivity()
    outfile = let
        df = CSV.read("data/input/producto65.csv", DataFrame)
        df = df[:, [3, 4, 6:end...]]
        rename_cols!(df)
        CSV.write("data/output/positividad_comunas.csv", df)
    end
    let
        # Solo última positividad
        df = CSV.read(outfile, DataFrame)
        df = df[:, [1, 2, end]]
        rename!(df, Dict(last(names(df)) => "positividad"))
        CSV.write("data/output/ultima_positividad_comunas.csv", df)
    end
end


"Plan paso a paso (producto 74)"
function make_step_by_step()
    # Estos datos se separan en zonas, donde cada región tiene
    # zona Urbana y Rural, o Total. Para simplificar esto, se
    # considerará el mínimo entre entre los valores de la zona de cada comuna
    outfile = let
        df = CSV.read("data/input/producto74.csv", DataFrame)
        df = df[:, 3:end]
        rename_cols!(df)
        df = combine(groupby(df, 1:2), names(df)[4:end] .=> minimum .=> names(df)[4:end])
        CSV.write("data/output/plan_paso_a_paso.csv", df)
    end
    let
        # Solo último
        df = CSV.read(outfile, DataFrame)
        df = df[:, [1, 2, end]]
        rename!(df, Dict(last(names(df)) => "paso_a_paso"))
        CSV.write("data/output/ultimo_plan_paso_a_paso.csv", df)
    end
end


begin
    # Download
    update_datasets!()
    # CleanUp
    make_active_cases()
    make_positivity()
    make_uci()
    make_uci_porcentage()
    make_total_cases()
    make_population()
    make_step_by_step()
end
