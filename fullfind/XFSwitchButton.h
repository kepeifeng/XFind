//
//  XFSwitchButton.h
//  fullfind
//
//  Created by Kent on 12/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XFSwitchButton : NSButton
-(instancetype)initWithFrame:(NSRect)frameRect offImage:(NSImage *)offImage onImage:(NSImage *)onImage;
@property (nonatomic, strong) NSImage * offImage;
@property (nonatomic, strong) NSImage * onImage;

@end
