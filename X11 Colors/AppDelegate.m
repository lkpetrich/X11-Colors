//
//  AppDelegate.m
//  X11 Colors
//
//  Created by Loren Petrich on 3/9/15.
//  Copyright (c) 2015 Loren Petrich. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewerWindow.h"

@implementation AppDelegate

{
    // X11-color data object: name, color-channel values, parsed versions, sort key
    NSMutableArray *X11ColorEntries;
    
    // Keeps list of windows for retaining them
    NSMutableArray *WindowList;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Read in the X11-colors definition file
    NSString *FilePath = [[NSBundle mainBundle] pathForResource:@"rgb" ofType:@"txt"];
    NSData *XCData = [NSData dataWithContentsOfFile:FilePath];
    
    // Extract the color-component values and the color names
    NSString *XCString = [[NSString alloc] initWithData:XCData encoding:NSASCIIStringEncoding];
    NSArray *XCLines = [XCString componentsSeparatedByString:@"\n"];
    
    // Big enough for the 752 X11 colors
    X11ColorEntries = [NSMutableArray arrayWithCapacity:1024];
    for (NSString *XCLine in XCLines)
    {
        // Empty line?
        if ([XCLine length] < 12) continue;
        
        // The color-channel values
        NSRange ClrValRange;
        ClrValRange.length = 3;
        
        ClrValRange.location = 0;
        NSString *RedStr = [XCLine substringWithRange:ClrValRange];
        NSInteger RedVal = [RedStr integerValue];
        unsigned int RedInt = (unsigned int)RedVal;
        CGFloat RedFlt = RedInt/255.0;
        NSNumber *RedObj = [NSNumber numberWithInteger:RedVal];
        
        ClrValRange.location = 4;
        NSString *GreenStr = [XCLine substringWithRange:ClrValRange];
        NSInteger GreenVal = [GreenStr integerValue];
        unsigned int GreenInt = (unsigned int)GreenVal;
        CGFloat GreenFlt = GreenInt/255.0;
        NSNumber *GreenObj = [NSNumber numberWithInteger:GreenVal];
      
        ClrValRange.location = 8;
        NSString *BlueStr = [XCLine substringWithRange:ClrValRange];
        NSInteger BlueVal = [BlueStr integerValue];
        unsigned int BlueInt = (unsigned int)BlueVal;
        CGFloat BlueFlt = BlueInt/255.0;
        NSNumber *BlueObj = [NSNumber numberWithInteger:BlueVal];
     
        // The name
        NSString *RawNameStr = [XCLine substringFromIndex:12];
        NSString *NameStr = [RawNameStr
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // Hexadecinal and decimal strings
        NSString *HexStr = [NSString stringWithFormat:@"%02X%02X%02X", RedInt, GreenInt, BlueInt];
        NSString *DecStr = [NSString stringWithFormat:@"%u,%u,%u", RedInt, GreenInt, BlueInt];
        
        // Color object
        NSColor *Color = [NSColor colorWithCalibratedRed:RedFlt green:GreenFlt blue:BlueFlt alpha:1.0];
        
        // Image object for displaying the color
        NSSize ImageSize = NSMakeSize(72, 24);
        NSImage *Image = [[NSImage alloc] initWithSize:ImageSize];
        
        [Image lockFocus];
        
        [Color setFill];
        [NSBezierPath fillRect:NSMakeRect(0, 0, ImageSize.width, ImageSize.height)];
        
        [[NSColor blackColor] setStroke];
        [NSBezierPath setDefaultLineWidth:1];
        [NSBezierPath strokeRect:NSMakeRect(0.5, 0.5, ImageSize.width-1, ImageSize.height-1)];
        
        [Image unlockFocus];
        
        // Placeholder for the sort key
        NSNull *NullValue = [NSNull null];
        
        // Made mutable so that we can change the sort key
        NSMutableDictionary *XCEntry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        NameStr, @"name",
                                        RedObj, @"red", GreenObj, @"green", BlueObj, @"blue",
                                        HexStr, @"hexstr", DecStr, @"decstr",
                                        Image, @"color",
                                        NullValue, @"sortkey", nil];
        
        [X11ColorEntries addObject:XCEntry];
    }
    
    WindowList = [NSMutableArray arrayWithCapacity:1024];
    
    // Make a viewer
    [self newDocument:self];
}

- (IBAction)newDocument:(id)sender
{
    // Make a viewer
    ViewerWindow *Viewer = [[ViewerWindow alloc] initWithData:X11ColorEntries];
    [Viewer showWindow:self];
    [WindowList addObject:Viewer];
}


@end
