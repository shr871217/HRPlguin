//
//  HRDebugItem.h
//  QHRDebug
//
//  Created by hongrisong on 15/7/3.
//  Copyright (c) 2015年 hongrisong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRDebugItem : NSObject
@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,assign)NSUInteger lineNumber;
@property(nonatomic,assign)int type;
@property(nonatomic,copy)NSString *typeString;
@property(nonatomic,copy)NSString *content;
@end
