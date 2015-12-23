//
//  NSObject_Extension.m
//  fullfind
//
//  Created by Kent on 12/23/15.
//  Copyright © 2015 Kent. All rights reserved.
//


#import "NSObject_Extension.h"
#import "fullfind.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[fullfind alloc] initWithBundle:plugin];
        });
    }
}
@end
