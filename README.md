# Uso de VegaLite para visualizar mapas

En esta oportunidad se elaboró un código que nos permite explorar las ventajas que tiene el paquete VegaLite.jl para visualizar mapas. Usamos datos geográficos que corresponden a límites distritales y centros poblados. El procedimiento seguido puede ser revisado aquí.

![](img/mapa2_huanuco.svg)

### Instrucciones

Para reproducir el código elaborado se recomienda seguir los siguientes pasos:

1. Clonar el repositorio en una carpeta local de su computador
2. En un terminal iniciar Julia en la carpeta local usando *`julia`*
3. Luego ejecutar los siguiente :
   * julia> `]`
   * (@v1.x) pkg> `activate .`
   * (" *SomeProject* ") pkg> `instantiate`
   * (" *SomeProject"* ) pkg> `status`

Al ejecutar `status` debería tener la siguiente salida:

* [5d742f6a] CSVFiles v1.0.1
* [682c06a0] JSON v0.21.2
* [c3e4b0f8] Pluto v0.16.1
* [1a8c2f83] Query v1.0.0
* [0ae4a718] VegaDatasets v2.1.1
* [112f6efa] VegaLite v2.6.0
