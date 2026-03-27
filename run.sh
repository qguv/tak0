#!/bin/sh
set -e
version="0.42.1"
exec java -jar "lib/rascal-${version}.jar" Main "$@"
