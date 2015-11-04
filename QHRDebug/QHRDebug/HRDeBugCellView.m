//
//  HRDeBugCellView.m
//  QHRDebug
//
//  Created by hongrisong on 15/7/3.
//  Copyright (c) 2015年 hongrisong. All rights reserved.
//

#import "HRDeBugCellView.h"

@implementation HRDeBugCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSImageView *iv=[[NSImageView alloc] initWithFrame:NSMakeRect(0, 10, 16, 16)];
        iv.image=[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:@"checkmark_off"]];
        [self addSubview:iv];
        
        NSTextField *titleField=[[NSTextField alloc] initWithFrame:NSMakeRect(20, 15, frame.size.width-20, 20)];
        titleField.font=[NSFont systemFontOfSize:14];
        [self addSubview:titleField];
        self.titleField=titleField;
        
        
        NSTextField *fileField=[[NSTextField alloc] initWithFrame:NSMakeRect(20, 0, frame.size.width-20, 15)];
        fileField.font=[NSFont systemFontOfSize:11];
        fileField.textColor=[NSColor darkGrayColor];
        [self addSubview:fileField];
        self.fileField=fileField;
        
        
        [titleField setBezeled:NO];
        [titleField setDrawsBackground:NO];
        [titleField setEditable:NO];
        [titleField setSelectable:NO];
        
        [fileField setBezeled:NO];
        [fileField setDrawsBackground:NO];
        [fileField setEditable:NO];
        [fileField setSelectable:NO];
        
    }
    return self;
}

@end
