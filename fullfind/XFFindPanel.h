//
//  XFFindPanel.h
//  xFinderLab
//
//  Created by Kent on 12/23/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DTXcodeUtils.h>
#import "XCFXcodePrivate.h"

typedef NS_ENUM(NSUInteger, XFFindMode){
    XFFindModeNone,
    XFFindModeFind,
    XFFindModeFindAndReplace
};

@interface XFFindPanel : NSView

@property (nonatomic, weak) NSScrollView * scrollView;
@property (nonatomic, strong) NSTextView * textView;
@property (nonatomic, weak) DVTSourceTextStorage * textStorage;
@property (nonatomic, weak) IDESourceCodeDocument * document;

@property (nonatomic, readonly) BOOL hasFocus;

-(void)showForScrollView:(NSScrollView *)scrollView andTextView:(NSTextView *)textView withReplace:(BOOL)withReplace;
-(void)findNext;
-(void)findPrevious;
@end

@interface NSTextView (XF)
@property (nonatomic, weak) XFFindPanel * xf_findPanel;
-(void)showFindPanelWithReplace:(BOOL)withReplace;
@end