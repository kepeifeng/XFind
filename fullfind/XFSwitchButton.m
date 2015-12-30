//
//  XFSwitchButton.m
//  fullfind
//
//  Created by Kent on 12/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "XFSwitchButton.h"

@implementation XFSwitchButton

-(instancetype)initWithFrame:(NSRect)frameRect offImage:(NSImage *)offImage onImage:(NSImage *)onImage{
    self = [super initWithFrame:frameRect];
    if (!self) {
        return nil;
    }
    
    self.offImage = offImage;
    self.onImage = onImage;
    
    [self setBezelStyle:NSRegularSquareBezelStyle];
    [self setButtonType:NSSwitchButton];
    [self setBordered:NO];
    
    [self updateViewForCurrentState];
    self.imagePosition = NSImageOnly;
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setOnImage:(NSImage *)onImage{
    _onImage = onImage;
    [self updateViewForCurrentState];
}

-(void)setOffImage:(NSImage *)offImage{
    _offImage = offImage;
    [self updateViewForCurrentState];
}

-(void)setState:(NSInteger)state{
    [super setState:state];
    [self updateViewForCurrentState];
}

-(void)updateViewForCurrentState{

    self.image = (self.state == NSOnState)?self.onImage:self.offImage;
}
@end
