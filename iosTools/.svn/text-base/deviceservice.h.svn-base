//### WS@M Project:Dr.Fone for iOS (Mac)  ###
//
//  deviceservice.h
//  mobilego
//
//  Created by fengxing on 10/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

