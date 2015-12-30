//
//  XFFindPanel.m
//  xFinderLab
//
//  Created by Kent on 12/23/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "XFFindPanel.h"
#import <objc/runtime.h>
#import <NSImage+MISSINGTint.h>
#import "NSImage+Xcode.h"
#import "XCFXcodePrivate.h"
#import "XFSwitchButton.h"
#import "XFSearchEngine.h"
#import "XFRegExpSearchEngine.h"
#import "XFTextField.h"
//#import "DTXcodeHeaders.h"

#define HIGHLIGHT_COLOR [NSColor colorWithRed:0.04 green:0.43 blue:0.71 alpha:1]

@interface XFFindPanel ()<NSTextFieldDelegate>
@property (nonatomic, readonly) NSLayoutConstraint * scrollViewTopConstraint;
@end

@implementation XFFindPanel{

    NSButton * _regButton;
    NSButton * _caseButton;
    NSButton * _wrapButton;
    NSButton * _selButton;
    
    XFTextField * _searchField;
    NSMutableArray * _rangeArray;
    NSUInteger _currentIndex;
//    NSUInteger _currentLocation;
    XFTextField * _replaceField;
    
    NSLayoutConstraint * _heightConst;
    
    BOOL _requiredRefresh;
//    NSRange _currentRange;
    
    BOOL _isReplacing;
    
    XFSearchEngine * _normalEngine;
    XFSearchEngine * _regExpEngine;
    __weak XFSearchEngine * _searchEngine;
    

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

-(void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
    
//    NSGraphicsContext * context = [NSGraphicsContext currentContext];
    [[NSColor colorWithCalibratedWhite:0.7 alpha:1] setFill];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(0, NSHeight(self.frame) - 1, NSWidth(self.frame), 1)] fill];
}

-(void)setupSearchEngine{

    _regExpEngine = [[XFRegExpSearchEngine alloc] initWithTextStorage:self.textStorage document:self.document];
    _normalEngine = [[XFSearchEngine alloc] initWithTextStorage:self.textStorage document:self.document];

    _searchEngine = _normalEngine;
}

-(void)initialSetup{

    
    
    _regButton = [[XFSwitchButton alloc] initWithFrame:[self rectForButtonAtIndex:0]
                                              offImage:[NSImage ak_imageNamed:@"reg-exp"]
                                               onImage:[[NSImage ak_imageNamed:@"reg-exp"] imageTintedWithColor:HIGHLIGHT_COLOR]];

    [_regButton setTarget:self];
    [_regButton setAction:@selector(regButtonClicked:)];
    [_regButton setToolTip:@"Regular Expression"];


    [self addSubview:_regButton];
    
    _caseButton = [[XFSwitchButton alloc] initWithFrame:[self rectForButtonAtIndex:1]
                                         offImage:[NSImage ak_imageNamed:@"case"]
                                          onImage:[[NSImage ak_imageNamed:@"case"] imageTintedWithColor:HIGHLIGHT_COLOR]];
    [_caseButton setToolTip:@"Case Sensitive"];
    [_caseButton setTarget:self];
    [_caseButton setAction:@selector(caseButtonClicked:)];
    [self addSubview:_caseButton];
    
    _wrapButton = [[XFSwitchButton alloc] initWithFrame:[self rectForButtonAtIndex:2]
                                         offImage:[NSImage ak_imageNamed:@"wrap"]
                                          onImage:[[NSImage ak_imageNamed:@"wrap"] imageTintedWithColor:HIGHLIGHT_COLOR]];
    [_wrapButton setToolTip:@"Wrap"];
    _wrapButton.target = self;
    _wrapButton.action = @selector(wrapButtonClicked:);
    _wrapButton.state = NSOnState;
    [self addSubview:_wrapButton];
    
    _selButton = [[XFSwitchButton alloc] initWithFrame:[self rectForButtonAtIndex:3]
                                        offImage:[NSImage ak_imageNamed:@"selection"]
                                         onImage:[[NSImage ak_imageNamed:@"selection"] imageTintedWithColor:HIGHLIGHT_COLOR]];
    [_selButton setToolTip:@"Find in selection"];
    [self addSubview:_selButton];
    
    _searchField = [[XFTextField alloc] initWithFrame:(NSMakeRect(NSMaxX(_selButton.frame),8,
                                                                  CGRectGetWidth(self.frame)-NSMaxX(_selButton.frame) - 80 - 5 -40, 20))];
    _searchField.delegate = self;
    [_searchField setTarget:self];
    [_searchField setAction:@selector(textFieldChanged:)];
    [_searchField setFocusRingType:(NSFocusRingTypeNone)];
    _searchField.bordered = NO;
    _searchField.autoresizingMask = NSViewWidthSizable;
    _searchField.font = [NSFont fontWithName:@"Menlo" size:12];
    _searchField.placeholderString = @"Find";

    [self addSubview:_searchField];
    
    NSButton * prevButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(_searchField.frame), 2, 40, 28)];
    prevButton.image = [NSImage imageNamed:@"arrow-left"];
    [prevButton setTarget:self];
    [prevButton setAction:@selector(prevButtonClicked:)];
    prevButton.autoresizingMask = NSViewMinXMargin;
    [self addSubview:prevButton];
    
    NSButton * nextButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(prevButton.frame), 2, 40, 28)];
    nextButton.image = [NSImage imageNamed:@"arrow-right"];
    [nextButton setTarget:self];
    [nextButton setAction:@selector(nextButtonClicked:)];
    nextButton.autoresizingMask = NSViewMinXMargin;
    [self addSubview:nextButton];
    
    NSButton * doneButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(nextButton.frame)+5, 2, 40, 28)];
    [doneButton setTitle:@"Done"];
    [doneButton setTarget:self];
    [doneButton setAction:@selector(doneButtonClicked:)];
    doneButton.autoresizingMask = NSViewMinXMargin;
    [self addSubview:doneButton];
    
    NSRect rect = _searchField.frame;
    rect.origin.y = 38;
    
    _replaceField = [[XFTextField alloc] initWithFrame:rect];
    _replaceField.autoresizingMask = NSViewWidthSizable;
    _replaceField.bordered = NO;
    _replaceField.placeholderString = @"Replacement";
    _replaceField.focusRingType = NSFocusRingTypeNone;
    _replaceField.font = [NSFont fontWithName:@"Menlo" size:12];
    [self addSubview:_replaceField];
    
    NSButton * allButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(_replaceField.frame), 32, 40, 28)];
    allButton.autoresizingMask = NSViewMinXMargin;
    [allButton setTitle:@"All"];
    allButton.target = self;
    allButton.action = @selector(replaceAllButtonClicked:);
    [self addSubview:allButton];
    
    NSButton * replaceButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSMaxX(allButton.frame), 32, 40 + 5 + 40, 28)];
    replaceButton.autoresizingMask = NSViewMinXMargin;
    [replaceButton setTitle:@"Replace"];
    replaceButton.target = self;
    replaceButton.action = @selector(replaceButtonClicked:);
    [self addSubview:replaceButton];
    
}

