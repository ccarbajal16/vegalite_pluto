### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 3a09444e-edba-475a-97e4-8188b99b149a
using VegaLite, VegaDatasets, JSON, CSVFiles

# ╔═╡ b9655d0a-2043-4ba3-8a6e-80435145f0d0
using Query

# ╔═╡ cde3df50-21f5-11ec-21d6-bfc6b7140b23
md"## Introducción a VegaLite con Julia"

# ╔═╡ bef11430-845c-433d-a3d2-bdfb8c5db111
md"Activamos los paquetes requeridos"

# ╔═╡ 3db88310-c09f-413a-86cc-b7b1317bf6d7
md"Debemos convertir nuestro cobertura de distritos que se encuentra en formato `topojson` a un objeto de tipo `VegaJSONDataset`."

# ╔═╡ 7a1c0a01-d873-4e27-9566-62cbf865ef07
begin
	huanuco = JSON.parsefile("data\\dist_huanucof.json")
	d = VegaDatasets.VegaJSONDataset(huanuco, "data\\dist_huanucof.json")
end

# ╔═╡ bc26f407-55b0-48c6-8ce1-fb1310ce2252
typeof(d)

# ╔═╡ fd208b2a-d9c6-4977-a6d0-5d1408e44395
md"Generando nuestro primer mapa básico con la cobertura de distritos"

# ╔═╡ e5303596-f442-4160-b9f8-67ac8661585d
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

# ╔═╡ b8733614-f667-4682-8c07-4cdfa9a99ecb
md"Ahora vamos a insertar una capa CSV de puntos (_Centros poblados de Huánuco_) en nuestro mapa."

# ╔═╡ d8432c70-0427-4f32-b5de-a94185dbc511
dat_pop = load("data/ccpp_huanuco.csv")

# ╔═╡ c1a02a94-1b6d-44be-ae0e-3b2ee6b51003
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

# ╔═╡ d6375e55-2f81-4bc3-9dec-5921c5dbe05f
md"Podemos guardar nuestro mapa generado con la función `save`."

# ╔═╡ c893624a-0073-426c-9081-b2151d9d4437
save("img/mapa2_huanuco.svg", mapa2)

# ╔═╡ 74319f76-6f36-43af-aeb8-6dea0525bfcb
md"Para realizar algunos filtros de nuestros datos vamos a emplear el paquete `Query.jl`."

# ╔═╡ 6b4c6f44-0ddf-4f35-a58c-2ba5b0cc3319
# Extracción de los centros poblados con categoría de Ciudad
load("data/ccpp_huanuco.csv") |> @filter(_.NOMCAT02 == "CIUDAD") |> save("data/ccpp_huanuco_capitales.csv")

# ╔═╡ 8a626222-629a-4b62-abcc-40e90d45ef9d
# Extracción de los centros poblados clasificados como Urbano
load("data/ccpp_huanuco.csv") |> @filter(_.CLASIF02 == "URBANO") |> save("data/ccpp_huanuco_urbano.csv")

# ╔═╡ 93653306-1e13-4ab5-8347-0047aa603ded
md"Definimos los nuevos datos generados para emplearlos en nuestros gráficos."

# ╔═╡ 9d34d203-fe0b-4b5c-ae79-803b619ddc3d
cp_cap = load("data/ccpp_huanuco_capitales.csv")

# ╔═╡ d9b9a456-c9d9-4080-9061-fdd8d47fb929
cp_urb = load("data/ccpp_huanuco_urbano.csv")

# ╔═╡ add67d82-2d53-4c24-bc39-7d7a5be2c821
md"Vamos a generar un mapa incorporando nuestros datos filtrados junto con leyendas para mejorar la visualización de los datos."

# ╔═╡ 5cbd4a73-28cd-416b-9709-5e8e4f89c0ff
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

# ╔═╡ c2b0ae21-e30c-44ae-a867-98ec2ed15d30
#Guardamos nuestro mapa final
save("img/mapa3_huanuco.svg", mapa3)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSVFiles = "5d742f6a-9f54-50ce-8119-2520741973ca"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
VegaDatasets = "0ae4a718-28b7-58ec-9efb-cded64d6d5b4"
VegaLite = "112f6efa-9a02-5b7d-90c0-432ed331239a"

