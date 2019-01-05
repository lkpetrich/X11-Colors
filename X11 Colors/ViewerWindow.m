//
//  ViewerWindow.m
//  X11 Colors
//
//  Created by Loren Petrich on 3/10/15.
//  Copyright (c) 2015 Loren Petrich. All rights reserved.
//

#import "ViewerWindow.h"

static CGFloat square(CGFloat x) {return x*x;}

@implementation ViewerWindow

{
    IBOutlet NSMutableArray *X11ColorEntries;
    IBOutlet NSArrayController *XCEntriesController;
    
    IBOutlet NSColorWell *ColorSwatch;
}

// Init with loading the data

- (id)initWithData:(NSMutableArray *)XCData
{
    self = [super initWithWindowNibName:@"ViewerWindow"];
    
    [self LoadData:XCData];
    
    return self;
}

- (void)LoadData:(NSMutableArray *)XCData
{
    X11ColorEntries = [XCData copy];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [XCEntriesController setContent:self->X11ColorEntries];
    
    [self SortByColor:self];
    // Initial selection
    [XCEntriesController setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (IBAction)SortByColor:(id)sender
{
    NSColor *PickedColor = ColorSwatch.color;
    CGFloat tgtred = [PickedColor redComponent];
    CGFloat tgtgreen = [PickedColor greenComponent];
    CGFloat tgtblue = [PickedColor blueComponent];
    
    int itred = (int)(256*tgtred);
    int itgreen = (int)(256*tgtgreen);
    int itblue = (int)(256*tgtblue);
    itred = MIN(itred,255);
    itgreen = MIN(itgreen,255);
    itblue = MIN(itblue,255);
    
    NSString *Title = [NSString stringWithFormat:@"Color: #%02X%02X%02X (%d,%d,%d)",
                       itred, itgreen, itblue, itred, itgreen, itblue];
    [[self window] setTitle:Title];
    
    for (NSMutableDictionary *XCEntry in X11ColorEntries)
    {
        CGFloat entred = [(NSNumber *)[XCEntry objectForKey:@"red"] intValue] / 255.;
        CGFloat entgreen = [(NSNumber *)[XCEntry objectForKey:@"green"] intValue] / 255.;
        CGFloat entblue = [(NSNumber *)[XCEntry objectForKey:@"blue"] intValue] / 255.;
        
        CGFloat diffred = entred - tgtred;
        CGFloat diffgreen = entgreen - tgtgreen;
        CGFloat diffblue = entblue - tgtblue;
        
        CGFloat clrdist = square(diffred) + square(diffgreen) + square(diffblue);
        NSNumber * distnum = [NSNumber numberWithDouble:(double)clrdist];
        [XCEntry setObject:distnum forKey:@"distance"];
    }
    
    NSSortDescriptor *SKDesc = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    NSSortDescriptor *NMDesc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES
                                                              selector:@selector(caseInsensitiveCompare:)];
    NSArray *SDArray = [NSArray arrayWithObjects:SKDesc, NMDesc, nil];
    
    // For forcing an update
    XCEntriesController.automaticallyRearrangesObjects = YES;
    XCEntriesController.sortDescriptors = SDArray;
    XCEntriesController.automaticallyRearrangesObjects = NO;
}

- (IBAction)UseSelectionsColor:(id)sender
{
    NSArray *SelectedObjects = XCEntriesController.selectedObjects;
    NSMutableDictionary *XCEntry = (NSMutableDictionary *)[SelectedObjects objectAtIndex:0];
    
    CGFloat entred = [(NSNumber *)[XCEntry objectForKey:@"red"] intValue] / 255.;
    CGFloat entgreen = [(NSNumber *)[XCEntry objectForKey:@"green"] intValue] / 255.;
    CGFloat entblue = [(NSNumber *)[XCEntry objectForKey:@"blue"] intValue] / 255.;
   
    NSColor *Color = [NSColor colorWithCalibratedRed:entred green:entgreen blue:entblue alpha:1.0];
    ColorSwatch.color = Color;
    [self SortByColor:self];
}

@end