-(BOOL)hasFocus{
    return _searchField.hasFocus || _replaceField.hasFocus;
}

-(void)replaceAllButtonClicked:(id)sender{

    //Range
    NSRange limitRange;
    //Options
    XFSearchOption searchOption = 0;
    
    [self fetchSearchOptions:&searchOption range:&limitRange];
    [self clearHighlight];
    [_searchEngine replaceAllOccurence:_searchField.stringValue
                   withString:_replaceField.stringValue
//                           in:nil
                   limitRange:limitRange withOptions:searchOption];
}

-(void)replaceButtonClicked:(id)sender{

    [self updateSearchIfNeeded];
    
    if (_currentIndex < _rangeArray.count) {
        
        _isReplacing = YES;
        
        NSRange _currentRange = [(NSValue *)[_rangeArray objectAtIndex:_currentIndex] rangeValue];
        [self.textStorage removeAttribute:NSBackgroundColorAttributeName range:_currentRange];
//        [self.textStorage replaceCharactersInRange:_currentRange withString:_replaceField.stringValue withUndoManager:self.document.undoManager];
        
        _isReplacing = NO;
        
        NSString * newString = [_searchEngine replaceTextAtRange:_currentRange withText:_replaceField.stringValue];
        
        int lengthDiff = newString.length - _currentRange.length;
        [_rangeArray removeObjectAtIndex:_currentIndex];
        
        for (NSInteger index = _currentIndex; index < _rangeArray.count; index++) {
            NSRange range = [(NSValue *)_rangeArray[index] rangeValue];
            range.location += lengthDiff;
            [_rangeArray replaceObjectAtIndex:index
                                   withObject:[NSValue valueWithRange:range]];
        }
        
        if (_currentIndex >= _rangeArray.count) {
            _currentIndex = MAX(0, _rangeArray.count-1);
        }
    }
}

-(BOOL)isFlipped{
    return YES;
}
-(void)doneButtonClicked:(NSButton *)sender{

    [self clearHighlight];
    [self updateLayoutsForMode:(XFFindModeNone)];
}

-(void)regButtonClicked:(NSButton *)sender{

    
//    NSImage * image = [NSImage ak_imageNamed:@"reg-exp.png"];
//    sender.image = (sender.state == NSOnState)?[image imageTintedWithColor:HIGHLIGHT_COLOR]:image;
    
    _searchEngine = (sender.state == NSOnState)?_regExpEngine:_normalEngine;
    
    [self searchText];
}
-(void)caseButtonClicked:(NSButton *)sender{
    [self searchText];
}

