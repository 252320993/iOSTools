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
    NSString *_filePath;
}

@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *crashTime;
@property (copy, nonatomic) NSString *filePath;

-(instancetype)initWithStrInfo:(NSString *)fileInfo;

@end
