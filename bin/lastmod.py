#!/usr/bin/env python
# encoding: utf-8

## Given a filename, output the last modified date as YYYY-MM-DD

import sys, os, datetime

if len(sys.argv) != 2:
	sys.exit("Usage: " + sys.argv[0] + " filename")
try:
	stat = os.stat(sys.argv[1])
except OSError as (errno, errmsg):
	sys.stderr.write("[1;37;41m'{0}': {1}[K[0;39;49m\n".format(sys.argv[1], errmsg))
	raise
print datetime.date.fromtimestamp(stat[8])
