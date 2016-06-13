//
//  iosDevice.h
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#ifndef __iosTools__iosDevice__
#define __iosTools__iosDevice__
#include <string>
#include <map>
#include "deviceinfo.h"
#include <tr1/memory>
#include "MobileDevice.h"
#include <iostream>
#define RETURN_CHECK(L,R) if((R) != (L)) return;
#define BREAK_CHECK(L,R) if((R) != (L)) break;

namespace mg_ios {
    using namespace std;
    typedef std::tr1::shared_ptr<IOSDevice> SPDevice; // share pointer device type
    class DeviceService;
    class IOSDevice
    {
    public:
        /**
         * :param device_: device param get from notifcation
         * IOSDevice will retain device
         */
        explicit IOSDevice(struct am_device* device_);
        ~IOSDevice();
        
        enum CacheDir { ROOT=0, PHOTO=1, MEDIA=2 };
    public:
        BasicDeviceInfo& basicDeviceInfo() { return _deviceInfo; }
        const char*     UDID() { return _deviceInfo.UniqueDeviceID.c_str(); }
        
        bool attach();
        void detach();
        
        bool deviceIsConnected() { return _isConnected; }
        bool deviceIsPaired();
        bool deviceIsSession()   { return _isSession; }
        
        bool deviceConnect();
        bool disDeviceConnect();
        
        CFDictionaryRef getAppLists();
    
        /**
         * Read device value
         * :param key_: value key_
         * :param domain:
         * :return: 0 if read failed, else CFString* with auto release
         */
        CFStringRef deviceValueForKey(CFStringRef key_, CFStringRef domain_);
        
        
        struct am_device* amdevice() { return _device; }
        /**
         * Get shared_ptr of self
         * :return: SPDevice object
         * Hopefully, every time you use this instead of raw pointer, cause of when
         * the iDevice plug-off, we want delete this, and avoid some one still use
         * it in accident
         */
        SPDevice sharedSelfPtr();
        
        
    public:
        
        /**
         * Pair device
         */
        bool devicePair();
        
        
        /**
         * Pair validate pair
         */
        bool deviceValidatePairing();
        
        /**
         * Session control
         */
        bool startSession();
        bool stopSession();
        
        void startPair();
        
        
    protected:
        BasicDeviceInfo _deviceInfo;
        struct am_device* _device;
        volatile bool _isConnected;
        bool _isSession;
        
        //FileManager* _fileManager;
        map<string, DeviceService*> _serviceConnMap;
        
        struct afc_connection _afc_notif;
        
    };
    
    struct DeviceDelegate
    {
        virtual void deviceConnected(IOSDevice* phone_) = 0;
        virtual void deviceDisconnected(IOSDevice* phone_) = 0;
        virtual void dfuConnected(IOSDevice* phone_) = 0;
        virtual void dfuDisconnected(IOSDevice* phone_) = 0;
        virtual void recoveryConnected(IOSDevice* phone_) = 0;
        virtual void recoveryDisconnected(IOSDevice* phone_) = 0;
    };
    
} // namesapce mg_ios

extern "C" int startListenDevice(mg_ios::DeviceDelegate* delegate_);


#endif /* defined(__iosTools__iosDevice__) */
