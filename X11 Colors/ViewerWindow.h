//
//  ViewerWindow.h
//  X11 Colors
//
//  Created by Loren Petrich on 3/10/15.
//  Copyright (c) 2015 Loren Petrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewerWindow : NSWindowController

// Init with loading the data

- (id)initWithData:(NSMutableArray *)XCData;

@end
