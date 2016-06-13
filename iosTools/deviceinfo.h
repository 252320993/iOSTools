//
//  deviceinfo.h
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#ifndef DeviceConnect_deviceinfo_h
#define DeviceConnect_deviceinfo_h
#include <string>
namespace mg_ios {

class IOSDevice;
struct BasicDeviceInfo
{
    BasicDeviceInfo();
    ~BasicDeviceInfo();
    
	std::string ActivationState;
	std::string BuildVersion;                      
    std::string DeviceColor;
    std::string DeviceClass;
    std::string DeviceName;
    std::string FirmwareVersion;
    std::string HardwareModel;  //
	std::string IntegratedCircuitCardIdentity;         // ICCID
    std::string InternationalMobileEquipmentIdentity;  // IMEI
    std::string InternationalMobileSubscriberIdentity; // IMSI
    std::string ModelNumber;    //
    std::string PhoneNumber;
    std::string ProductType;    // 
    std::string ProductVersion; // OSVersion
    std::string RegionInfo;     // Product Region
    std::string SerialNumber;   
    std::string UniqueDeviceID;
    int PasswordProtected; // password. 1 = has, 0 = no, -1 = not get
    int is800001a;          // AMDevicePair 1= failed; 0 = ok;
    int isJailBreak;        //0 jailbreak; 1=unjailbreak;
    
    std::string PurchaseDate;   // 
    std::string CovEndDate;     // Coverage end date
    std::string ActiveDate;     // LAST_UNBRICK_DT

    std::string ModelProduct;   // iPhone 3GS, iPhone 4...
    
    int64_t TotalSystemAvailable;
    int64_t TotalSystemCapacity;
    int64_t TotalDataAvailable;
    int64_t TotalDataCapacity;
    int64_t     AppSize;
    int64_t     AudioSize;
    int64_t     VedioSize;
    int64_t     PhotoSize;
    
    bool isServerReady()
    {
        return (_done != 0);
    }    
protected:
    friend class IOSDevice;
    bool attach(IOSDevice* device_);
    bool attachDeviceInfo(IOSDevice* device_);
    std::string findModelProduct(std::string productType_);
    static void* GetDeviceInfoFromServer(void* arg);
    void GetDeviceSize(IOSDevice* device_);
    
    int _IsServerOk;
    int _done;
    pthread_t server_thread;
    std::string _serialPath;
};

}
#endif

