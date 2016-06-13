//### WS@M Project:Dr.Fone for iOS (Mac)  ###
//
//  filemanager.cpp
//  mobilego
//
//  Created by fengxing on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <fstream>
#include "filemanager.h"
#include "MobileDevice.h"
#include "deviceservice.h"

using namespace mg_ios;

#define BREAK_CHECK(L, R)       if((R) != (L)) break;
#define BREAK_CHECK_NOT(L, R)   if((R) == (L)) break;
#define FILE_CHUNKS (256*1024)

FileManager::FileManager(afc_connection* conn)
{
    if (conn) {
       _opencc = conn; 
    }else {
        _opencc = 0;
    }
}

FileManager::FileManager(DeviceService* deviceService)
{
    if (deviceService) {
        if(deviceService->StartService("com.apple.afc") == 0)
            _opencc = deviceService->GetOpenConnecton();
        else 
            _opencc = 0;
    }
    else {
        _opencc = 0;
    }
}

FileManager::~FileManager()
{
//    if (_afccon) 
//    {
//        int ret = AFCConnectionClose(_afccon);
//        if (ret) 
//            ELOG("* AFCConnectionClose failed with error %d\n", ret);
//    }
    //CODE_TRACE
}

afc_file_ref FileManager::openFile(string filePath, int mode)
{
    if (!_opencc) return 0;
    afc_file_ref rAFC = 0;
	
	int ret = AFCFileRefOpen(_opencc, (char*)filePath.c_str(), (unsigned long long int)mode, &rAFC);
	if (ret != 0) {
		printf("* AFCFileRefOpen(%s, %d) failed with error %d", filePath.c_str(), mode, ret);
		return 0;
	}
	return rAFC;
}

bool FileManager::closeFile(afc_file_ref rafc)
{
    if (!_opencc || !rafc) return false;
    return (AFCFileRefClose(_opencc, rafc) == 0);
}

bool FileManager::isPathExist(string path)
{
    size_t pos = 0;
    pos = path.find_last_of("/");
    if (pos == string::npos)
        return false;
    
    pos++;
    string dirPath = path.substr(0,pos);
    string name = path.substr(pos,path.length());
    
    vector<string> listFiles = readDir(dirPath);
    for (int i = 0; i < listFiles.size(); i++)
    {
        string fileName = listFiles[i];
        if (fileName.compare(name) == 0) 
            return true;
    }
    return false;
}

int FileManager::readFileToBuf(string srcPath, unsigned long long ulOffset, unsigned long long ulBytesOfRead, unsigned char *sBuf, IFilePosState* stat_)
{
    struct afc_dictionary *info = NULL;
    
    if (NULL == sBuf || 0 == ulBytesOfRead) 
    {
        printf("FileManager::readFileToBuf() error, invalid param\n");
        return -1;
    }
	if (AFCFileInfoOpen(_opencc, (char*)srcPath.c_str(), &info) != 0) {
		return EDEV_FILE_EXIST;
	}
    AFCKeyValueClose(info);
    afc_file_ref srcRef = openFile(srcPath, MODE_READ);
    if (srcRef == 0) 
        return EDEV_FILE_EXIST;
    
    unsigned long long ulFileSize = 0;
    afc_error_t err;
        //int iRet = 0;
    unsigned char *pBuf = sBuf;
    off_t offset = ulOffset;
    size_t size = 0;
    size_t bytesOfReaded = 0;
    
    if(0 != (err = AFCFileRefSeek(_opencc, srcRef, 0, 2, 0)))
    {
        printf("FileManager::readFileToBuf() error, fail to AFCFileRefSeek %d\n", err);
        // iRet = err;
        goto END_READFILETOBUF;
    }
    AFCFileRefTell(_opencc, srcRef, &ulFileSize);
    
    if (ulOffset > ulFileSize) 
    {
        printf("FileManager::readFileToBuf() error, offset %llu over filesize %llu\n", ulOffset, ulFileSize);
        // iRet = -2;
        goto END_READFILETOBUF;
    }   
    ulBytesOfRead = (ulOffset + ulBytesOfRead <= ulFileSize) ? ulBytesOfRead : (ulFileSize - ulOffset);    
    
    do 
    {   
        size = FILE_CHUNKS;
        if (ulBytesOfRead == bytesOfReaded) 
        {
            size = 0;
            break;
        }
        else if (ulBytesOfRead < bytesOfReaded + size) 
        {
            size = ulBytesOfRead - bytesOfReaded;
        }
        BREAK_CHECK(AFCFileRefSeek(_opencc, srcRef, offset, 0, 0), 0)
        BREAK_CHECK(AFCFileRefRead(_opencc, srcRef, pBuf, &size), 0)
        
        offset += size;
        pBuf += size;
        bytesOfReaded += size;
        if (stat_) 
        {
            if (stat_->setFilePos(offset) != 0)
            {
                closeFile(srcRef);
                return ETSK_USER_CANCEL;
            }
        } 
    } while (size);
    
END_READFILETOBUF:
    closeFile(srcRef);
    
    return (size == 0) ? 0 : -1;
}

