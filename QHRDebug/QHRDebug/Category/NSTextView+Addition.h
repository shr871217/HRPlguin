//
//  NSTextView+Addition.h
//  MLAutoReplace
//
//  Created by molon on 4/25/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (Addition)

- (NSInteger)currentCurseLocation;

//get begin location of current curse location line
- (NSUInteger)locationOfCurrentLine;

- (NSUInteger)endLocationOfCurrentLine;
//get text of current curse location line
- (NSString *)textOfCurrentLine;

@end
