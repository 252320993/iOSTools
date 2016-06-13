//
//  deviceservice.h
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#ifndef mobilego_deviceservice_h
#define mobilego_deviceservice_h
#include "iosdevice.h"
namespace mg_ios
{
    class DeviceService
    {
    public:
        explicit DeviceService(IOSDevice *);
        ~DeviceService();
        
        int StartService(std::string service);
        
        long StartServiceForLockScreen(std::string service);
        void Destroy();
        struct afc_connection* GetOpenConnecton();
        SOCKET socket() { return _socket; }
        
    protected:
        IOSDevice* _device;
        struct afc_connection* _service;
        struct afc_connection* _openCon;
        SOCKET _socket;
    };
}
#endif