int FileManager::readFile(string dstPath, string srcPath, IFilePosState* stat_)
{
    struct afc_dictionary *info = NULL;
	if (AFCFileInfoOpen(_opencc, (char*)srcPath.c_str(), &info) != 0) {
		return EDEV_FILE_EXIST;
	}
    AFCKeyValueClose(info);
    afc_file_ref srcRef = openFile(srcPath, MODE_READ);
    if (srcRef == 0) 
        return EDEV_FILE_EXIST;
    
    char chunkData[FILE_CHUNKS];
    FILE* dstFd = fopen(dstPath.c_str(), "wb+");
    if (!dstFd) 
    {
        printf("* fopen %s failed: %s", dstPath.c_str(), strerror(errno));
        closeFile(srcRef);
        return ELOC_FILE_EXIST;
    }
    
    off_t offset = 0;
    size_t size = 0;
    do 
    {   
        size = FILE_CHUNKS;
        BREAK_CHECK(AFCFileRefSeek(_opencc, srcRef, offset, 0, 0), 0)
        BREAK_CHECK(AFCFileRefRead(_opencc, srcRef, chunkData, &size), 0)
        BREAK_CHECK(fwrite(chunkData, 1, size, dstFd), size)
        offset += size;
        if (stat_) 
        {
            if (stat_->setFilePos(offset) != 0)
            {
                fclose(dstFd);
                closeFile(srcRef);
                return ETSK_USER_CANCEL;
            }
        } 
    } while (size);
    
    fclose(dstFd);
    closeFile(srcRef);

    return (size == 0)?0:-1;
}

int FileManager::writeFile(string dstPath, string srcPath, IFilePosState* stat_)
{
    afc_file_ref dstRef = openFile(dstPath, MODE_WRITE);
    if (dstRef == 0) 
    {
        string ddir(dstPath.begin(), dstPath.begin()+dstPath.find_last_of("/"));
        if(createDir(ddir) == 0)
            dstRef = openFile(dstPath, MODE_WRITE);
        if (dstRef == 0)
            return EDEV_FILE_CREATE;
    }

    char chunkData[FILE_CHUNKS];
    FILE* srcFd = fopen(srcPath.c_str(), "rb");
    if (!srcFd) 
    {
        printf("* fopen %s failed: %s\n", srcPath.c_str(), strerror(errno));
        closeFile(dstRef);
        return ELOC_FILE_EXIST;
    }
    
    off_t offset = 0; 
    size_t size = 0;
    do 
    {   
        size = FILE_CHUNKS;
        BREAK_CHECK_NOT(size = fread(chunkData, 1, size, srcFd), 0)
        BREAK_CHECK(AFCFileRefSeek(_opencc, dstRef, offset, 0, 0), 0)
        BREAK_CHECK(AFCFileRefWrite(_opencc, dstRef, chunkData, size), 0)
        offset += size;
        if (stat_) 
        {
            if (stat_->setFilePos(offset) != 0)
            {
                fclose(srcFd);
                closeFile(dstRef);
                return ETSK_USER_CANCEL;
            }
        }
    } while (size);
    fclose(srcFd);
    closeFile(dstRef);
    
    return (size == 0)?0:-1;
}


