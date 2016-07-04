//
//  ycwAppDelegate.mm
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#import "ycwAppDelegate.h"
#import "deviceinfo.h"
#import "AppWindowCtrl.h"
#import "CrashreportWinCtrl.h"
#import "CrashFileInfo.h"

@implementation ycwAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    if (deviceDeleget_==NULL)
        deviceDeleget_= new MyDeviceDeleget(self);
    startListenDevice(deviceDeleget_);
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}


-(void)deviceConnected:(mg_ios::IOSDevice*)device
{
    
    bool bAttachRet = device->attach();
    if (!bAttachRet)
    {
        return;
    }
    
    [self showiOSDeviceInfo:device];
    
    currentDevice = device;
    
    
}

-(void)deviceDisConnected:(mg_ios::IOSDevice*)device
{
    [_lblDeviceName setStringValue:@""];
    [_lbliOSVersion setStringValue:@""];
    [_lblDeviceUDID setStringValue:@""];
    currentDevice = nil;
}


-(void)showiOSDeviceInfo:(mg_ios::IOSDevice*)device{
    BasicDeviceInfo info = device->basicDeviceInfo();
    [_lblDeviceName setStringValue:[NSString stringWithUTF8String:info.DeviceName.c_str()]];
    [_lbliOSVersion setStringValue:[NSString stringWithUTF8String:info.ProductVersion.c_str()]];
    [_lblDeviceUDID setStringValue:[NSString stringWithUTF8String:info.UniqueDeviceID.c_str()]];
    _Uiid = [_lblDeviceUDID stringValue];
    NSLog(@"\n%@\n",[NSString stringWithUTF8String:info.UniqueDeviceID.c_str()]);
}

#pragma mark - 按钮事件
- (IBAction)clickListApps:(id)sender {
    CFDictionaryRef dictRef = currentDevice->getAppLists();
    NSDictionary *dict = (NSDictionary *)dictRef;
    
    AppWindowCtrl *appwin = [[AppWindowCtrl alloc]initWithDict:dict];
    [appwin showSelf];
    [appwin release],appwin = nil;
}

- (IBAction)clickInstallApp:(id)sender {
    NSString *strPath = [_lblAppPath stringValue];
    CFStringRef pathRef = (__bridge CFStringRef)strPath;
    bool result = currentDevice->installApp(pathRef);
}

- (IBAction)clickCrashReport:(id)sender {
    
    CrashreportWinCtrl *crashReportWin = [[CrashreportWinCtrl alloc] init];
    [crashReportWin setDelegate:self];
    delete fileManager_;fileManager_=NULL;
    [self openCrashReportCopyService:currentDevice];
    NSMutableArray *crashFileArray = [NSMutableArray array];
    [self readCrashReportFileListFromPath:@"/" toArray:crashFileArray];
    [crashReportWin setCrashFileArray:crashFileArray];
    [crashReportWin showWindow:crashReportWin.window];

}

- (IBAction)clickBackup:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //调用备份进程
        NSString *savePath = [NSString stringWithFormat:@"%@%@",localBakcupPath,@"Backup/"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:savePath]) {
            [fm createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSArray  *argumArray = [NSArray arrayWithObjects: @"-b", @"--target", _Uiid, @"-q",savePath, nil];
        int retCode = [self execBackup:argumArray];
        if (retCode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"Success!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Backup Success, path is %@",savePath];
                [alert runModal];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"Failed!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Backup Failed!!!"];
                [alert runModal];
            });
        }
    });
}