-(void)wrapButtonClicked:(NSButton *)sender{
//    [self searchText];
}

-(void)selectedButtonClicked:(NSButton *)sender{
    [self searchText];
}

-(void)textFieldChanged:(id)sender{

    [self searchText];
}

-(void)fetchSearchOptions:(XFSearchOption *)options range:(NSRange *)range{

    //Range
    NSRange limitRange;
    if (_selButton.state == NSOnState && _textView.selectedRange.length>0) {
        limitRange = _textView.selectedRange;
    }else{
        limitRange = NSMakeRange(0, _textView.string.length);
    }
    
    if(range){
        *range = limitRange;
    }
    
    //Options
    XFSearchOption searchOption = 0;
    if (_regButton.state == NSOnState) {
        searchOption = searchOption | XFSearchOptionRegularExpression;
    }
    
    if (_caseButton.state == NSOnState) {
        searchOption = searchOption | XFSearchOptionCaseSensitive;
    }
    
    if (options) {
        *options = searchOption;
    }
    
}

-(void)searchText{

    [self clearHighlight];
    if (_searchField.stringValue.length == 0) {
        return;
    }
    
    //Range
    NSRange limitRange;
    //Options
    XFSearchOption searchOption = 0;
    
    [self fetchSearchOptions:&searchOption range:&limitRange];

    
    NSUInteger firstOccurrenceIndex;
    _rangeArray = [[_searchEngine findAllRangeOf:_searchField.stringValue in:_textView.string limitRange:limitRange
                           withOptions:searchOption firstRangeIndex:&firstOccurrenceIndex afterPosition:_textView.selectedRange.location] mutableCopy];
    _currentIndex = (firstOccurrenceIndex == NSNotFound)?0:firstOccurrenceIndex;
    
    _requiredRefresh = NO;
    
    [self highlightRanges:_rangeArray];
    [self gotoCurrentIndex];
}
-(void)clearHighlight{
    
    [self.textView.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.textView.textStorage.length)];
//    [self.textView.textStorage removeAttribute:NSStrokeColorAttributeName range:NSMakeRange(0, self.textView.textStorage.length)];

}

-(void)highlightRanges:(NSArray *)rangeArray{

    for (NSValue * rangeValue in rangeArray) {
        [self.textView.textStorage addAttributes:@{NSBackgroundColorAttributeName:[[NSColor yellowColor] colorWithAlphaComponent:0.2]}
                                           range:[rangeValue rangeValue]];
//        [self.textView.textStorage addAttribute: value: range:];
    }
}

-(void)gotoCurrentIndex{

    if (_currentIndex >= _rangeArray.count) {
        return;
    }
    
    NSRange range = [(NSValue *)[_rangeArray objectAtIndex:_currentIndex] rangeValue];
    [self.textView scrollRangeToVisible:range];
    [self.textView showFindIndicatorForRange:range];
    
}

-(void)prevButtonClicked:(id)sender{

    [self findPrevious];
}

-(void)nextButtonClicked:(id)sender{
    
    [self findNext];
}

-(NSRect)rectForButtonAtIndex:(NSUInteger)index{

    CGSize buttonSize = CGSizeMake(32, 32);
    CGFloat margin = 5;
    return NSMakeRect((buttonSize.width + margin)* index, 0, buttonSize.width, buttonSize.height);
}


-(NSLayoutConstraint *)scrollViewTopConstraint{

    NSView * targetView = self.scrollView;
    NSView * container = targetView.superview;
   
    NSLayoutConstraint * foundConstraint;
    for (NSLayoutConstraint * constraint in [container.constraints copy]) {
        if (constraint.firstItem == targetView && constraint.firstAttribute == NSLayoutAttributeTop
            && constraint.secondItem == container && constraint.secondAttribute == NSLayoutAttributeTop) {
            if (foundConstraint == nil) {
                foundConstraint = constraint;
            }else{
                [container removeConstraint:constraint];
            }
//            return constraint;
        }
    }
    
    return foundConstraint;
//    return nil;
}

-(void)showForScrollView:(NSScrollView *)scrollView andTextView:(NSTextView *)textView withReplace:(BOOL)withReplace{
    
    self.scrollView = scrollView;
    self.textView = textView;
    
    self.document = [DTXcodeUtils currentSourceCodeDocument];
    self.textStorage = (DVTSourceTextStorage *)[DTXcodeUtils currentTextStorage];
    
//    CGRect frame = self.frame;
//    frame.size.width = NSWidth(scrollView.frame);
    
    if (self.superview == nil) {
        self.autoresizingMask = NSViewMinYMargin | NSViewWidthSizable;
//        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.frame = NSMakeRect(0, NSMaxY(scrollView.frame), NSWidth(self.scrollView.frame), 0);
        
        NSView * container = self.scrollView.superview;
        
//        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;

        [container addSubview:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewTextDidChangedHandler:)
                                                     name:NSTextDidChangeNotification
                                                   object:textView];
    }
    
    [self updateLayoutsForMode:withReplace?XFFindModeFindAndReplace:XFFindModeFind];
    
    [_searchField becomeFirstResponder];
    

}