int FileManager::copyFile(string dstPath, string srcPath, IFilePosState* stat_)
{
    struct afc_dictionary *info = NULL;
	if (AFCFileInfoOpen(_opencc, (char*)srcPath.c_str(), &info) != 0)
		return EDEV_FILE_EXIST;
    AFCKeyValueClose(info);

    afc_file_ref srcRef = openFile(srcPath, MODE_READ);
    if (srcRef == 0) 
        return EDEV_FILE_OPEN;

    afc_file_ref dstRef = openFile(dstPath, MODE_WRITE);
    if (dstRef == 0) 
    {
        closeFile(srcRef);
        return EDEV_FILE_OPEN;
    }
    char chunkData[FILE_CHUNKS];

    off_t offset = 0; 
    size_t size = 0;
    do 
    {   
        size = FILE_CHUNKS;
        BREAK_CHECK(AFCFileRefSeek(_opencc, srcRef, offset, 0, 0), 0)
        BREAK_CHECK(AFCFileRefRead(_opencc, srcRef, chunkData, &size), 0)
        BREAK_CHECK(AFCFileRefSeek(_opencc, dstRef, offset, 0, 0), 0)
        BREAK_CHECK(AFCFileRefWrite(_opencc, dstRef, chunkData, size), 0)
        offset += size;
        if (stat_) 
        {
            if (stat_->setFilePos(offset) != 0)
            {
                closeFile(dstRef);
                closeFile(srcRef);
                return ETSK_USER_CANCEL;
            }
        }
    } while (size);
    closeFile(dstRef);
    closeFile(srcRef);
    
    return (size == 0)?0:-1;
}

int FileManager::writeFileEx(string dstPath, string srcPath, IFilePosState* stat_)
{
    string dstPathTmp = dstPath + ".tmp";
    string dstPathBak = dstPath + ".bak";
    int ret = 0;
    if ((ret = writeFile(dstPathTmp, srcPath, stat_)))
    {
        printf("writeFileEx failed with %d\n", ret);
        removePath(dstPathTmp);
        return writeFile(dstPath, srcPath);
    }

    renamePath(dstPath, dstPathBak);
    return renamePath(dstPathTmp, dstPath);
}

//只传最后一级路径
int FileManager::removePath(string fileName_)
{
    if (!_opencc) return -1;
    printf("Remove %s\n", fileName_.c_str());
    
    int ret = AFCRemovePath(_opencc, (char*)fileName_.c_str());
    if (ret == 0 || ret == AFC_NOT_EXIST)
        return 0;
    
    vector<string> files = readDir(fileName_);
    for (auto it = files.begin(); it != files.end(); it++) 
    {
        string fileName = fileName_ + "/" + *it;
        int ret = AFCRemovePath(_opencc, (char*)fileName.c_str());
        printf("%d", ret);
    }
    
    return AFCRemovePath(_opencc, (char*)fileName_.c_str());
}

int FileManager::renamePath(string existName, string newName)
{
    if (!_opencc) return -1;
    printf("Rename %s to %s\n", existName.c_str(), newName.c_str());
    removePath(newName);
    return AFCRenamePath(_opencc, (char*)existName.c_str(), (char*)newName.c_str());
}

//恢复文件,删掉现有文件，并将fileName.bak文件重命名为fileName文件
int FileManager::RestoreFile(string fileName)
{    
    string strBakFile = fileName + ".bak";

    //判断设备上的bak文件是否存在
    if(!isPathExist(strBakFile))
    {
        printf("FileManager::RestoreFile:%s is not exist.\n", strBakFile.c_str());
        return EDEV_FILE_RESTORE_FAILED;
    }
    if (renamePath(strBakFile, fileName) != 0)
        return EDEV_FILE_RESTORE_FAILED;
    else
        return 0;
}