- (IBAction)clickCopyFile:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *strPhotoLibraryPath = [NSString stringWithFormat:@"%@%@",localBakcupPath,@"PhotoLibrary/"];
        if ([fm fileExistsAtPath:strPhotoLibraryPath]) {
            [fm removeItemAtPath:strPhotoLibraryPath error:nil];
        }
        NSString *localPhotoDataPath = [NSString stringWithFormat:@"%@%@",localBakcupPath,@"PhotoLibrary/PhotoData/"];
        [fm createDirectoryAtPath:localPhotoDataPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *photoDataPath = @"/PhotoData/";
        delete fileManager_;fileManager_=NULL;
        [self openAFCService:currentDevice];
        if (fileManager_ && (fileManager_->isServiceOk()))
        {
            [self getDirFromDevice:localPhotoDataPath srcPath:photoDataPath];
        }
        
        NSString *localPhotoPath = [NSString stringWithFormat:@"%@%@",localBakcupPath,@"PhotoLibrary/Photos/"];
        [fm createDirectoryAtPath:localPhotoPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *photoPath = @"/Photos/";
        delete fileManager_;fileManager_=NULL;
        [self openAFCService:currentDevice];
        BOOL retcode = NO;
        if (fileManager_ && (fileManager_->isServiceOk()))
        {
            retcode = [self getDirFromDevice:localPhotoPath srcPath:photoPath];
        }
        else{
            retcode = NO;
        }
        
        if (retcode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"Success" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Copy PhotoLibrary Success, path is %@",strPhotoLibraryPath];
                [alert runModal];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"Failed!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Copy Failed!!!"];
                [alert runModal];
            });
        }
    });
}

- (IBAction)clickClearFile:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL ret = NO;
        if ([fm fileExistsAtPath:localBakcupPath]) {
            NSError *error = nil;
            ret = [fm removeItemAtPath:localBakcupPath error:&error];
            
            if (ret) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Success!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Delete Success!!!"];
                    [alert runModal];
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Failed!!!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",error.description];
                    [alert runModal];
                });
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"Alert!!!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"File No Exits"];
                [alert runModal];
            });
        }
    });
}

#pragma mark - 备份

- (NSString*)getAppPath
{
    //从系统目录中找
    NSString* strapp = nil;
    NSString* tStrHelpAppPath = @"/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/AppleMobileDeviceHelper.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:tStrHelpAppPath]) {
        strapp = [NSString stringWithFormat:@"%@/Contents/Resources/AppleMobileBackup",tStrHelpAppPath];
    }else {
        NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
        strapp = [NSString stringWithFormat:@"%@/AppleMobileBackup",resourcePath];
    }
    return strapp;
}

