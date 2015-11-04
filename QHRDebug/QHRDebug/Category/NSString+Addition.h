//
//  NSString+Addition.h
//
//  Created by Molon on 13-11-12.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Addition)

-(NSString *) vv_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement;
-(NSString *) vv_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase;
-(NSString *) vv_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
-(NSArray *) vv_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex;
-(NSArray *) vv_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
-(BOOL) vv_matchesPatternRegexPattern:(NSString *)regex;
-(BOOL) vv_matchesPatternRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;

@end