CFDictionaryRef FileManager::deviceInfo()
{
    if (!_opencc) return nil;
    struct afc_dictionary *info = NULL;
	if (AFCDeviceInfoOpen(_opencc, &info) != 0) {
		return nil;
	} 
	
	CFMutableDictionaryRef deviceProperties = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    char *key, *val;
	
	while ((AFCKeyValueRead(info, &key, &val) == 0) && key && val)
    {
        //CFStringRef keyRef = CFStringCreateWithCString(NULL, key, kCFStringEncodingASCII); 
        CFStringRef valRef = CFStringCreateWithCString(NULL, val, kCFStringEncodingASCII); 
        if (strcmp(key, "FSFreeBytes") == 0) 
        {
            CFDictionaryAddValue(deviceProperties, kDeviceInfoFreeBytes, valRef);
            CFRelease(valRef);
            continue;
        }
        if (strcmp(key, "FSBlockSize") == 0) 
        {
            CFDictionaryAddValue(deviceProperties, kDeviceInfoBlockSize, valRef);
            CFRelease(valRef);
            continue;
        }
        if (strcmp(key, "FSTotalBytes") == 0) 
        {
            CFDictionaryAddValue(deviceProperties, kDeviceInfoTotalBytes, valRef);
            CFRelease(valRef);
            continue;
        }
        CFRelease(valRef);
    }

	AFCKeyValueClose(info);
	
	return deviceProperties;
}

int FileManager::linkPath(string dstPath, string srcPath)
{
    //if (!_opencc) return -1;
    //return AFCLinkPath(_opencc, 1, dstPath.c_str(), srcPath.c_str());
    return -1;
}

CFDictionaryRef FileManager::fileInfo(string filePath)
{
    if (!_opencc) return nil;
    struct afc_dictionary *info = NULL;
	if (AFCFileInfoOpen(_opencc, (char*)filePath.c_str(), &info) != 0) {
		return nil;
	} 
	
	CFMutableDictionaryRef fileProperties = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    char *key, *val;
	
	while ((AFCKeyValueRead(info, &key, &val) == 0) && key && val)
    {
        //CFStringRef keyRef = CFStringCreateWithCString(NULL, key, kCFStringEncodingASCII); 
        CFStringRef valRef = CFStringCreateWithCString(NULL, val, kCFStringEncodingASCII); 
        if (valRef == 0)
            break;

        if (strcmp(key, "st_size") == 0) 
        {
            CFDictionaryAddValue(fileProperties, kFileInfoSize, valRef);
            continue;
        }
        if (strcmp(key, "st_blocks") == 0) 
        {
            CFDictionaryAddValue(fileProperties, kFileInfoBlocks, valRef);
            continue;
        }
        if (strcmp(key, "st_nlink") == 0) 
        {
            CFDictionaryAddValue(fileProperties, kFileInfoNlinks, valRef);
            continue;
        }
        if (strcmp(key, "st_ifmt") == 0) 
        {
            CFDictionaryAddValue(fileProperties, kFileInfoIfmt, valRef);
            continue;
        }
        if (strcmp(key, "S_IFLNK") == 0) 
        {
            CFDictionaryAddValue(fileProperties, kFileInfoIflnk, valRef);
            continue;
        }
        if (strcmp(key, "LinkTarget") == 0) 
        {
            CFDictionaryAddValue(fileProperties, kFileInfoLinkTarget, valRef);
            continue;
        }
 		//CFDictionaryAddValue(fileProperties, keyRef, valRef);
        CFRelease(valRef);
    }
	AFCKeyValueClose(info);
	
	return fileProperties;
}

long long FileManager::getFileSize(string filePath_)
{
    CFDictionaryRef info = fileInfo(filePath_);
    long long size = 0;
    if (info) 
    {
        CFStringRef sizeRef = (CFStringRef)CFDictionaryGetValue(info, kFileInfoSize);
        if (sizeRef) 
        {
            char bytes[30];
            if (CFStringGetCString(sizeRef, bytes, sizeof(bytes), kCFStringEncodingASCII))
            {
                size = atoll(bytes);
            }
        }
        CFRelease(info);
    }
    else {
        printf("* getFileSize: %s not exist", filePath_.c_str());
    }
    return size;
}

int FileManager::createDir(string dirPath)
{
    if (!_opencc) return -1;
    int pos = 0;
    
    if (*dirPath.begin() == '/') 
        pos++;
    if (*(dirPath.end()-1) == '/')
        dirPath.erase(dirPath.end()-1);
    
    do {
        pos = dirPath.find("/", pos+1);
        if (pos == string::npos) {
            break;
        }
        string subdir = dirPath.substr(0, pos);
        AFCDirectoryCreate(_opencc, (char*)subdir.c_str());
    } while (1);
    return AFCDirectoryCreate(_opencc, (char*)dirPath.c_str());
}

