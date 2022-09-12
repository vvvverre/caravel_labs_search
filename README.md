## Caravel LABS Search

This project implements an accelerator core for the computation of the autocorrelation of binary sequences, and the associated search for binary sequences with low autocorrelation.

For more information about low autocorrelation binary sequences (LABS) and the search for the most optimum solution, see e.g. [Mertens *et al.* (2016)](https://arxiv.org/abs/1512.02475).

# Overview

This design contains two accelerator cores which compute the single-sided autocorrelation value. The cores are fed input sequences via the wishbone interface and the resulting energy value is also read back via the wishbone interface. The input and output of each core is decoupled from the interface via an 8-deep FIFO.

The design is mapped at the address *0x3000_0000*.

# Register Map

| Offset (bytes) | Hex Offset |   Name   | Description |
|:--------------:|:----------:|:--------:|:-----------:|
|        0       |     00h    |  STATUS  |             |
|        4       |     04h    |   FIXED  |             |
|        8       |     08h    |  CONFIG  |             |
|       12       |     0Ch    | SEQ0 LSW |             |
|       16       |     10h    | SEQ0 MSW |             |
|       20       |     14h    |    E0    |             |
|       24       |     18h    | SEQ1 LSW |             |
|       28       |     1Ch    | SEQ1 MSW |             |
|       32       |     20h    |    E1    |             |