[compat]
CSVFiles = "~1.0.1"
JSON = "~0.21.2"
Query = "~1.0.0"
VegaDatasets = "~2.1.1"
VegaLite = "~2.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSVFiles]]
deps = ["CodecZlib", "DataValues", "FileIO", "HTTP", "IterableTables", "IteratorInterfaceExtensions", "TableShowUtils", "TableTraits", "TableTraitsUtils", "TextParse"]
git-tree-sha1 = "d4dd66b73d3c811daa67587980bf45a179d16983"
uuid = "5d742f6a-9f54-50ce-8119-2520741973ca"
version = "1.0.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e8a30e8019a512e4b6c56ccebc065026624660e8"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.7.0"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[DoubleFloats]]
deps = ["GenericLinearAlgebra", "LinearAlgebra", "Polynomials", "Printf", "Quadmath", "Random", "Requires", "SpecialFunctions"]
git-tree-sha1 = "1c962cf7e75c09a5f1fbf504df7d6a06447a1129"
uuid = "497a8b3b-efae-58df-a0af-a86822472b78"
version = "1.1.23"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "3c041d2ac0a52a12a27af2782b34900d9c3ee68c"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.1"

[[FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "6d4b609786127030d09e6b1ee0e2044ec20eb403"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.11"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GenericLinearAlgebra]]
deps = ["LinearAlgebra", "Printf", "Random"]
git-tree-sha1 = "eddbb6ee8fe2c3244a2c973874a3179c3c4d3ac5"
uuid = "14197337-ba66-59df-a3e3-ca00e7dcff7a"
version = "0.2.6"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Intervals]]
deps = ["Dates", "Printf", "RecipesBase", "Serialization", "TimeZones"]
git-tree-sha1 = "323a38ed1952d30586d0fe03412cde9399d3618b"
uuid = "d8418881-c3e1-53bb-8760-2df7ec849ed5"
version = "1.5.0"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[IterableTables]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Requires", "TableTraits", "TableTraitsUtils"]
git-tree-sha1 = "70300b876b2cebde43ebc0df42bc8c94a144e1b4"
uuid = "1c8ee90f-4401-5389-894e-7a04a3dc0f4d"
version = "1.0.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSONSchema]]
deps = ["HTTP", "JSON", "URIs"]
git-tree-sha1 = "2f49f7f86762a0fbbeef84912265a1ae61c4ef80"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "0.3.4"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Mocking]]
deps = ["ExprTools"]
git-tree-sha1 = "748f6e1e4de814b101911e64cc12d83a6af66782"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.2"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "3927848ccebcc165952dc0d9ac9aa274a87bfe01"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.2.20"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[NodeJS]]
deps = ["Pkg"]
git-tree-sha1 = "905224bbdd4b555c69bb964514cfa387616f0d3a"
uuid = "2bd173c7-0d6d-553b-b6af-13a54713934c"
version = "1.3.0"

[[Nullables]]
git-tree-sha1 = "8f87854cc8f3685a60689d8edecaa29d2251979b"
uuid = "4d1e1d77-625e-5b40-9113-a560ec7a8ecd"
version = "1.0.0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "9d8c00ef7a8d110787ff6f170579846f776133a9"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.4"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Polynomials]]
deps = ["Intervals", "LinearAlgebra", "MutableArithmetics", "RecipesBase"]
git-tree-sha1 = "0bbfdcd8cda81b8144de4be8a67f5717e959a005"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "2.0.14"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Quadmath]]
deps = ["Printf", "Random", "Requires"]
git-tree-sha1 = "5a8f74af8eae654086a1d058b4ec94ff192e3de0"
uuid = "be4d8f0f-7fa4-5f49-b795-2f01399ab2dd"
version = "0.5.5"

[[Query]]
deps = ["DataValues", "IterableTables", "MacroTools", "QueryOperators", "Statistics"]
git-tree-sha1 = "a66aa7ca6f5c29f0e303ccef5c8bd55067df9bbe"
uuid = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
version = "1.0.0"

