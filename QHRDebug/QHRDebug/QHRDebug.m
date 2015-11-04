//
//  QHRDebug.m
//  QHRDebug
//
//  Created by hongrisong on 15/7/1.
//  Copyright (c) 2015年 hongrisong. All rights reserved.
//

#import "QHRDebug.h"
#import "SharedXcode.h"
#import "HRDebugListController.h"
#import "NSTextView+Addition.h"
#import "NSString+Addition.h"
#import "VVKeyboardEventSender.h"

#define StringIsNullOrEmpty(str) (str==nil || [(str) isEqual:[NSNull null]] ||[str isEqualToString:@""])

//static NSString *_selectedText = @"";
static QHRDebug* sharedPlugin=nil;


@interface QHRDebug()
@property (nonatomic, strong) HRDebugListController *windowController;
@property (nonatomic, strong) dispatch_queue_t textCheckQueue;
@end

@implementation QHRDebug
#pragma mark - Plugin Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
    NSLog(@"QHRDebug插件被加载启动");
}

- (id)init
{
    if (self = [super init]) {
        self.textCheckQueue = dispatch_queue_create("com.shr.textCheckQueue", NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
        NSLog(@"QHRDebug applicationDidFinishLaunching");
    }
    return self;
}


- (void) applicationDidFinishLaunching: (NSNotification*) notification {
    
    //DEBUG Plugin选中替换
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification
                                               object:nil];
    //@property Plugin
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textStorageDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:nil];
    
    
    //add menu
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"View"];
    
    [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"QHRDebug Plugin"
                                                         action:@selector(insertTextView:)
                                                  keyEquivalent:@"c"];
    [newMenuItem setTarget:self];
    [newMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
    
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"QHRDebug List"
                                                                action:@selector(toggleList)
                                                         keyEquivalent:@"x"];
        [actionMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        
        [actionMenuItem setTarget:self];
        [[editMenuItem submenu] addItem:actionMenuItem];
    }
    
    if (editMenuItem) {
        NSLog(@"QHRDebug add editMenuItem");
        [[editMenuItem submenu] addItem:newMenuItem];
        //[newMenuItem release];
    }
}


- (void)textViewAddMenu
{
    
//    NSTextView * textView = [SharedXcode textView];
//    NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"QHRDebug Plugin"
//                                                         action:@selector(insertTextView:)
//                                                  keyEquivalent:@""];
//    [newMenuItem setTarget:self];
//    NSMenu *defaultMenu = [NSTextView defaultMenu];
//    [defaultMenu addItem:newMenuItem];
    
//    [NSEvent mouseEventWithType:NSRightMouseUp location:NSMakePoint(50,50) modifierFlags:0 timestamp:1 windowNumber:[[self window] windowNumber] context:[NSGraphicsContext currentContext] eventNumber:1 clickCount:1 pressure:0.0];
    
//    NSEvent *theEvent = [NSEvent
//                mouseEventWithType:NSRightMouseUp
//                location:textView.frame.size
//                modifierFlags:0
//                timestamp:1
//                windowNumber:[[self window] windowNumber]
//                context:[NSGraphicsContext currentContext]
//                eventNumber:1
//                clickCount:1
//                pressure:0.0];
    
    //[NSMenu popUpContextMenu:defaultMenu withEvent:nil forView:textView];
}

//DEBUG plugin
- (void)selectionDidChange:(NSNotification*)notification {
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        NSTextView* textView = (NSTextView *)[notification object];
        NSArray* selectedRanges = [textView selectedRanges];
        if (selectedRanges.count==0){
            return;
        }
        NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        NSString* text = textView.textStorage.string;
        self.selectedText = [text substringWithRange:selectedRange];
        NSLog(@"QHRDebug selectionDidChange notification  *****%@",self.selectedText);
    }
}

//property plugin
- (void)textStorageDidChange:(NSNotification*)notification
{
    if (![[notification object] isKindOfClass:NSClassFromString(@"DVTSourceTextView")]) {
        return;
    }
    
    //在后台线程里做。
    dispatch_async(self.textCheckQueue, ^{
        NSTextView *textView = (NSTextView *)[notification object];
        NSString *currentLine = [textView textOfCurrentLine];
        //empty should be ignored
        if (!currentLine || currentLine.length == 0) {
            return;
        }
        //replace @ps 等
        [self replaceOtherWithCurrentLine:currentLine textView:textView];
    });
}


/**
 *  查看DEBUG
 */
- (void)toggleList
{
    if (self.windowController.window.isVisible) {
        [self.windowController.window close];
    }else{
        if (self.windowController==nil) {
            HRDebugListController *wc=[[HRDebugListController alloc] initWithWindowNibName:@"HRDebugListController"];
            self.windowController=wc;
            self.windowController.window.title= [[SharedXcode workspaceDocument].displayName stringByDeletingLastPathComponent];
        }
        
        NSString *projectPath= [[[SharedXcode workspaceDocument].workspace.representingFilePath.fileURL
                                 path]
                                stringByDeletingLastPathComponent];
        
        //!!!: how about the path is nil?
        self.windowController.projectPath=projectPath;
        [self.windowController.window makeKeyAndOrderFront:nil];
        
        [self.windowController refresh:nil];
    }
}

/**
 *  快捷键插入
 *
 *  @param origin
 */
