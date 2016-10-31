# Metrics

## Introduction

The server keeps a list of the last blocks in the mainchain. Using that list, it generates data
that it sends to the client to be rendered.

The list of blocks (the blockchain) is kept by `lib/history.js`, a fragment:


```js
var MAX_HISTORY = 2000;

var MAX_PEER_PROPAGATION = 40;
var MIN_PROPAGATION_RANGE = 0;
var MAX_PROPAGATION_RANGE = 10000;

var MAX_UNCLES = 1000;
var MAX_UNCLES_PER_BIN = 25;
var MAX_BINS = 40;

var History = function History(data)
{
	this._items = [];
	this._callback = null;
}

```

The callback function, if defined, is called when the data is changed, ie, a new block arrived to be
processed.

## Multiple Values

### Block Time

A list of times to produce a new block, ordered by ascending height.

### Difficulty

A list of block difficulty, ordered by ascending height.

### Block Propagation

A list of times (delta 0.5 seconds), counting the number of blocks that propagate in that interval.
Each block has many propagation times, one per reached node. 

### Last Blocks Miners

A list of miners ids, that mined the blocks in the current history.

### Uncle Count

Count of uncles, in the current block history. Each count is the sum of uncle counts in 25 blocks.

### Transactions

Number of transactions in the last blocks in current history.

### Gas Spending

Gas amount spent in each executed block.

### Gas Limit

Gas limit per block in history.

## Single Values

### Best Block

### Uncles

### Last Block

### Average Block Time

### Average Network Hashrate

### Difficulty

### Active Nodes

### Gas Price

### Gas Limit

### Page Latency

### Uptime

