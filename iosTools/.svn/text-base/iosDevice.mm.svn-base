//
//  iosDevice.cpp
//  iosTools
//
//  Created by YangCW on 16-6-2.
//  Copyright (c) 2016年 ycw. All rights reserved.
//

#include "iosDevice.h"
#include <list>
using namespace mg_ios;
using namespace std;

class DeviceDelegate* g_delegate = 0;
bool g_subscribed = false;
//vector <SPDevice> g_deviceVec;
list <SPDevice> g_deviceList;
pthread_mutex_t mutex;

IOSDevice::IOSDevice(struct am_device* device_)
{
    _device = device_;
    _isSession = false;
    _isConnected = false;
    AMDeviceRetain(_device);
    pthread_mutex_init(&mutex,NULL);
}

IOSDevice::~IOSDevice()
{
    if (_isSession)     stopSession();
    if (_isConnected)   disDeviceConnect();
	if (_device)        { AMDeviceRelease(_device); _device = NULL;}
    
    pthread_mutex_destroy(&mutex);
}

bool IOSDevice::attach()
{
    printf("[iosDevice] begin attach device \n");
    startPair();
        _deviceInfo.attach(this);
        
        //判断是否越狱
        struct afc_connection *tServer = nil;
        CFStringRef name = CFStringCreateWithCString(NULL, "com.apple.afc2", kCFStringEncodingASCII);
        mach_error_t ret = AMDeviceSecureStartService(_device, name, NULL, &tServer);
        CFRelease(name);
        if (ret)
        {
            printf("* AMDeviceStartService %s failed (%d)\n", "com.apple.afc2", ret);
            _deviceInfo.isJailBreak = 1;
        }
        else{
            _deviceInfo.isJailBreak = 0;
        }
        tServer = nil;
        
        stopSession();
        disDeviceConnect();
        
    
    AMDeviceRelease(_device);
    
    printf("[iosDevice] end attach device \n");
    return true;
}

void IOSDevice::detach()
{
    stopSession();
    disDeviceConnect();
}

bool IOSDevice::startSession()
{
    if (!_device || !_isConnected) return false;
    if (_isSession) 			   return true;
    
    mach_error_t ret = 0;
    if ((ret = AMDeviceStartSession(_device))) {
        printf("*** AMDeviceStartSession failed (%d)\n", ret);
    } else {
        _isSession = true;
        printf("AMDeviceStartSession %p\n", _device);
        return true;
    }
    return false;
}


bool IOSDevice::stopSession()
{
    //pthread_mutex_lock(&mutex);
    if (!_device)    return true;
    if (!_isSession) return true;
    
    mach_error_t ret = 0;
    if ((ret = AMDeviceStopSession(_device))) {
        printf("*** AMDeviceStopSession failed (%d)\n", ret);
    } else {
        _isSession = false;
        printf("AMDeviceStopSession %p\n", _device);
        //pthread_mutex_unlock(&mutex);
        return true;
    }
    
    //pthread_mutex_unlock(&mutex);
    return false;
}

CFStringRef IOSDevice::deviceValueForKey(CFStringRef key_, CFStringRef domain_)
{
	if (!_device) return 0;
    
    CFStringRef result = AMDeviceCopyValue(_device, domain_, key_);
    
	return result;
}

bool IOSDevice::deviceConnect()
{
    if (!_device)     return false;
    if (_isConnected) return true;
    
    mach_error_t ret = 0;
    if ((ret = AMDeviceConnect(_device))) {
        printf("[iosDevice] deviceConnect AMDeviceConnect failed (%d)\n", ret);
    } else {
        _isConnected = true;
        printf("[iosDevice] deviceConnect Success AMDeviceConnect %p\n", _device);
        return true;
    }
    return false;
}


bool IOSDevice::disDeviceConnect()
{
    if (!_device)      return true;
    if (!_isConnected) return true;
    
    //pthread_mutex_lock(&mutex);
    mach_error_t ret = 0;
    if ((ret = AMDeviceDisconnect(_device)))
    {
        printf("AMDeviceDisconnect failed (%d)\n", ret);
    }
    else
    {
        _isConnected = false;
        printf("AMDeviceDisconnect %p\n", _device);
        //pthread_mutex_unlock(&mutex);
        return true;
    }
    
    //pthread_mutex_unlock(&mutex);
    return false;
}




