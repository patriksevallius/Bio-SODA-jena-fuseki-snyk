#!/bin/sh

exec "java" $JAVA_OPTIONS -jar "fuseki-server.jar" "$@"
