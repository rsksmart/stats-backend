RSK Network Stats | Backend
===========================

This component exposes a websockets interface to receive and aggregate information from RSK network nodes. 
Information is then provided through a websockets service and used by the RSK Network Stats frontend component. This component outputs all the data through vue interace.

There is also an angular front end interface in this code that works but is currently not being used to output information.

Note. Information received from network nodes is provided by a service called `stats agent` which is responsible for interacting with an RSK node via web3 to extract relevant information.


## Prerequisites
* node
* npm

## Installation
Make sure you have node.js and npm installed.

Clone the repository and install the dependencies

```bash
git clone https://github.com/rsksmart/stats.git
cd stats
npm install
sudo npm install -g grunt-cli
```

## Build the resources
There are two versions: the full version and the lite version. In order to build the static files you have to run grunt tasks which will generate dist or dist-lite directories containing the js and css files, fonts and images.


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

## Run

```bash
npm start
```

See the interface at http://localhost:3000


To update geoip-lite db run

``` bash
npm explore geoip-lite -- npm run updatedb
```