[[QueryOperators]]
deps = ["DataStructures", "DataValues", "IteratorInterfaceExtensions", "TableShowUtils"]
git-tree-sha1 = "911c64c204e7ecabfd1872eb93c49b4e7c701f02"
uuid = "2aef5ad7-51ca-5a8f-8e88-e75cf067b44b"
version = "0.9.3"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "fca29e68c5062722b5b4435594c3d1ba557072a3"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.7.1"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "793793f1df98e3d7d554b65a107e9c9a6399a6ed"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.7.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Test"]
git-tree-sha1 = "14c54e1e96431fb87f0d2f5983f090f1b9d06457"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.5"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TextParse]]
deps = ["CodecZlib", "DataStructures", "Dates", "DoubleFloats", "Mmap", "Nullables", "WeakRefStrings"]
git-tree-sha1 = "eb1f4fb185c8644faa2d18d14c72f2c24412415f"
uuid = "e0df1984-e451-5cb5-8b61-797a481e67e3"
version = "1.0.2"

[[TimeZones]]
deps = ["Dates", "Future", "LazyArtifacts", "Mocking", "Pkg", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "6c9040665b2da00d30143261aea22c7427aada1c"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.5.7"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Vega]]
deps = ["DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "JSONSchema", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "Setfield", "TableTraits", "TableTraitsUtils", "URIParser"]
git-tree-sha1 = "43f83d3119a868874d18da6bca0f4b5b6aae53f7"
uuid = "239c3e63-733f-47ad-beb7-a12fde22c578"
version = "2.3.0"

[[VegaDatasets]]
deps = ["DataStructures", "DataValues", "FilePaths", "IterableTables", "IteratorInterfaceExtensions", "JSON", "TableShowUtils", "TableTraits", "TableTraitsUtils", "TextParse"]
git-tree-sha1 = "c997c7217f37205c5795de8c797f8f8531890f1d"
uuid = "0ae4a718-28b7-58ec-9efb-cded64d6d5b4"
version = "2.1.1"

[[VegaLite]]
deps = ["Base64", "DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "TableTraits", "TableTraitsUtils", "URIParser", "Vega"]
git-tree-sha1 = "3e23f28af36da21bfb4acef08b144f92ad205660"
uuid = "112f6efa-9a02-5b7d-90c0-432ed331239a"
version = "2.6.0"

[[WeakRefStrings]]
deps = ["DataAPI", "Parsers"]
git-tree-sha1 = "4a4cfb1ae5f26202db4f0320ac9344b3372136b0"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.3.0"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─cde3df50-21f5-11ec-21d6-bfc6b7140b23
# ╟─bef11430-845c-433d-a3d2-bdfb8c5db111
# ╠═3a09444e-edba-475a-97e4-8188b99b149a
# ╟─3db88310-c09f-413a-86cc-b7b1317bf6d7
# ╠═7a1c0a01-d873-4e27-9566-62cbf865ef07
# ╠═bc26f407-55b0-48c6-8ce1-fb1310ce2252
# ╟─fd208b2a-d9c6-4977-a6d0-5d1408e44395
# ╠═e5303596-f442-4160-b9f8-67ac8661585d
# ╟─b8733614-f667-4682-8c07-4cdfa9a99ecb
# ╠═d8432c70-0427-4f32-b5de-a94185dbc511
# ╠═c1a02a94-1b6d-44be-ae0e-3b2ee6b51003
# ╟─d6375e55-2f81-4bc3-9dec-5921c5dbe05f
# ╠═c893624a-0073-426c-9081-b2151d9d4437
# ╟─74319f76-6f36-43af-aeb8-6dea0525bfcb
# ╠═b9655d0a-2043-4ba3-8a6e-80435145f0d0
# ╠═6b4c6f44-0ddf-4f35-a58c-2ba5b0cc3319
# ╠═8a626222-629a-4b62-abcc-40e90d45ef9d
# ╟─93653306-1e13-4ab5-8347-0047aa603ded
# ╠═9d34d203-fe0b-4b5c-ae79-803b619ddc3d
# ╠═d9b9a456-c9d9-4080-9061-fdd8d47fb929
# ╟─add67d82-2d53-4c24-bc39-7d7a5be2c821
# ╠═5cbd4a73-28cd-416b-9709-5e8e4f89c0ff
# ╠═c2b0ae21-e30c-44ae-a867-98ec2ed15d30
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
