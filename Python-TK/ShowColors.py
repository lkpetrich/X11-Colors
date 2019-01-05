#!/usr/bin/env python
#
# Shows which X11 colors are closest to some entered color
# Makes a list of colors closes to some Colors
#
# By Loren Petrich under the MIT License
#

from Tkinter import *
import tkColorChooser

import X11Colors

Colors = X11Colors.Get()

# Dump color in HTML-friendly form (hexadecimal)
# Input is tuple of three color-channel values
def clrtxt(Color):
	return "#%02x%02x%02x" % Color

# Standard swatch here
# The GUI widget is called "widget" of course
class Swatch:
	def __init__(self,Parent):
		self.widget = Frame(Parent)
		self.widget.config(width=80, height=24, bd=2, relief=SUNKEN)
		self.widget.pack(padx=2, pady=2)
	
	def set(self,Color):
		self.widget.config(bg = clrtxt(Color))


# Standard labeled swatch here, for the results
# The label widget is called txtlbl.
# It's an Entry to allow copying out
class LabeledSwatch:
	def __init__(self,Parent):
		self.frame = Frame(Parent)		
		self.frame.pack()
		
		self.swatch = Swatch(self.frame)
		self.swatch.widget.pack(side=LEFT)
		
		self.hexlbl = Entry(self.frame, width=8)
		self.hexlbl.pack(side=LEFT)
		
		self.txtlbl = Entry(self.frame, width=48)
		self.txtlbl.pack(side=LEFT)
		
	def set(self,ClrLbl):
		self.swatch.set(ClrLbl[0])
		
		self.hexlbl.delete(0,END)
		self.hexlbl.insert(0,clrtxt(ClrLbl[0]))
		
		lbltxt = ', '.join(ClrLbl[1])
		self.txtlbl.delete(0,END)
		self.txtlbl.insert(0,lbltxt)


# Distance function
# Actually square of distance as function of color-channel values
# No perceptual adjustment
def dist(c1,c2):
	cdiff = [c2[i]-c1[i] for i in xrange(3)]
	
	# Sum of differences (approximation of intensity difference)
	#dsum = sum(cdiff)
	
	# Sum of square of differences (more proper sort of difference)
	dsqr = 0
	for i in xrange(3):
		dsqr += cdiff[i]**2
	
	# Different weightings
	d = dsqr
	#d = dsqr - dsum**2/4
	#d = dsqr + dsum**2
	
	return d

# Selected color
SelColor = (127,127,127)

# Set the colors from that
def SetColor():
	ClSlSwatch.set(SelColor)

	ClSlText.delete(0,END)
	ClSlText.insert(0,clrtxt(SelColor))
	
	# Find color distance, then sort
	DistancesForColors = [(dist(SelColor,c[0]),c) for c in Colors]
	DistancesForColors.sort(lambda a,b: cmp(a[0],b[0]))
	
	# Use the first of the colors
	for i in xrange(NumLabeledSwatches):
		LabeledSwatches[i].set(DistancesForColors[i][1])


# Select it
def GetColor():
	global SelColor
	ColorTuple, ColorHex = tkColorChooser.askcolor(SelColor)
	
	if ColorTuple != None:
		SelColor = ColorTuple
		SetColor()

# Start with...
Root = Tk()
Root.resizable(False,False)

# Color selection:
ClSlFrame = Frame(Root)
ClSlFrame.config(bd=2, relief=RIDGE)
ClSlFrame.grid(row=0, column=0, sticky=N, padx=2, pady=2)

lbl0 = Label(ClSlFrame, text="Selected Color")
lbl0.pack(side=TOP)

# The color selected
ClSlSwatch = Swatch(ClSlFrame)

# For copying out the color value
ClSlText = Entry(ClSlFrame, width=9);
ClSlText.pack()

# Selection action
ClSlButton = Button(ClSlFrame, text="Select", command=GetColor)
ClSlButton.pack()

# Result display
ResFrame = Frame(Root)
ResFrame.config(bd=2, relief=RIDGE)
ResFrame.grid(row=0, column=1, sticky=N, padx=2, pady=2)

lbl1 = Label(ResFrame, text="X11 Color")
lbl1.pack(side=TOP)

NumLabeledSwatches = 20
LabeledSwatches = [LabeledSwatch(ResFrame) for i in xrange(NumLabeledSwatches)]

# Initial fill-in
SetColor()

Root.mainloop()

# Consider improvements