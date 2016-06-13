//
//  deviceservice.cpp
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//


#include <iostream>
#include "deviceservice.h"
#include "MobileDevice.h"

#define RETURN_CHECK1(L, R, R1) if((R) != (L)) return (R1);

using namespace mg_ios;
using namespace std;

DeviceService::DeviceService(IOSDevice* dev_)
{
    _device = dev_;
    _service = _openCon = 0;
}

DeviceService::~DeviceService()
{
    Destroy();
}

void DeviceService::Destroy()
{
    if (_openCon)
    {
        AFCConnectionClose(_openCon);
    }
    _openCon = NULL;
}

int DeviceService::StartService(std::string service)
{
    RETURN_CHECK1(_device->deviceConnect(), true, 1)
    //RETURN_CHECK1(_device->stopSession(), true, 1)
    CFStringRef name = CFStringCreateWithCString(NULL, service.c_str(), kCFStringEncodingASCII);
	//mach_error_t ret = AMDeviceStartService(_device->amdevice(), name, &_service, NULL);
    mach_error_t ret = AMDeviceSecureStartService(_device->amdevice(), name, NULL, &_service);
    CFRelease(name);
    if (ret) 
    {
        printf("* AMDeviceStartService %s failed (%d)\n", service.c_str(), ret);
        return -1;
    }
    printf("AMDeviceStartService %s\n", service.c_str());
    _socket = AMDServiceConnectionGetSocket(_service);
    return 0;
}


long DeviceService::StartServiceForLockScreen(std::string service)
{
    RETURN_CHECK1(_device->deviceConnect(), true, 1)
    CFStringRef name = CFStringCreateWithCString(NULL, service.c_str(), kCFStringEncodingASCII);
    long ret = AMDeviceSecureStartService(_device->amdevice(), name, NULL, &_service);
    CFRelease(name);
    if (ret)
    {
        printf("* AMDeviceStartService %s failed (%ld)\n", service.c_str(), ret);
    }
    
    printf("AMDeviceStartService %s\n", service.c_str());
    _socket = AMDServiceConnectionGetSocket(_service);
    return ret;
}


struct afc_connection* DeviceService::GetOpenConnecton()
{
    if (_openCon) {
        return _openCon;
    }
    
    if (AFCConnectionOpen(_socket, 0, &_openCon)) {
        return NULL;
    }
    return _openCon;
}