void iphone_notify_callback(struct am_device_notification_callback_info *info, void* cookie)
{
    DeviceDelegate* delegate = (DeviceDelegate*)cookie;
    if (!delegate)
	{
		printf("* no delegate callback\n");
		return;
	}
    
    switch (info->msg) {
        case ADNCI_MSG_CONNECTED:{
            printf("deviceID: %d\nproductID:%d\n",info->dev->device_id,info->dev->product_id);
            printf("[iosdevice] begin iphone_notify_callback ADNCI_MSG_CONNECTED\n");
            SPDevice phone(new IOSDevice(info->dev));
            g_deviceList.push_back(phone);
            delegate->deviceConnected(phone.get());
            printf("[iosdevice] end iphone_notify_callback ADNCI_MSG_CONNECTED\n");
            break;
        }
        case ADNCI_MSG_DISCONNECTED:{
            printf("设备拔出\n");
            for (list<SPDevice>::iterator it = g_deviceList.begin(); it != g_deviceList.end(); it++)
            {
                if ((*it)->amdevice() == info->dev)
                {
                    printf("[iosdevice] begin iphone_notify_callback ADNCI_MSG_DISCONNECTED \n");
                    delegate->deviceDisconnected(it->get());
                    
                    (*it)->detach();
                    //g_deviceList.erase(it);//导致程序连接过程断开设备程序Crash的原因,连接还没完成又把对象清楚了，处理方法为设备拔掉，保存列表不清除，不影响程序功能。
                    
                    printf("[iosdevice] end iphone_notify_callback ADNCI_MSG_DISCONNECTED \n");
                    break;
                }
            }
            break;
        }
    }
}

void iphone_recovery_connect_callback(struct am_recovery_device *)
{
    if (g_delegate) g_delegate->recoveryConnected(0);
}

void iphone_recovery_disconnect_callback(struct am_recovery_device *)
{
    if (g_delegate) g_delegate->recoveryDisconnected(NULL);
}

void iphone_dfu_connect_callback(struct am_recovery_device *)
{
    if (g_delegate) g_delegate->dfuConnected(NULL);
}

void iphone_dfu_disconnect_callback(struct am_recovery_device *)
{
    if (g_delegate) g_delegate->dfuDisconnected(NULL);
}


CFDictionaryRef IOSDevice::getAppLists()
{
        startPair();
        CFDictionaryRef apps;
        AMDeviceLookupApplications(_device, 0, &apps);
        NSDictionary *appDict = CFBridgingRelease(apps);
        NSLog(@"%@",appDict);

        stopSession();
        disDeviceConnect();
    CFDictionaryRef dictRef = (CFDictionaryRef)appDict;
        
    return dictRef;
}


void IOSDevice::startPair(){
    if (!_device)     return;
    int connectTimes =0;
    AMDeviceRetain(_device);
    
    while (!deviceConnect() && connectTimes < 3) {
        usleep(300);
        connectTimes++;
        printf("[iosDevice] attach deviceConnet failed connectTimes=%d \n",connectTimes);
    }
    
    disDeviceConnect();
    
	int iRet = 0;
    connectTimes =0;
    while (!deviceConnect() && connectTimes < 3)
    {
        usleep(300);
        connectTimes++;
        printf("[iosDevice] attach deviceConnet failed connectTimes=%d \n",connectTimes);
    }
    
    iRet = AMDeviceIsPaired(_device);
    if (iRet != 1) {
        printf("[iosDevice] attach AMDeviceIsPaired is failed\n");
    }
    
    iRet = AMDeviceValidatePairing(_device);
    if (iRet != 0)
    {
        iRet = AMDevicePair(_device);
        if (iRet != 0) {
            if (iRet == 0xe800001a) {
                //需要信任
                printf("[iosDevice] attach AMDevicePair failed for device is not trust\n");
                _deviceInfo.is800001a = 1;
                // _deviceInfo.attachDeviceInfo(this);
            }
            //break;
            printf("[iosDevice] attach AMDevicePair failed for unknown error \n");
        }
    }
    
    connectTimes =0;
    while (!startSession() && connectTimes < 3) {
        usleep(300);;
        connectTimes++;
        
        disDeviceConnect();
        deviceConnect();
        AMDeviceIsPaired(_device);
        AMDeviceValidatePairing(_device);
        printf("[iosDevice] attach startSession failed connectTimes=%d \n",connectTimes);
    }
   

}

int startListenDevice(mg_ios::DeviceDelegate* delegate_){
    static am_device_notification *notif = 0;
    int ret = 0;
    ret = AMDeviceNotificationSubscribe(iphone_notify_callback, 0, 1, (void *)delegate_,&notif);
    return ret;
}

