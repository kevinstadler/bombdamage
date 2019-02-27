# Bomb damage 

This submission for the ACDH virtual hackathon Open Data Day Vienna hack consists of two parts:

1. a method for data cleaning and online map tile generation
2. an interactive web map to explore the historical data as a transparent overlay over other contemporary maps

## How to build the tiles

The data retrieval, cleaning and tile generation process is documented in detail in the [data](data/) sub-directory.

## How to build the website

The interactive map is live at http://kevinstadler.github.io/bombdamage/

In order to locally rebuild the web app to reflect changes made to the [index.js](index.js) javascript file you will need the `npm` and `browserify` binaries in your path. Simply run:

> npm install
> npm run build

## License

The software in this repository is made available under the [MIT license](LICENSE).

The geodata and map tiles found in *data/* directory are derived from the [Kriegsschäden um 1946 Wien](https://www.data.gv.at/katalog/dataset/87282445-a02d-4f7f-9bf6-196d73d9b3a9) dataset originally made available by the City of Vienna under a [(CC BY 3.0 AT) license](https://creativecommons.org/licenses/by/3.0/at/deed.de)
