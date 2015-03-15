# ANSIKit
[![Build status](https://badge.buildkite.com/7651debde69eef1691403ae8cae48008e2e39de01dd0edc6e0.svg)](https://buildkite.com/mattdelves/ansikit)

## A Call for help.

So, I need your help. This current implementation works, but it's horrible. It needs cleaning up and making it less of a memory and cpu hog than it currently is.

## Why

Log files are everywhere and if they are generated in a terminal (linux, unix, osx, otherwise) then they are more than likely to be ANSI formatted.

Displaying these text files in a app (iOS or OSX) is desirable, but first we need to extract them

## The Problem

There are many ways in which a blob of text can be formatted. One of these is by using ANSI escape codes to change the format of the text. A typical use of these codes is in a terminal window whereby the output is progressively rendered to the screen.

This isn't as easy when it comes to displaying the final output from a log file that contains this formatting.

What I need help with is the following areas of the code.

1. How can I reliably identify the range over which an escape code would apply
1. How can I identify the escape codes amongst the string being parsed
1. How can I avoid consuming all the cpu and ram on a device.

The current use of this framework is in an iOS app that displays the output from a saved log file. This log file is the result of running tests against the code and is ANSI formatted. 

## How to help out

1. Fork the repo.
1. Clone the repo.
1. Create a branch.
1. Write a solution including tests.
1. Commit your code and push it up.
1. Submit a pull request.

## Thanks

Many thanks for your help and input. You are all awesome.
