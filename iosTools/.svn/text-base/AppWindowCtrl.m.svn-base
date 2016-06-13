//
//  AppWindowCtrl.m
//  iosTools
//
//  Created by YangCW on 16-6-3.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#import "AppWindowCtrl.h"

@interface AppWindowCtrl ()

@end

@implementation AppWindowCtrl

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id)init{
    self = [super initWithWindowNibName:@"AppWindowCtrl" owner:self];
    if (self) {
        ;
    }
    return self;
}

-(id)initWithDict:(NSDictionary*)dict{
    self = [self init];
    if (self) {
        NSDictionary* appDict = [[NSDictionary alloc] initWithDictionary:dict];
        appArray = [[NSArray alloc] initWithArray:[appDict allValues]];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [appArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary* appDict = [appArray objectAtIndex:row];
    NSString *description = [NSString stringWithFormat:@""];
    switch ([tableColumn.identifier intValue]) {
        case 0:
            description = [appDict objectForKey:@"CFBundleDisplayName"];
            break;
        case 1:
            description = [appDict objectForKey:@"CFBundleShortVersionString"];
            break;
        case 2:
            description = [appDict objectForKey:@"CFBundleIdentifier"];
            break;
        default:
            break;
    }
    
    return description;
}

-(void)showSelf{
    [[NSApplication sharedApplication] runModalForWindow:self.window];
}

-(void)windowWillClose:(NSNotification *)notification{
    [[NSApplication sharedApplication] stopModal];
}



@end
