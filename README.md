RSK Stats
============
[![Build Status][travis-image]][travis-url] [![dependency status][dep-image]][dep-url]

This is a visual interface for tracking rsk status. It uses WebSockets to receive stats from running nodes and output them through an angular interface. It is the front-end implementation for [rsk-net-intelligence-api](https://github.com/rootstock/rsk-net-intelligence-api).

![Screenshot](https://github.com/rootstock/rsk-netstats/blob/master/src/images/screenshot.jpg?raw=true "Screenshot")

## Prerequisite
* node
* npm

## Installation
Make sure you have node.js and npm installed.

Clone the repository and install the dependencies

```bash
git clone https://github.com/rootstock/rsk-netstats.git
cd rsk-netstats
npm install
sudo npm install -g grunt-cli
```

##Build the resources
NetStats features two versions: the full version and the lite version. In order to build the static files you have to run grunt tasks which will generate dist or dist-lite directories containing the js and css files, fonts and images.


To build the full version run
```bash
grunt
```

To build the lite version run
```bash
grunt lite
```

If you want to build both versions run
```bash
grunt all
```

##Run

```bash
npm start
```

see the interface at http://localhost:3000
