//
//  HRDebugListController.h
//  QHRDebug
//
//  Created by hongrisong on 15/7/3.
//  Copyright (c) 2015年 hongrisong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HRDebugListController : NSWindowController

@property(nonatomic,retain) NSArray *items;
@property(nonatomic,copy) NSString *projectPath;

- (IBAction)refresh:(id)sender;

@end
