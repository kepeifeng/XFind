//
//  XFRegExpSearchEngine.m
//  fullfind
//
//  Created by Kent on 12/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "XFRegExpSearchEngine.h"

@implementation XFRegExpSearchEngine{

    NSRegularExpression * _regExp;
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
    
    if ((options & XFSearchOptionRegularExpression) == XFSearchOptionRegularExpression) {
        NSRegularExpressionOptions regOptions = NSRegularExpressionAnchorsMatchLines;
        if ((options & XFSearchOptionCaseSensitive) != XFSearchOptionCaseSensitive) {
            regOptions = regOptions|NSRegularExpressionCaseInsensitive;
        }
        
        _regExp = [NSRegularExpression regularExpressionWithPattern:substring
                                                                              options:regOptions
                                                                                error:nil];
        NSArray<NSTextCheckingResult *> * resultArray = [_regExp matchesInString:string options:0 range:limitRange];
        for (NSInteger i = 0; i<resultArray.count; i++) {
            NSTextCheckingResult * result = resultArray[i];
            foundRange = result.range;
            [rangeArray addObject:[NSValue valueWithRange:foundRange]];
            if (foundRange.location > position && index == NSNotFound) {
                index = i;
            }
        }
    }
    
    
    if (firstRangeIndex) {
        *firstRangeIndex = index;
    }
    
    return rangeArray;
    
}

-(NSString *)replaceTextAtRange:(NSRange)range withText:(NSString *)text{
    
    NSMutableString * string = [[self.textStorage.string substringWithRange:range] mutableCopy];

    [_regExp replaceMatchesInString:string options:(0) range:NSMakeRange(0, string.length) withTemplate:text];
//    NSString * newString = text;
    [self.textStorage replaceCharactersInRange:range withString:string withUndoManager:self.document.undoManager];
    
    return string;
    
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
    
    NSMutableString * string = [[self.textStorage.string substringWithRange:limitRange] mutableCopy];
    [_regExp replaceMatchesInString:string options:(0) range:NSMakeRange(0, string.length) withTemplate:replaceString];

//    NSString * replacedString = [origialString stringByReplacingOccurrencesOfString:substring
//                                                                         withString:replaceString
//                                                                            options:compareOptions
//                                                                              range:limitRange];
    
    [self.textStorage replaceCharactersInRange:limitRange
                                    withString:string
                               withUndoManager:self.document.undoManager];
    
}


@end