- (int)execBackup:(NSArray *)argumArray
{
    NSLog(@"exec Backup task");
    
    int retCode = BU_Successful;
    
    backupTask_ = [[[NSTask alloc] init] autorelease];
    [backupTask_ setLaunchPath:[self getAppPath]];
    [backupTask_ setArguments:argumArray];
    
    NSPipe  *b_pipe = [[NSPipe alloc] init];
    [backupTask_ setStandardError:b_pipe];
    
    [backupTask_ launch];
    
    [backupTask_ waitUntilExit];
    
    taskState = [backupTask_ terminationStatus];
    if(taskState == 0)
    {
        NSLog(@"Task succeeded.");
        retCode = BU_Successful;
    }
    else
    {
        NSLog(@"[BackupDeviceBll] : threadExeBody Task backup failed.");
        NSLog(@"Backup Argum:%@,%@",_Uiid,[argumArray lastObject]);
        retCode = BU_UnknownError;
        
        NSFileHandle *readHander = [b_pipe fileHandleForReading];
        NSData  *readData =[readHander readDataToEndOfFile];
        NSString *errorcodeString = [[[NSMutableString alloc] initWithData:readData encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"%@", errorcodeString);
        
        
        //restore错误码
        int restoreIndex = [errorcodeString rangeOfString:@"Restore error:"].location;
        if (restoreIndex != NSNotFound)  //restore
        {
            NSString *errorMsg = @"Restore error:";
            int errorCodeIndex = restoreIndex + [errorMsg length];
            errorcodeString = [errorcodeString substringFromIndex:errorCodeIndex];
            errorcodeString = [errorcodeString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            errorcodeString = [errorcodeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (nil!=errorcodeString)
            {
                if ([errorcodeString isEqualToString:@"-37"] == YES)
                {
                    NSLog(@"need to find my iphone  \n");
                    retCode = BU_NEEDCLOSEFINDMYIPHONE;
                }
                else if ([errorcodeString isEqualToString:@"-36"] == YES)
                {
                    NSLog(@"Insufficient space\n");
                    retCode = BU_InsufficientSpace;
                }
                else if ([errorcodeString isEqualToString:@"-2"] == YES)
                {
                    NSLog(@"BU_ConnectFailed %s\n", [errorcodeString UTF8String]);
                    retCode = BU_ConnectFailed;
                }
                else if ([errorcodeString isEqualToString:@"-10"] == YES)
                {
                    NSLog(@"BU_DeviceLost   ======    %s\n", [errorcodeString UTF8String]);
                    retCode = BU_DeviceLost;
                }
                else if ([errorcodeString isEqualToString:@"-35"] == YES) {
                    NSLog(@"BU_Devicelock   ======    %s\n", [errorcodeString UTF8String]);
                    retCode = BU_PassWord;
                }
                else
                {
                    NSLog(@"%@",errorcodeString);
                }
            }
        }
        else
        {
            int bindex = [errorcodeString rangeOfString:@"Backup error:"].location;
            
            if([errorcodeString rangeOfString:@"SocketStreamHandlerConnect: Can't connect to host:"].location != NSNotFound)
            {
                retCode = BU_PassWord;
            }
            
            //取错误码
            else if (bindex != NSNotFound)
            {
                NSString *errorMsg = @"Backup error:";
                int errorCodeIndex = bindex + [errorMsg length];
                errorcodeString = [errorcodeString substringFromIndex:errorCodeIndex];
                errorcodeString = [errorcodeString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                errorcodeString = [errorcodeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (nil!=errorcodeString  )
                {
                    if ([errorcodeString isEqualToString:@"-36"] == YES)
                    {
                        NSLog(@"Insufficient space\n");
                        retCode = BU_InsufficientSpace;
                    }
                    else if ([errorcodeString isEqualToString:@"-2"] == YES)
                    {
                        NSLog(@"BU_ConnectFailed %s\n", [errorcodeString UTF8String]);
                        retCode = BU_ConnectFailed;
                    }
                    else if ([errorcodeString isEqualToString:@"-10"] == YES)
                    {
                        NSLog(@"BU_DeviceLost   ======    %s\n", [errorcodeString UTF8String]);
                        retCode = BU_DeviceLost;
                    }
                    else if ([errorcodeString isEqualToString:@"-35"] == YES) {
                        NSLog(@"BU_Devicelock   ======    %s\n", [errorcodeString UTF8String]);
                        retCode = BU_PassWord;
                    }
                    else {
                        NSLog(@"%@",errorcodeString);
                    }
                }
            }
            else if([errorcodeString rangeOfString:@"from lockdown"].location != NSNotFound)
            {
                NSLog(@"BU_Devicelock   ======    %s\n", [errorcodeString UTF8String]);
                retCode = BU_PassWord;
            }else if([errorcodeString rangeOfString:@"ERROR: Password change"].location != NSNotFound)
            {
                NSLog(@"BU_ITunesSetPassWord   ======    %s\n", [errorcodeString UTF8String]);
                retCode = BU_ITunesSetPassword;
            }
            else
            {
                NSLog(@"%@",errorcodeString);
            }
        }
    }
    
    [b_pipe release];
    backupTask_ = nil;
    return retCode;
}

#pragma mark - 拷贝文件到PC

- (void)openAFCService:(mg_ios::IOSDevice*)device
{
    if (device == NULL) {
        return ;
    }
    
    if (device->deviceConnect()) {
        if (device->startSession()) {
            
            //创建文件对象
            fileSerice_ = new mg_ios::DeviceService(device);
            fileManager_ = new mg_ios::FileManager(fileSerice_ ,NO);
            
            device->stopSession();
        }
        device->disDeviceConnect();
    }
}

- (BOOL)getFileFromDevice:(NSString*)localPath  path:(NSString *)strDevicePath
{
    
    NSString* dstPath = localPath;
    NSString* srcPath = strDevicePath;
    
    if(0 == fileManager_->readFile([dstPath UTF8String],[srcPath UTF8String]))
    {
        NSLog(@"copy success!");
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)getDirFromDevice:(NSString*)dstPath srcPath:(NSString*)strDevicePath
{
    BOOL retcode = YES;
    vector<string>fileLists = fileManager_->readDir([strDevicePath UTF8String]);
    for (int i = 0; i < fileLists.size(); i++){
        NSMutableString *destFile = [NSMutableString stringWithString:dstPath];
        NSMutableString *srcFile = [NSMutableString stringWithString:strDevicePath];
        [destFile appendString:[NSString stringWithUTF8String:fileLists[i].c_str()]];
        [srcFile appendString:[NSString stringWithUTF8String:fileLists[i].c_str()]];
        CFDictionaryRef dictRef = fileManager_->fileInfo([srcFile UTF8String]);
        NSDictionary *dict = (NSDictionary *)dictRef;
        if ([[dict objectForKey:@"st_ifmt"] isEqualToString:@"S_IFDIR"]) {
            [destFile appendString:@"/"];
            [srcFile appendString:@"/"];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:destFile]) {
                [fm createDirectoryAtPath:destFile withIntermediateDirectories:YES attributes:nil error:nil];
            }
            [self getDirFromDevice:destFile srcPath:srcFile];
        }
        else{
            retcode &= [self getFileFromDevice:destFile path:srcFile];
        }
    }
    return retcode;
}

#pragma mark - com.apple.crashreportcopymobile服务

- (void)openCrashReportCopyService:(mg_ios::IOSDevice*)device
{
    if (device == NULL) {
        return ;
    }
    
    if (device->deviceConnect()) {
        if (device->startSession()) {
            
            //创建文件对象
            fileSerice_ = new mg_ios::DeviceService(device);
            fileManager_ = new mg_ios::FileManager(fileSerice_ ,YES);
            
            device->stopSession();
        }
        device->disDeviceConnect();
    }
}

-(BOOL)copyCrashReportToDesFolder:(NSString*)destFolder{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *strCrashReportPath = [NSString stringWithFormat:@"%@%@",localBakcupPath,@"CrashReport/"];
        if ([fm fileExistsAtPath:strCrashReportPath]) {
            [fm removeItemAtPath:strCrashReportPath error:nil];
        }
        [fm createDirectoryAtPath:strCrashReportPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *reportPath = @"/";
        delete fileManager_;fileManager_=NULL;
        [self openCrashReportCopyService:currentDevice];
        BOOL retcode = NO;
        if (fileManager_ && (fileManager_->isServiceOk()))
        {
            retcode = [self getDirFromDevice:strCrashReportPath srcPath:reportPath];
        }
        else{
            retcode = NO;
        }
    
    return retcode;
}

-(BOOL)readCrashReportFileListFromPath:(NSString *)strFolderPath toArray:(NSMutableArray *)crashFileArray{
    
    if (fileManager_ && (fileManager_->isServiceOk()))
    {
        vector<string>fileLists = fileManager_->readDir([strFolderPath UTF8String]);
        for (int i = 0; i < fileLists.size(); i++){
            NSMutableString *srcFile = [NSMutableString stringWithString:strFolderPath];
            [srcFile appendString:[NSString stringWithUTF8String:fileLists[i].c_str()]];
            CFDictionaryRef dictRef = fileManager_->fileInfo([srcFile UTF8String]);
            NSDictionary *dict = (NSDictionary *)dictRef;
            if ([[dict objectForKey:@"st_ifmt"] isEqualToString:@"S_IFDIR"]) {
                [srcFile appendString:@"/"];
                [self readCrashReportFileListFromPath:srcFile toArray:crashFileArray];
            }
            else{
                CrashFileInfo *fileinfo = [[CrashFileInfo alloc] initWithStrInfo:[NSString stringWithUTF8String:fileLists[i].c_str()]];
                fileinfo.filePath = srcFile;
                [crashFileArray addObject:fileinfo];
                [fileinfo release],fileinfo = nil;
            }
        }
    }
    return YES;
}


#pragma mark - CrashreportWinCtrl delegate

-(void)copyAllCrashreportFile{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       bool ret = [self copyCrashReportToDesFolder:nil];
        if (ret) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"success" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"copy success!"];
                [alert runModal];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"failed!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Copy failed!"];
                [alert runModal];
            });
        }
    });
    
}

-(NSString *)readCrashReportfileContentFromPath:(NSString *)strPath{
    NSString *strContent = @"";
    if (fileManager_ && (fileManager_->isServiceOk())) {
        string fileContent;
        fileManager_->readFileToString([strPath UTF8String], fileContent);
        strContent = [NSString stringWithUTF8String:fileContent.c_str()];
    }
    return strContent;
}

@end