vector<string> FileManager::readDir(string dirPath)
{
    struct afc_directory *hAFCDir = 0;
    vector<string> listFiles;
    if (!_opencc) return listFiles;
    
	int ret = AFCDirectoryOpen(_opencc, (char*)dirPath.c_str(), &hAFCDir);
	if (ret) 
    {
		printf("AFCDirectoryOpen %s failed with %d\n", dirPath.c_str(), ret);
	}
    else 
    {
        char *buffer = NULL;      
        while ((AFCDirectoryRead(_opencc, hAFCDir, &buffer) == 0) && buffer)
        {
            if (strcmp(".", buffer) == 0 || strcmp("..", buffer) == 0)
                continue;
    
            listFiles.push_back(buffer);
        }
		AFCDirectoryClose(_opencc, hAFCDir);
	}
    return listFiles;
}

int FileManager::lockFile(afc_file_ref rafc_)
{
    if (!_opencc && !rafc_) return -1;
    return AFCFileRefLock(_opencc, rafc_);
}

int FileManager::unlockFile(afc_file_ref rafc_)
{
    if (!_opencc && !rafc_) return -1;
    return AFCFileRefUnlock(_opencc, rafc_);
}

int FileManager::readFileToString(string srcPath, string &outString_)
{
    outString_.clear();
    string dstPath = tmpnam(NULL);
    int ret = readFile(dstPath, srcPath);
    if (ret != 0) 
        return ret;
    ifstream ifs(dstPath.c_str(), ifstream::binary);
    outString_.assign(istreambuf_iterator<char>(ifs), istreambuf_iterator<char>());
    ifs.close();
#ifdef DEBUG
    FILE* fp = fopen(dstPath.c_str(), "rb");
    fseek(fp, 0, SEEK_END);
    //ASSERT(ftell(fp) == outString_.size());
    fclose(fp);
#endif
    return ret;
}

int FileManager::writeFileFromString(string dstPath, string inString)
{
    char* srcPath = tmpnam(NULL);
    ofstream ofs(srcPath, ifstream::binary);
    ofs.write(inString.c_str(), inString.size());
    ofs.close();
#ifdef DEBUG
    FILE* fp = fopen(srcPath, "rb");
    fseek(fp, 0, SEEK_END);
    //ASSERT(ftell(fp) == inString.size());
    fclose(fp);
#endif
    return writeFile(dstPath, srcPath);
}

int FileManager::writeFileFromBuf(string dstPath, const void* buf, size_t len)
{
    return writeFileFromString(dstPath, string((char*)buf, len));
}

int FileManager::copyFilesToDestFolder(char *pSrcFolder, char *pDesFolder)
{
    int ret = -1;
    
    if (!_opencc) return ret;
    
    struct afc_directory *hAFCDir = 0;
	ret = AFCDirectoryOpen(_opencc, pSrcFolder, &hAFCDir);
	
    if (ret) 
    {
		printf("AFCDirectoryOpen %s failed with %d\n", pSrcFolder, ret);
	}
    else 
    {
        char *buffer = NULL;      
        while ((AFCDirectoryRead(_opencc, hAFCDir, &buffer) == 0) && buffer)
        {
            if (strcmp(".", buffer) == 0 || strcmp("..", buffer) == 0)
            {
                continue;
            }
            
            std::string strCurFile = std::string(pSrcFolder) +std::string("/") + std::string(buffer);
            CFDictionaryRef info = fileInfo(strCurFile);
            bool bFolder = true;
            if (info) {
                CFStringRef typeRef = (CFStringRef)CFDictionaryGetValue(info, kFileInfoIfmt);
                if (typeRef) 
                {
                    char bytes[30] = {0};
                    if (CFStringGetCString(typeRef, bytes, sizeof(bytes), kCFStringEncodingASCII))
                    {
                        if (strcmp(bytes, "S_IFDIR")) {
                            bFolder = false;
                        };
                    }
                }
                CFRelease(info);
            }
            
            if (bFolder) {                //文件夹
                copyFilesToDestFolder((char*)strCurFile.c_str(), pDesFolder);
            }
            else {                  //文件
                readFile( std::string(pDesFolder) + std::string("/") + std::string(buffer), strCurFile);
            }
        }
        
		AFCDirectoryClose(_opencc, hAFCDir);
	}
    
    return ret;
}
