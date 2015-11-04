//
//  HRDebugListController.m
//  QHRDebug
//
//  Created by hongrisong on 15/7/3.
//  Copyright (c) 2015年 hongrisong. All rights reserved.
//

#import "HRDebugListController.h"
#import "HRDebugItem.h"
#import "HRDebugModel.h"
#import "HRDeBugCellView.h"

@interface HRDebugListController ()<NSOutlineViewDataSource,NSOutlineViewDelegate>
@property (nonatomic,retain) IBOutlet NSOutlineView *listView;

@property(nonatomic,retain)NSMutableDictionary *data;

@end

@implementation HRDebugListController

static NSArray *types=Nil;

+(void)initialize{
    //the todo type we will show
#if DEBUG 
    types=@[@"#if"];

#endif
}


-(void)windowDidLoad{
    [super windowDidLoad];
    
    self.listView.indentationMarkerFollowsCell=NO;
    self.listView.indentationPerLevel=10.0;
    self.listView.allowsMultipleSelection=NO;
    
    self.window.level=kCGFloatingWindowLevel;
    self.data=[NSMutableDictionary dictionaryWithCapacity:5];
}

#if DEBUG

#endif

-(void)setItems:(NSArray *)items{
    _items=items;
    
    for (NSString *type in types) {
        NSPredicate *pred=[NSPredicate predicateWithFormat:@"SELF.typeString = %@",type];
        NSArray *arr=[items filteredArrayUsingPredicate:pred];
        if (arr.count) {
            [self.data setObject:arr forKey:type];
        }else{
            [self.data removeObjectForKey:type];
        }
    }
    
    [self.listView reloadData];
}

- (IBAction)refresh:(id)sender {
    if (self.projectPath==nil) {
        return;
    }
    
    //TODO: show refresh stat
    
    NSArray *items=[HRDebugModel findItemsWithPath:self.projectPath];
    self.items=items;
}


-(CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    if ([item isKindOfClass:[HRDebugItem class]]) {
        return 35.0;
    }
    return 25;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(HRDebugItem*)item {
    NSLog(@"Display %@",[item description]);
}


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(HRDebugItem*)item {
    if (![item isKindOfClass:[HRDebugItem class]]) {
        NSTableCellView *cellView= [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        cellView.textField.stringValue=(id)item;
        
        return cellView;
    } else {
        
        NSString *cellID=@"HRDebugCell";
        
        HRDeBugCellView *cellView =[outlineView makeViewWithIdentifier:cellID owner:self];
        
        if (cellView==nil) {
            cellView = [[HRDeBugCellView alloc] initWithFrame:NSMakeRect(0, 0, outlineView.bounds.size.width, 35)];
            
            cellView.identifier = cellID;
            
        }
        
        cellView.titleField.stringValue = [item.filePath lastPathComponent];
        cellView.fileField.stringValue = [NSString stringWithFormat:@"%line Number:ld",item.lineNumber];
        
        return cellView;
    }
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if (item==nil) {
        return self.data.count;
    }
    return [self.data[item] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if (item==nil) {
        return types[index];
    }
    
    return [self.data[item] objectAtIndex:index];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if ([item isKindOfClass:[HRDebugItem class]]) {
        return NO;
    }
    return YES;
}
- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
    NSOutlineView *outlineView=notification.object;
    
    NSInteger row=[outlineView selectedRow];
    
    HRDebugItem *item = [outlineView itemAtRow:row];
    
    if ([item isKindOfClass:[HRDebugItem class]]) {
        [HRDebugModel openItem:item];
        
    }else{
        [outlineView deselectRow:row];
    }
    
}

- (IBAction)openAbout:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://weibo.com/songhr871217"]];
}

@end
