//
//  MyDeviceDeleget.h
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#ifndef DeviceConnectDemo_MyDeviceDeleget_h
#define DeviceConnectDemo_MyDeviceDeleget_h
#include "iosdevice.h"
using namespace mg_ios;

class MyDeviceDeleget : public DeviceDelegate
{
public:
    MyDeviceDeleget(id proxy_):proxy(proxy_) {}
    MyDeviceDeleget() {}
    
    virtual void deviceConnected(IOSDevice* phone_)
    {
        [proxy deviceConnected: phone_];

    }
    virtual void deviceDisconnected(IOSDevice* phone_)
    {
        [proxy deviceDisConnected: phone_];
    }
    
    virtual void dfuConnected(IOSDevice* phone_)
    {
        printf("DFU Connected!");
    }
    virtual void dfuDisconnected(IOSDevice* phone_)
    {
        printf("DFU DisConnected!");
    }
    virtual void recoveryConnected(IOSDevice* phone_)
    {
        printf("Recovery Connected!");
    }
    virtual void recoveryDisconnected(IOSDevice* phone_)
    {
        printf("Recovery Disconnected!");
    }
    
private:
    id proxy;
};


#endif


