//
//  fullfind.h
//  fullfind
//
//  Created by Kent on 12/23/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <AppKit/AppKit.h>

@class fullfind;

static fullfind *sharedPlugin;

@interface fullfind : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end