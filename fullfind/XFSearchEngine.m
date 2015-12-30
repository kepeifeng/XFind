//
//  XFSearchEngine.m
//  fullfind
//
//  Created by Kent on 12/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "XFSearchEngine.h"

@implementation XFSearchEngine

-(instancetype)initWithTextStorage:(DVTSourceTextStorage *)textStorage document:(IDESourceCodeDocument *)document{
    if ((self = [super init]) == nil) {
        return nil;
    }
    self.textStorage = textStorage;
    self.document = document;
    
    return self;
}

-(NSArray *)findAllRangeOf:(NSString *)substring in:(NSString *)string
                limitRange:(NSRange)limitRange
               withOptions:(XFSearchOption)options
           firstRangeIndex:(NSUInteger *)firstRangeIndex
             afterPosition:(NSUInteger)position{
    
    
    NSRange searchRange = limitRange;
    NSRange foundRange;
    NSMutableArray * rangeArray = [[NSMutableArray alloc] init];
    NSInteger index = NSNotFound;
    NSUInteger count = 0;
    
    NSStringCompareOptions compareOptions = 0;
    if ((options & XFSearchOptionCaseSensitive) != XFSearchOptionCaseSensitive) {
        compareOptions = compareOptions | NSCaseInsensitiveSearch;
    }
    while (searchRange.location < limitRange.location + limitRange.length) {
        
        foundRange = [string rangeOfString:substring options:compareOptions range:searchRange];
        if (foundRange.location != NSNotFound) {
            // found an occurrence of the substring! do stuff here
            [rangeArray addObject:[NSValue valueWithRange:foundRange]];
            if (foundRange.location > position && index == NSNotFound) {
                index = count;
            }
            searchRange.location = foundRange.location+foundRange.length;
            searchRange.length = limitRange.location + limitRange.length - searchRange.location;
            
        } else {
            // no more substring to find
            break;
        }
        count++;
    }
    
    if (firstRangeIndex) {
        *firstRangeIndex = index;
    }
    
    return rangeArray;
}

-(NSString *)replaceTextAtRange:(NSRange)range withText:(NSString *)text{

    NSString * newString = text;
    [self.textStorage replaceCharactersInRange:range withString:newString withUndoManager:self.document.undoManager];
    
    return newString;
}

-(void)replaceAllOccurence:(NSString *)substring
                withString:(NSString *)replaceString
                limitRange:(NSRange)limitRange
               withOptions:(XFSearchOption)options{
    
//    NSRange searchRange = limitRange;
//    NSRange foundRange;
//    NSMutableArray * rangeArray = [[NSMutableArray alloc] init];
//    NSInteger index = NSNotFound;
//    NSUInteger count = 0;
    
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

@end
