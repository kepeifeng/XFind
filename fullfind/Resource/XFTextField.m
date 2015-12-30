//
//  XFTextField.m
//  fullfind
//
//  Created by Kent on 12/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "XFTextField.h"
@interface XFTextField()
@property (nonatomic, readwrite) BOOL hasFocus;
@end

@implementation XFTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(BOOL)becomeFirstResponder{

    self.hasFocus = [super becomeFirstResponder];
//    self.hasFocus = status;
    return self.hasFocus;
}

-(BOOL)resignFirstResponder{
    BOOL status = [super resignFirstResponder];
    self.hasFocus = !status;
    return status;
}
@end
