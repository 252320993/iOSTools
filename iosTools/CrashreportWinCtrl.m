//
//  CrashreportWinCtrl.m
//  iosTools
//
//  Created by meitu on 16/7/1.
//  Copyright © 2016年 ycw. All rights reserved.
//

#import "CrashreportWinCtrl.h"
#import "CrashFileInfo.h"

@implementation CrashreportWinCtrl
@synthesize delegate = _delegate;

-(instancetype)init{
    self = [super initWithWindowNibName:@"CrashreportWin" owner:self];
    if (self) {
    }
    return self;
}

-(void)dealloc{
    [_crashFileArray release],_crashFileArray = nil;
    [super dealloc];
}

-(void)setCrashFileArray:(NSArray *)CrashFileArray{
    [_crashFileArray release],_crashFileArray = nil;
    _crashFileArray = [CrashFileArray retain];
    [_tableView reloadData];
}

-(NSArray *)crashFileArray{
    return _crashFileArray;
}


-(void)windowDidLoad{
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
}

#pragma mark - tableview data source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [[self crashFileArray] count];
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
        CrashFileInfo *fileinfo = [self.crashFileArray objectAtIndex:row];
        return fileinfo.fileName;
}

#pragma mark - tableview delegate
-(NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes{
    NSInteger row = [proposedSelectionIndexes firstIndex];
    CrashFileInfo *selectedFile = [self.crashFileArray objectAtIndex:row];
    if (_delegate && [_delegate respondsToSelector:@selector(readCrashReportfileContentFromPath:)]) {
        NSString *strContent = [_delegate readCrashReportfileContentFromPath:selectedFile.filePath];
        [_lblContent setString:strContent?strContent:@"不支持该格式的预览"];
    }
    return proposedSelectionIndexes;
}


#pragma mark - Action
- (IBAction)clickCopyAllCrashreportBtn:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(copyAllCrashreportFile)]) {
        [_delegate copyAllCrashreportFile];
    }
}
@end
