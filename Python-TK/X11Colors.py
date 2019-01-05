#!/usr/bin/env python
#
# Reads color names from X11 color-definition file "rgb.txt"
#
# By Loren Petrich under the MIT License
#

import re

# Change this variable to point to some different location.
# Originally in its OSX location of /usr/X11/share/X11/rgb.txt
FilePath = "rgb.txt"

def csicmp(a,b):
	rc = cmp(a.lower(),b.lower())
	if rc != 0: return rc
	return cmp(a,b)

# Returns color values as tuples of:
# Tuple of color values (red,green,blue), and tuple of names
def Get():
	clrdict = {}
	f = open(FilePath)
	for ln in f:
		lnsp = re.split("\s",ln)
		lnsp = filter(lambda s: len(s)>0, lnsp)
		if len(lnsp) < 4: continue
		clrval = tuple(map(int,lnsp[0:3]))
		name = ' '.join(lnsp[3:])
		if clrval not in clrdict: clrdict[clrval] = []
		clrdict[clrval].append(name)
	f.close()
	
	clrlist = clrdict.items()
	clrres = []
	for clr in clrlist:
		val = clr[0]
		names = clr[1]
		names.sort(csicmp)
		names = tuple(names)
		clrres.append((val,names))
	clrres.sort()
	return clrres
	
# Color dictionary: divides the color space into boxes,
# then finds which colors are in each box in a 3D grid.
# The grid dimensions are given as a power of 2.
# 0 = whole box, 8 = individual values (16,777,216 boxes!)

def ColorDict(colors,gridexp):
	gridsize = 2 ** gridexp
	boxsize = 256/gridsize

	clrdict = []
	for i1 in xrange(gridsize):
		d1 = []
		clrdict.append(d1)
		for i2 in xrange(gridsize):
			d2 = []
			d1.append(d2)
			for i3 in xrange(gridsize):
				d3 = []
				d2.append(d3)
	
	for color in colors:
		val = color[0]
		clrdict[val[0]/boxsize][val[1]/boxsize][val[2]/boxsize].append(color)
	
	return clrdict

# For debugging / testing
if __name__ == "__main__":
	import sys
	
	if len(sys.argv) > 1: FilePath = sys.argv[1]
	
	# Get the colors and dump them
	colors = Get()
	print "Colors:"
	print
	for color in colors:
		print color
	
	print
	
	# Make a color dictionary
	clrdict = ColorDict(colors,2)
	cdlen = len(clrdict)
	print "Color Dictionary"
	print
	for i1 in xrange(cdlen):
		for i2 in xrange(cdlen):
			for i3 in xrange(cdlen):
				print "%3d %3d %3d" % (i1,i2,i3)
				dent = clrdict[i1][i2][i3]
				for clr in dent: print clr
				print
	
	# Find various statistics
	numcolors = len(colors)
	print "Number of colors:", numcolors
	
	txtmaxlen = 0
	for color in colors:
		clrtxt = ', '.join(color[1])
		txtmaxlen = max(txtmaxlen,len(clrtxt))
	
	print "Maximum color-text length:", txtmaxlen
