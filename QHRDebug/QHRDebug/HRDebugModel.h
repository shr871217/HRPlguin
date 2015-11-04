//
//  HRDebugModel.h
//  QHRDebug
//
//  Created by hongrisong on 15/7/3.
//  Copyright (c) 2015年 hongrisong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRDebugItem.h"
#import <AppKit/AppKit.h>

@interface HRDebugModel : NSObject

+ (NSArray*)findItemsWithPath:(NSString*)projectPath;

+(void)openItem:(HRDebugItem*)item;

@end