- (void) insertTextView: (id) origin {
    
    if(self.selectedText && [self.selectedText isKindOfClass:[NSString class]]){
        if(self.selectedText.length > 0){
            NSString *documentationString = @"";
            documentationString = [documentationString stringByAppendingString:@"#if DEBUG \n"];
            documentationString = [documentationString stringByAppendingString:self.selectedText];
            documentationString = [documentationString stringByAppendingString:@"\n#endif"];
            NSLog(@"QHRDebug insertTextView  *****%@",documentationString);
            
            NSTextView * textView = [SharedXcode textView];
            
            [textView insertText:documentationString];
        }
    }
}


//匹配快捷键
/*
 @ps  对应 strong 
 @pa  对应 assgin
 @pw  对应 weak
 */
- (BOOL)replaceOtherWithCurrentLine:(NSString*)currentLine textView:(NSTextView*)textView
{
    //定义快捷键
    //对于@ps,@pw,@pa 作为默认的。如果存储的没找到就放在最后面，检测这三个默认的
    NSArray * const defaultArray = @[
                                  @{
                                      @"regex":@"^\\s*@ps$",
                                      @"replaceContent": @"@property (nonatomic, strong) <type> <name>"
                                   },
                                  @{
                                      @"regex":@"^\\s*@pw$",
                                      @"replaceContent": @"@property (nonatomic, weak) <type> <name>"
                                  },
                                  @{
                                      @"regex":@"^\\s*@pa$",
                                      @"replaceContent": @"@property (nonatomic, assign) <type> <name>"
                                  },
                                ];
    NSMutableArray *finalReplaceOthers = nil;
    if (finalReplaceOthers) {
        [finalReplaceOthers addObjectsFromArray:defaultArray];
    }else{
        finalReplaceOthers = [defaultArray mutableCopy];
    }
    for (NSDictionary *aRegexDict in finalReplaceOthers) {
        //找到正则
        NSString *regex = aRegexDict[@"regex"];
        //找到替换内容
        NSString *replaceContent = aRegexDict[@"replaceContent"];
        if (StringIsNullOrEmpty(regex)||StringIsNullOrEmpty(replaceContent)) {
            continue;
        }
        
        //检测是否匹配
        if(![currentLine vv_matchesPatternRegexPattern:regex]){
            continue;
        }
        //按键以完成替换
        [self removeCurrentLineAndInputContent:replaceContent textView:textView];
        return YES;
        
    }
    
    return NO;
    
}

#pragma mark - auto input content and remove orig conten of current line
- (void)removeCurrentLineAndInputContent:(NSString*)replaceContent textView:(NSTextView*)textView
{
    //记录下光标位置，找到此行开头的位置
    NSUInteger currentLocation = [textView locationOfCurrentLine];
    NSUInteger tabBeginLocation = currentLocation;
    
    //根据replaceContent里的内容检查是否需要自动Tab
    BOOL isNeedAutoTab = NO;
    if([replaceContent vv_matchesPatternRegexPattern:@"<#\\w+#>"]){
        isNeedAutoTab = YES;
        
        //找到第一个可tab的所在位置
        NSLog(@"replaceContent: %@",replaceContent);
        NSArray *array = [replaceContent vv_stringsByExtractingGroupsUsingRegexPattern:@"(<#\\w+#>)"];
        if (array.count<=0) {
            return;
        }
        NSLog(@"replaceContent array[0]: %@",array[0]);
        NSUInteger index = [replaceContent rangeOfString:array[0]].location;
        if (index==NSNotFound) {
            isNeedAutoTab = NO;
        }else{
            tabBeginLocation = currentLocation+index;
        }
    }
    
    //保存以前剪切板内容
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    NSString *originPBString = [pasteBoard stringForType:NSPasteboardTypeString];
    
    //复制要添加内容到剪切板
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:replaceContent forType:NSStringPboardType];
    
    dispatch_block_t block = ^{
        VVKeyboardEventSender *kes = [[VVKeyboardEventSender alloc] init];
        BOOL useDvorakLayout = [VVKeyboardEventSender useDvorakLayout];
        
        [kes beginKeyBoradEvents];
        
        //光标移到此行结束的位置,这样才能一次把一行都删去
        [textView setSelectedRange:NSMakeRange([textView endLocationOfCurrentLine]+1, 0)];
        //删掉当前这一行光标位置前面的内容 Command+Delete
        [kes sendKeyCode:kVK_Delete withModifierCommand:YES alt:NO shift:NO control:NO];
        
        //粘贴剪切板内容
        NSInteger kKeyVCode = useDvorakLayout?kVK_ANSI_Period : kVK_ANSI_V;
        [kes sendKeyCode:kKeyVCode withModifierCommand:YES alt:NO shift:NO control:NO];
        
        //这个按键用来模拟下上个命令执行完毕了，然后需要还原剪切板 ,按键是同步进行的,所以接到F20的时候应该之前的都执行完毕了
        [kes sendKeyCode:kVK_F20];
        
        static id eventMonitor = nil;
        eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *incomingEvent) {
            if ([incomingEvent type] == NSKeyDown && [incomingEvent keyCode] == kVK_F20) {
                [NSEvent removeMonitor:eventMonitor];
                eventMonitor = nil;
                
                //还原剪切板
                [pasteBoard setString:originPBString forType:NSStringPboardType];
                
                if (isNeedAutoTab) {
                    //光标移到tab开始的位置
                    [textView setSelectedRange:NSMakeRange(tabBeginLocation, 0)];
                    //Send a 'tab' after insert the doc. For our lazy programmers. :)
                    [kes sendKeyCode:kVK_Tab];
                }
                
                [kes endKeyBoradEvents];
                
                //让默认行为无效
                return nil;
            }
            return incomingEvent;
        }];
    };
    //键盘操作放到主线程去做
    dispatch_async(dispatch_get_main_queue(), block);
    
}

@end
