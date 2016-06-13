//### WS@M Project:Dr.Fone for iOS (Mac)  ###
//
//  deviceinfo.cpp
//  mobilego
//
//  Created by fengxing on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include "deviceinfo.h"
#include "iosdevice.h"
#include "MobileDevice.h"

using namespace mg_ios;

BasicDeviceInfo::BasicDeviceInfo()
{
    server_thread = 0;
    _done = 0;
    _IsServerOk = 0;
    
    TotalSystemAvailable = 0;
    TotalSystemCapacity = 0;
    TotalDataAvailable = 0;
    TotalDataCapacity = 0;
    AppSize = 0;
    AudioSize = 0;
    VedioSize = 0;
    PhotoSize = 0;
    is800001a = 0;
}

BasicDeviceInfo::~BasicDeviceInfo()
{
//    if (server_thread) 
//    {
//        pthread_join(server_thread, NULL);
//    }
}

bool BasicDeviceInfo::attachDeviceInfo(IOSDevice *device_)
{
    printf("[deviceinfo] being attachDeviceInfo \n");
    
    bool ret = false;
    do
    {
        BREAK_CHECK(device_ && device_->amdevice(), true)
        CFStringRef value = nil;
        char buf[1024] = {0};
        int getTimes = 0;
#define QUICK_ADD_PROPERTY(key) \
getTimes = 0; \
do { \
value = nil; \
value = AMDeviceCopyValue(device_->amdevice(), NULL, CFSTR(#key)); \
if (value) {\
    if (CFStringGetCString(value, buf, sizeof(buf), kCFStringEncodingUTF8)) {\
        key = buf;\
    }\
    CFRelease(value);\
    break; \
}\
usleep(100);;\
getTimes ++ ;\
}while(getTimes < 2);
        
    QUICK_ADD_PROPERTY(ActivationState);                      
    QUICK_ADD_PROPERTY(BuildVersion);                      
    QUICK_ADD_PROPERTY(DeviceColor);
    QUICK_ADD_PROPERTY(DeviceClass);
    QUICK_ADD_PROPERTY(DeviceName);
    QUICK_ADD_PROPERTY(FirmwareVersion);
    QUICK_ADD_PROPERTY(HardwareModel);
    QUICK_ADD_PROPERTY(IntegratedCircuitCardIdentity);         // ICCID
    QUICK_ADD_PROPERTY(InternationalMobileEquipmentIdentity);  // IMEI
    QUICK_ADD_PROPERTY(InternationalMobileSubscriberIdentity); // IMSI
    QUICK_ADD_PROPERTY(ModelNumber);
    QUICK_ADD_PROPERTY(PhoneNumber);
    QUICK_ADD_PROPERTY(ProductType);
    QUICK_ADD_PROPERTY(ProductVersion);                         // OSVersion
    QUICK_ADD_PROPERTY(RegionInfo);
    QUICK_ADD_PROPERTY(SerialNumber);   
        //QUICK_ADD_PROPERTY(UniqueDeviceID);
    
        // get UUID : QUICK_ADD_PROPERTY(UniqueDeviceID)某些情况无法获取到uuid，要用特定接口进行获取
    CFStringRef uuid = AMDeviceCopyDeviceIdentifier(device_->amdevice());
    if (uuid && CFStringGetCString(uuid, buf, sizeof(buf), kCFStringEncodingUTF8)) 
        {
            UniqueDeviceID = buf;
        }
    if (uuid != NULL)
        {
            CFRelease(uuid);
        }


        
//        ModelProduct = findModelProduct(ProductType);
//        printf("[%s: %s]\n", "ModelProduct", ModelProduct.c_str());
        
        CFBooleanRef boolValue = nil;
        boolValue = (CFBooleanRef)AMDeviceCopyValue(device_->amdevice(), NULL, CFSTR("PasswordProtected"));
        if (boolValue)
        {
            if (CFBooleanGetValue(boolValue))
                PasswordProtected = 1;
            else 
                PasswordProtected = 0;
            CFRelease(boolValue);
        }
        else {
            PasswordProtected = -1;
        }
        
        ret = true;
    } while (0);
    
     printf("[deviceinfo] end attachDeviceInfo \n");   
    return ret;
}


bool BasicDeviceInfo::attach(IOSDevice* device_)
{
    int ret = attachDeviceInfo(device_);
    return ret;
}


string BasicDeviceInfo::findModelProduct(string productType_)
{
    static const char* product[] = {
        "iPhone1,1", "iPhone 1G",
        "iPhone1,2", "iPhone 3G",
        "iPhone2,1", "iPhone 3GS",
        "iPhone3,1", "iPhone 4",
        "iPhone3,2", "iPhone 4 Verizon",
        "iPhone3,3", "iPhone 4 CDMA",
        "iPhone4,1", "iPhone 4s",
        "iPhone5,1", "iPhone 5",
        "iPhone5,2", "iPhone 5",
        "iPhone5,3", "iPhone 5c (GSM)",
        "iPhone5,4", "iPhone 5c",
        "iPhone6,1", "iPhone 5s (GSM)",
        "iPhone6,2", "iPhone 5s",
        "iphone7,2", "iPhone 6",
        "iphone7,1", "iPhone 6 plus",
        "iphone8,1", "iPhone 6s",
        "iphone8,2", "iPhone 6s plus",
        "iphone8,4", "iPhone SE",
        "iPod1,1", "iPod Touch 1G",
        "iPod2,1", "iPod Touch 2G",
        "iPod3,1", "iPod Touch 3G",
        "iPod4,1", "iPod Touch 4G",
        "iPod5,1", "iPod Touch 5G",
        "iPad1,1", "iPad",
        "iPad2,1", "iPad 2 (WiFi)",
        "iPad2,2", "iPad 2 (GSM)",
        "iPad2,3", "iPad 2 (CDMA)",
        "iPad2,5", "iPad mini (WiFi)",
        "iPad2,6", "iPad mini (GSM)",
        "iPad2,7", "iPad mini",
        "iPad3,1", "iPad 3 (WiFi)",
        "iPad3,2", "iPad 3 (CDMA)",
        "iPad3,3", "iPad 3",
        "iPad3,4", "iPad 4 (WiFi)",
        "iPad3,5", "iPad 4 (GSM)",
        "iPad3,6", "iPad 4",
    };
    
    
	for (int i = 0; i*2 < (sizeof(product)/sizeof(product[0])); i++)
	{
		if (strcmp(product[i*2], productType_.c_str()) == 0)
			return product[i*2+1];
	}
	return "Unknown";

}


