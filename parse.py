#!/usr/bin/python3
import re
import sys
fails = 100
success = False
with open(sys.argv[1],"r") as fd:
  for line in fd.readlines():
    g = re.search(r'tests passed, (\d+) tests failed out of',line)
    if g:
      fails = int(g.group(1))
      success = True
      print("Failed:",fails)

if success and fails < 5:
  exit(0)
else:
  print("No tests passed")
  exit(1)