-(void)textViewTextDidChangedHandler:(NSNotification *)notification{

    if(notification.object != self.textView){
        return;
    }
    
    if (_isReplacing) {
        _requiredRefresh = YES;
        [self clearHighlight];
        
    }
    
}

-(BOOL)updateSearchIfNeeded{

    if (_requiredRefresh) {
        [self searchText];
        return YES;
    }
    return NO;
}

-(void)findNext{
    
    if ([self updateSearchIfNeeded] == YES) {
        return;
    }
    
    if (_currentIndex < _rangeArray.count-1) {
        _currentIndex++;
    }else if(_wrapButton.state == NSOnState){
        _currentIndex = 0;
    }else{
        //        return;
    }
    
    [self gotoCurrentIndex];
}
-(void)findPrevious{
    
    if ([self updateSearchIfNeeded] == YES) {
        return;
    }
    
    if(_currentIndex>0){
        _currentIndex--;
    }else if(_wrapButton.state == NSOnState) {
        _currentIndex = _rangeArray.count - 1;
    }else{
        //        return;
    }
    
    [self gotoCurrentIndex];
}


-(void)replace{


    
}

-(void)replaceAllOccurence:(NSString *)substring
                withString:(NSString *)replaceString
//                        in:(NSString *)string
                limitRange:(NSRange)limitRange
               withOptions:(XFSearchOption)options{


    NSStringCompareOptions compareOptions = 0;
    if ((options & XFSearchOptionCaseSensitive) != XFSearchOptionCaseSensitive) {
        compareOptions = compareOptions | NSCaseInsensitiveSearch;
    }
    
    NSString * origialString = [self.textStorage.string substringWithRange:limitRange];
    NSString * replacedString = [origialString stringByReplacingOccurrencesOfString:substring
                                                                           withString:replaceString
                                                                              options:compareOptions
                                                                                range:limitRange];

    [self.textStorage replaceCharactersInRange:limitRange
                                    withString:replacedString
                               withUndoManager:self.document.undoManager];

    
}

-(void)updateLayoutsForMode:(XFFindMode)mode{

    CGFloat oldHeight = NSHeight(self.frame);
    CGFloat height;
    switch (mode) {
        case XFFindModeNone:
//            rect = NSZeroRect;
            height = 0;
            break;
        case XFFindModeFind:
//            rect = NSMakeRect(0, NSMaxY(self.scrollView.frame) - 32, NSWidth(self.scrollView.frame), 32);
            height = 32;
            break;
        case XFFindModeFindAndReplace:
            height = 64;
            break;
        default:
            break;
    }
    
    NSRect scrollFrame = self.scrollView.frame;
    scrollFrame.size.height += oldHeight;
    
    NSRect rect;
    rect = NSMakeRect(0, NSMaxY(scrollFrame) - height, NSWidth(self.scrollView.frame), height);
    self.frame = rect;
//    _heightConst.constant = height;
//    [self setNeedsLayout:YES];
//    [self.animator setFrame:rect];
    
//    rect = self.scrollView.frame;
//    rect.size.height = NSHeight(rect) + height - NSHeight(self.frame);
    scrollFrame.size.height -= height;
    self.scrollView.frame = scrollFrame;
//    self.scrollViewTopConstraint.constant = height;
    
}


#pragma mark - Text Field Delegate
-(void)controlTextDidChange:(NSNotification *)obj{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchText) object:nil];
    [self performSelector:@selector(searchText) withObject:nil afterDelay:(_searchEngine == _regExpEngine)?1.0:0.3];
//    [self searchText];
}
@end


@implementation NSTextView (XF)


- (XFFindPanel *)xf_findPanel {
    return objc_getAssociatedObject(self, @selector(xf_findPanel));
}

- (void)setXf_findPanel: (XFFindPanel *)xf_findPanel {
    objc_setAssociatedObject(self, @selector(xf_findPanel), xf_findPanel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)showFindPanelWithReplace:(BOOL)withReplace{
    
    if(self.xf_findPanel == nil){
        XFFindPanel * findPanel = [[XFFindPanel alloc] init];
        self.xf_findPanel = findPanel;
    
    }
    [self.xf_findPanel showForScrollView:(NSScrollView *)self.superview.superview andTextView:self withReplace:withReplace];
}

@end
