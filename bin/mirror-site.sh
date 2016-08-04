#!/bin/bash
wget --background --random-wait --retry-connrefused -kprN -l inf -np -e robots=off $1
