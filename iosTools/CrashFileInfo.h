//
//  crashFileInfo.h
//  iosTools
//
//  Created by meitu on 16/7/1.
//  Copyright © 2016年 ycw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashFileInfo : NSObject{
    NSString *_fileName;
    NSString *_crashTime;
    NSString *_deviceFilePath;
    NSString *_localFilePath;
}

@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *crashTime;
@property (copy, nonatomic) NSString *deviceFilePath;
@property (copy, nonatomic) NSString *localFilePath;

-(instancetype)initWithStrInfo:(NSString *)fileInfo;

@end
