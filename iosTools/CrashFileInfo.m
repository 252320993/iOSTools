//
//  crashFileInfo.m
//  iosTools
//
//  Created by meitu on 16/7/1.
//  Copyright © 2016年 ycw. All rights reserved.
//

#import "CrashFileInfo.h"

@implementation CrashFileInfo
@synthesize crashTime = _crashTime;
@synthesize fileName = _fileName;
@synthesize filePath = _filePath;

-(instancetype)initWithStrInfo:(NSString *)fileInfo{
    self = [super init];
    self.fileName = fileInfo;
    return self;
}

@end
