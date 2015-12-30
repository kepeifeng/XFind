//
//  XFSearchEngine.h
//  fullfind
//
//  Created by Kent on 12/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCFXcodePrivate.h"

typedef NS_OPTIONS(NSUInteger, XFSearchOption){
    XFSearchOptionNone = 0,
    XFSearchOptionRegularExpression = 1 << 0,
    XFSearchOptionCaseSensitive = 1 << 1,
};

@interface XFSearchEngine : NSObject

-(instancetype)initWithTextStorage:(DVTSourceTextStorage *)textStorage document:(IDESourceCodeDocument *)document;

@property (nonatomic, weak) DVTSourceTextStorage * textStorage;
@property (nonatomic, weak) IDESourceCodeDocument * document;

-(NSArray *)findAllRangeOf:(NSString *)substring in:(NSString *)string
                limitRange:(NSRange)limitRange
               withOptions:(XFSearchOption)options
           firstRangeIndex:(NSUInteger *)firstRangeIndex
             afterPosition:(NSUInteger)position;

-(NSString *)replaceTextAtRange:(NSRange)range withText:(NSString *)text;

-(void)replaceAllOccurence:(NSString *)substring
                withString:(NSString *)replaceString
                limitRange:(NSRange)limitRange
               withOptions:(XFSearchOption)options;
@end
