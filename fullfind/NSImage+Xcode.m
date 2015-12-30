//
//  NSImage+Xcode.m
//  fullfind
//
//  Created by Kent on 12/28/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "NSImage+Xcode.h"
#import "fullfind.h"

@implementation NSImage (Xcode)

+(NSBundle *)currentBundle{
    static NSBundle * gCurrentBundle;
    if (!gCurrentBundle) {
        gCurrentBundle = [NSBundle bundleForClass:[fullfind class]];
    }
    
    return gCurrentBundle;
}

+(NSImage *)ak_imageNamed:(NSString *)imageName{

    NSString *path = [[NSImage currentBundle] pathForImageResource:imageName];
    NSData * data = [NSData dataWithContentsOfFile:path];
    return [[NSImage alloc] initWithData:data];
}
@end
