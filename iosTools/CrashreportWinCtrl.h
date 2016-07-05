//
//  CrashreportWinCtrl.h
//  iosTools
//
//  Created by meitu on 16/7/1.
//  Copyright © 2016年 ycw. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CrashreportWinCtrl : NSWindowController<NSTableViewDelegate,NSTableViewDataSource>{

    IBOutlet NSTableView *_tableView;
    NSArray *_crashFileArray;
    IBOutlet NSTextView *_lblContent;
    IBOutlet NSTextField *_lblDSYMFile;
    IBOutlet NSTextField *_lblCheckResult;
    
    id _delegate;
}

@property(assign,nonatomic) NSArray *crashFileArray;
@property(assign,nonatomic) id delegate;
- (IBAction)clickCopyAllCrashreportBtn:(id)sender;
- (IBAction)clickSymbolizationBtn:(id)sender;
- (IBAction)clickCheckDSYMFileBtn:(id)sender;

@end

@protocol CrashreportDelegate <NSObject>

-(void)copyAllCrashreportFile;
-(NSString *)readCrashReportfileContentFromPath:(NSString *)strPath;
-(void)copySingleCrashFile:(NSString *)strCrashFilePath toDesFolder:(NSString *)strDestFolder;

@end