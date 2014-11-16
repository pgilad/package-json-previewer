# package-json-previewer
> Web interface to preview your normalized package.json or metadata using [normalize-package-data](https://github.com/npm/normalize-package-data)

This package is a web interface that uses [browserify](http://browserify.org/) in order to create a live preview of how your `package.json` will be transformed.

NPM transforms your `package.json` using a module named [normalize-package-data](https://github.com/npm/normalize-package-data), which mutates several parameters.

This previewer will let you quickly see how your file will be transformed.

## Install

```sh
# clone repo
$ git clone https://github.com/pgilad/package-json-previewer

# change to cloned directory
$ npm install
```

## Usage

```js
# compile everything into ./dist and run server
$ gulp

# open browser in localhost:1337

## Test

```sh
$ npm test
```

## License

MIT @[Gilad Peleg](http://giladpeleg.com)
