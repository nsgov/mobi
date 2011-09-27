#!/usr/bin/env python
# encoding: utf-8

## Given a filename, output the last modified date as YYYY-MM-DD

import sys, os, datetime

if len(sys.argv) != 2:
	sys.exit("Usage: " + sys.argv[0] + " filename")
stat = os.stat(sys.argv[1])
print datetime.date.fromtimestamp(stat[8])
