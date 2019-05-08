#!/usr/bin/python3
import re
fails = 100
with open("test-out.txt","r") as fd:
  for line in fd.readlines():
    g = re.search(r'tests passed, (\d+) tests failed out of',line)
    if g:
      fails = int(g.group(1))
      print("Failed:",fails)

if fails > 3:
  exit(1)
else:
  exit(0)
