//
//  AppWindowCtrl.h
//  iosTools
//
//  Created by YangCW on 16-6-3.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppWindowCtrl : NSWindowController<NSTableViewDataSource,NSTableViewDelegate,NSWindowDelegate>
{
    IBOutlet NSTableView *_tableView;
    NSArray *appArray;

}
-(id)initWithDict:(NSDictionary*)dict;
-(void)showSelf;
@end
