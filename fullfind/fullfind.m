//
//  fullfind.m
//  fullfind
//
//  Created by Kent on 12/23/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "fullfind.h"
//#import "DTXcodeHeaders.h"
#import "DTXcodeUtils.h"
#import "XFFindPanel.h"

#define ITEM_FIND @"Find\u2026"
#define ITEM_FIND_AND_REPLACE @"Find and Replace\u2026"
#define ITEM_FIND_NEXT @"Find Next"
#define ITEM_FIND_PREVIOUS @"Find Previous"


@interface fullfind()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) NSMutableSet *notificationSet;
@end

@implementation fullfind{

//    NSMenuItem * _originalFindItem;
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:nil object:nil];
        
        self.notificationSet = [NSMutableSet new];
    }
    return self;
}

- (void)handleNotification:(NSNotification *)notification {
    
//    NSLog(@"[NOTE]\t%@\t%@", [notification.object class], notification.name);
//    if (![self.notificationSet containsObject:notification.name]) {
//        NSLog(@"%@, %@", notification.name, [notification.object class]);
//        [self.notificationSet addObject:notification.name];
//    }
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Find"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"XFind" action:@selector(findItemClicked:) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        
        NSMenuItem * findNextItem = [[NSMenuItem alloc] initWithTitle:@"XFind Next" action:@selector(findNextItemClicked:) keyEquivalent:@""];
        [findNextItem setTarget:self];
        [[menuItem submenu] addItem:findNextItem];
        
        NSMenuItem * findPreviousItem = [[NSMenuItem alloc] initWithTitle:@"XFind Previous" action:@selector(findPreviousItemClicked:) keyEquivalent:@""];
        [findPreviousItem setTarget:self];
        [[menuItem submenu] addItem:findPreviousItem];
        
        NSMenuItem * replaceItem = [[NSMenuItem alloc] initWithTitle:@"XReplace" action:@selector(replaceItemClicked:) keyEquivalent:@""];
        replaceItem.target = self;
        [[menuItem submenu] addItem:replaceItem];
        
    }

    
}

-(void)findNextItemClicked:(id)sender{
    NSTextView * sourceTextView = (NSTextView *)[DTXcodeUtils currentSourceTextView];
    if ([self shouldResponse]) {
        [sourceTextView.xf_findPanel findNext];
        
    }else{
        [self invokeOriginalFindMenuItem:ITEM_FIND_NEXT];
    }

}
-(void)findPreviousItemClicked:(id)sender{
    NSTextView * sourceTextView = (NSTextView *)[DTXcodeUtils currentSourceTextView];
    
    if ([self shouldResponse]) {
        [sourceTextView.xf_findPanel findPrevious];    
    }else{
        [self invokeOriginalFindMenuItem:ITEM_FIND_PREVIOUS];
    }

}

-(void)invokeOriginalFindMenuItem:(NSString *)itemName{

    NSMenu * findMenu = [[[NSApp menu] itemWithTitle:@"Find"] submenu];
    NSMenuItem * _originalFindItem = [findMenu itemWithTitle:itemName];
    
    NSResponder * responder = [[NSApp keyWindow] firstResponder];
    while (responder) {
        
        if ([responder respondsToSelector:_originalFindItem.action]) {
            [responder performSelector:_originalFindItem.action withObject:_originalFindItem];
            break;
        }else{
            responder = responder.nextResponder;
        }
    }
    
}
// Sample Action, for menu item:
- (void)findItemClicked:(id)sender
{
//    [self.notificationSet removeAllObjects];

    NSTextView * sourceTextView = (NSTextView *)[DTXcodeUtils currentSourceTextView];
   
    if ([self shouldResponse]) {
        [sourceTextView showFindPanelWithReplace:NO];
    }else{
        [self invokeOriginalFindMenuItem:ITEM_FIND];
    }
    
}

-(BOOL)shouldResponse{
    NSTextView * sourceTextView = [DTXcodeUtils currentSourceTextView];
    NSResponder * firstResponder = [NSApp keyWindow].firstResponder;
    BOOL result =( firstResponder == sourceTextView || sourceTextView.xf_findPanel.hasFocus);
    return result;
}

-(void)replaceItemClicked:(id)sender{
    NSTextView * sourceTextView = [DTXcodeUtils currentSourceTextView];
    [sourceTextView showFindPanelWithReplace:YES];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
