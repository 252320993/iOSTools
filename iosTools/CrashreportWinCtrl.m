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
        NSString *strContent = [_delegate readCrashReportfileContentFromPath:selectedFile.deviceFilePath];
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

- (IBAction)clickSymbolizationBtn:(id)sender {
    if ([self checkDSYMFile] && [self checkTableViewSelected]) {
        CrashFileInfo *fileInfo = [self.crashFileArray objectAtIndex:[_tableView selectedRow]];
        NSString *strLocalPath = [NSString stringWithFormat:@"%@%@",localBakcupPath,@"CrashReport/"];
        if (_delegate && [_delegate respondsToSelector:@selector(copySingleCrashFile:toDesFolder:)]) {
            [_delegate copySingleCrashFile:fileInfo.deviceFilePath toDesFolder:strLocalPath];
        }
        fileInfo.localFilePath = [strLocalPath stringByAppendingString:fileInfo.fileName];
        
        NSString *strSymbolToolPath = [[NSBundle mainBundle] pathForResource:@"symbolicatecrash" ofType:nil];
        NSTask *symbolTask = [[NSTask alloc] init];
        [symbolTask setEnvironment:[NSDictionary dictionaryWithObject:@"/Applications/Xcode.app/Contents/Developer" forKey:@"DEVELOPER_DIR"]];
        [symbolTask setLaunchPath:strSymbolToolPath];
        [symbolTask setArguments:[NSArray arrayWithObjects:fileInfo.localFilePath,_lblDSYMFile.stringValue, nil]];
        
        NSPipe *pipe = [[NSPipe alloc] init];
        [symbolTask setStandardOutput:pipe];
        
        NSFileHandle *filehandle = [pipe fileHandleForReading];
        
        [symbolTask launch];
        [symbolTask waitUntilExit];
        int ret = [symbolTask terminationStatus];
        if (ret == 0) {
            NSString *strSymbol = [[NSString alloc] initWithData:[filehandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
            [_lblContent setString:strSymbol];
            
            NSString *strDestFileFolder = [NSString stringWithFormat:@"%@%@",localBakcupPath,@"symbolCrashReport/"];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:strDestFileFolder]) {
                [fm createDirectoryAtPath:strDestFileFolder withIntermediateDirectories:YES attributes:nil error:nil];
            }
            [strSymbol writeToFile:[strDestFileFolder stringByAppendingString:fileInfo.fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [strSymbol release],strSymbol = nil;
        }
        
        [pipe release], pipe = nil;
        [symbolTask release],symbolTask = nil;
        
    }
}

- (IBAction)clickCheckDSYMFileBtn:(id)sender
{
    if (![self checkDSYMFile]) {
        return;
    }
    
    NSTask *checkTask = [[NSTask alloc] init];
    [checkTask setLaunchPath:@"/usr/bin/dwarfdump"];
    [checkTask setArguments:[NSArray arrayWithObjects:@"--uuid",_lblDSYMFile.stringValue, nil]];
    
    NSPipe *pipe = [[NSPipe alloc] init];
    [checkTask setStandardOutput:pipe];
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    
    [checkTask launch];
    [checkTask waitUntilExit];
    
    int iRet = [checkTask terminationStatus];
    
    if (iRet == 0) {
        NSString *strResult = [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        NSArray *uuidArray = [self UUIDFromdwarfdumpResult:strResult];
        NSString *crashUUID = [[self UUIDFromCrashString:_lblContent.string] uppercaseString];
        BOOL bRet = NO;
        for (NSString *strUUID in uuidArray) {
            if ([strUUID isEqualToString:crashUUID]) {
                bRet = YES;
            }
        }
        
        if (!bRet) {
            [_lblCheckResult setStringValue:@"警告！UUID不匹配，符号化可能有误！"];
        }
        else{
            [_lblCheckResult setStringValue:@"匹配成功！"];
        }
    }

    
    [pipe release],pipe = nil;
    [checkTask release],checkTask = nil;
}

-(NSString *)UUIDFromCrashString:(NSString *)strContent{
    NSString *sRet = @"";
    NSRange binaryRange = [strContent rangeOfString:@"Binary Images:"];
    if (binaryRange.location != NSNotFound) {
        sRet = [strContent substringFromIndex:binaryRange.location];
        NSRange leftArrowRange = [sRet rangeOfString:@"<"];
        if (leftArrowRange.location != NSNotFound) {
            sRet = [sRet substringFromIndex:leftArrowRange.location + 1];
            NSRange rightArrowRange = [sRet rangeOfString:@">"];
            if (rightArrowRange.location != NSNotFound) {
                sRet = [sRet substringToIndex:rightArrowRange.location];
            }
        }
    }
    
    return sRet;
}

-(NSArray*)UUIDFromdwarfdumpResult:(NSString *)strContent{
    NSMutableArray *uuidArray = [NSMutableArray arrayWithCapacity:2];
    NSRange firstUUIDrange = [strContent rangeOfString:@"UUID: "];
    if (firstUUIDrange.location != NSNotFound) {
        NSString *strFirstUUID = [strContent substringWithRange:NSMakeRange(firstUUIDrange.location + firstUUIDrange.length, 36)];
        [uuidArray addObject:[strFirstUUID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    }
    
    NSRange secondUUIDrange = [strContent rangeOfString:@"UUID: " options:NSBackwardsSearch];
    if (secondUUIDrange.location != NSNotFound) {
        NSString *strSecondUUID = [strContent substringWithRange:NSMakeRange(secondUUIDrange.location + secondUUIDrange.length, 36)];
        [uuidArray addObject:[strSecondUUID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    }
    
    return uuidArray;
}

-(BOOL)checkDSYMFile{
    BOOL bRet = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    bRet = [fm fileExistsAtPath:[_lblDSYMFile stringValue]];
    if (!bRet) {
        [self showAlertWithText:@"Please select a dSYM file!"];
    }
    
    return bRet;
}

-(BOOL)checkTableViewSelected{
    BOOL bRet = NO;
    if ([_tableView selectedRow] != -1) {
        bRet = YES;
    }
    else{
        [self showAlertWithText:@"Please select a crash file from left table!"];
    }
    return bRet;
}

-(void)showAlertWithText:(NSString *)strContent{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setInformativeText:strContent];
    [alert setMessageText:@"Warning!"];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
    [alert release],alert = nil;

}
@end
