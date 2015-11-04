//
//  HRDebugModel.m
//  QHRDebug
//
//  Created by hongrisong on 15/7/3.
//  Copyright (c) 2015年 hongrisong. All rights reserved.
//

#import "HRDebugModel.h"
#import "SharedXcode.h"

@implementation HRDebugModel

+ (NSArray*)findItemsWithPath:(NSString*)projectPath{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    NSString *shellPath=[[NSBundle bundleForClass:[self class]] pathForResource:@"find" ofType:@"sh"];
    
    NSLog(@"shellPath:%@",shellPath);
    
    [task setArguments:@[shellPath,projectPath]];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSLog(@"Path:%@\nOUTPUT:%@",projectPath,string);
    
    NSArray *results=[string componentsSeparatedByString:@"\n"];
    
    NSMutableArray *arr=[NSMutableArray array];
    for (NSString *line in results) {
        if (line.length>4) {
            [arr addObject:[self itemFromLine:line]];
        }
    }
    return arr;
}


+(HRDebugItem*)itemFromLine:(NSString*)line{
    NSLog(@"line :%@",line);
    
    NSArray *cpt=[line componentsSeparatedByString:@":"];
    if (cpt.count<4) {
        return nil;
    }
    HRDebugItem *item=[[HRDebugItem alloc] init];
    item.filePath=cpt[0];
    item.lineNumber=[cpt[1] integerValue];
    
    item.typeString=cpt[3];
    
    if (cpt.count==4) {
        item.content=[cpt[3] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        
    }else{
        //add the other contents back
        NSString *s=cpt[3];
        int i=3;
        while (i<cpt.count-1) {
            i++;
            s=[s stringByAppendingFormat:@":%@",cpt[i]];
        }
        item.content=[s stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    }
    return item;
}

+(void)openItem:(HRDebugItem *)item{
    
    //IDESourceCodeEditor *editor=[self currentEditor];
    
    //NSURL *fileURL=[NSURL fileURLWithPath:item.filePath];
    //open the file
    BOOL result=[[NSWorkspace sharedWorkspace] openFile:item.filePath withApplication:@"Xcode"];
    
    //open the line
    if (result) {
        IDESourceCodeEditor *editor=[SharedXcode currentEditor];
        NSTextView *textView=editor.textView;
        if (textView) {
            NSString *viewContent = [textView string];
            NSRange range= [viewContent lineRangeForRange:NSMakeRange(item.lineNumber, 1)];
            
            //FIXME: the line is not selected or highlighted
            [textView setSelectedRange:range];
            [textView selectLine:nil];
            
        }else{
            //FIXME: pretty slow to open file with applescript
            
            NSString *theSource = [NSString stringWithFormat: @"do shell script \"xed --line %ld \" & quoted form of \"%@\"", item.lineNumber,item.filePath];
            NSAppleScript *theScript = [[NSAppleScript alloc] initWithSource:theSource];
            [theScript performSelectorInBackground:@selector(executeAndReturnError:) withObject:nil];
        }
    }
}

@end
