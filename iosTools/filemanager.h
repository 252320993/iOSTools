//
//  filemanager.h
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#ifndef mobilego_filemanager_h
#define mobilego_filemanager_h
#include <vector>
#include "iosdevice.h"

namespace mg_ios {
using namespace std;
/**
 * FilePosState used to get copy or write file state
 */
struct IFilePosState
{
    /**
     * File pos callback
     * :return: is success return 0, else failed
     */
    virtual int setFilePos(off_t pos) = 0;
};
#define kFileInfoSize          CFSTR("st_size")     //val - size in bytes
#define kFileInfoBlocks        CFSTR("st_blocks")   //val - size in blocks
#define kFileInfoNlinks        CFSTR("st_nlink")    //val - number of hardlinks
#define kFileInfoIfmt          CFSTR("st_ifmt")     //val - "S_IFDIR" for folders
#define kFileInfoIflnk         CFSTR("S_IFLNK")     //for symlinks
#define kFileInfoLinkTarget    CFSTR("LinkTarget")  //val - path to symlink target
#define kDeviceInfoFreeBytes   CFSTR("FSFreeBytes")
#define kDeviceInfoBlockSize   CFSTR("FSBlockSize")
#define kDeviceInfoTotalBytes  CFSTR("FSTotalBytes")
    
// File
#define ELOC_FILE_EXIST  250
#define EDEV_FILE_EXIST  251
#define EDEV_FILE_OPEN   252
#define EDEV_FILE_CREATE 253
#define EDEV_FILE_RESTORE_FAILED  254
#define ETSK_USER_CANCEL 301
    
class FileManager
{
    enum { MODE_READ=2, MODE_WRITE=3 };
    enum { AFC_NOT_EXIST = 8 };
public:
    explicit FileManager(DeviceService* deviceService);
    explicit FileManager(afc_connection* conn);
    ~FileManager();
    
    /**
     * Check whether afc protocol is connected.
     * If device connected with wifi or not connect, return false
     */
    bool isServiceOk() { return (_opencc != NULL); }
    /**
     * :return: dictonary, user need release it
     *          FSFreeBytes - free bytes on system device for afc2, user device for afc
	 *          FSBlockSize - filesystem block size
	 *          FSTotalBytes - size of device
	 *          Model - iPhone1,1 etc.     
     */
    CFDictionaryRef deviceInfo();
    /**
     * Open afc connection
     * :param afc: com.apple.afc or com.apple.afc2
     * :return: 0 if failed
     */
    //int initAFCService(string afc);
    
    /**
     * Get file refernce
     * :param filePath: the file to open
     * :param mode: MODE_READ / MODE_WRITE
     * :return: 0 if failed
     */
    afc_file_ref openFile(string filePath, int mode);
    bool closeFile(afc_file_ref rafc);
    
    int lockFile(afc_file_ref rafc_);
    int unlockFile(afc_file_ref rafc_);
    /**
     *  compare file and dir is exist
     */
    bool isPathExist(string path);
    /**
     * Sync Task
     */
    int readFile(string dstPath, string srcPath, IFilePosState* stat_ = 0);
    /**
     * If parent dir didn't exist, create
     */
    int writeFile(string dstPath, string srcPath, IFilePosState* stat_ = 0);
    int copyFile(string dstPath, string srcPath, IFilePosState* stat_=0);
    /**
     * Write file to device safe
     * :param dstPath: path on iphone
     * :param srcPath: path on imac
     * :param stat_: file pos delegate
     * :return: success return 0
     * writeFileEx will first create a temp file on device, and then
     * rename origin, rename tmp to dstPath at last.
     * If the space is limited, it create directly.
     */
    int writeFileEx(string dstPath, string srcPath, IFilePosState* stat_ = 0);
    
	int removePath(string fileName);
    /**
     * Like mv, 
     */
	int renamePath(string existName, string newName);
    
    //恢复文件,删掉现有文件，并将fileName.bak文件重命名为fileName文件
    int RestoreFile(string fileName);
    /**
     * :return: dictonary, user need release it
     *          "st_size":     val - size in bytes
     *          "st_blocks":   val - size in blocks
     *          "st_nlink":    val - number of hardlinks
     *          "st_ifmt":     val - "S_IFDIR" for folders
     *          "S_IFLNK" for symlinks
     *          "LinkTarget":  val - path to symlink target
     */
	CFDictionaryRef fileInfo(string fileName);
    long long getFileSize(string filePath_);
    
    /**
     * Create hard link, just like copy
     *
     */
    int linkPath(string dstPath, string srcPath);
    /**
     * If parent dir didn't exist, create
     */
	int createDir(string dirPath);
    vector<string> readDir(string dirPath);

	//bool isFileExist(string filePath);
    //bool isDirExist(string dirPath);
    
    int copyFilesToDestFolder(char* pSrcFolder, char* pDesFolder);
    
    /**
     * Help function, read file into a string
     */
    int readFileToBuf(string srcPath, unsigned long long ulOffset, unsigned long long ulBytesOfRead, unsigned char *sBuf, IFilePosState* stat_);
    int readFileToString(string srcPath, string& outString_);
    int writeFileFromString(string dstPath, string inString);
    int writeFileFromBuf(string dstPath, const void* buf, size_t len);
    bool touch(string dstPath) { return closeFile(openFile(dstPath, MODE_READ)); }
protected:
    //SPDevice _device;
    //DeviceService* _service;
    struct afc_connection* _opencc;
};

} // namespace mg_ios


#endif

