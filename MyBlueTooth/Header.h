
//
//  Header.h
//  MyBlueTooth
//
//  Created by 郑冰津 on 16/4/29.
//  Copyright © 2016年 JiangMen. All rights reserved.
//
#define Screen_H [UIScreen mainScreen].bounds.size.height
#define Screen_W [UIScreen mainScreen].bounds.size.width

#import <CoreBluetooth/CoreBluetooth.h>
#import "CentralModel.h"
#import "ConversionData.h"

///中心设备的唯一标示
#define kRestoreIdentifierKey [UIDevice currentDevice].name
///订阅的特征UUID
#define kCharacteristicUUID  @"6A3D4B29-123D-4F2A-12A8-D5E211411400"


///标准的service UUID
#define     BLE_UUID_ALERT_NOTIFICATION_SERVICE   0x1811
#define     BLE_UUID_BATTERY_SERVICE   0x180F
#define     BLE_UUID_BLOOD_PRESSURE_SERVICE   0x1810
#define     BLE_UUID_CURRENT_TIME_SERVICE   0x1805
#define     BLE_UUID_CYCLING_SPEED_AND_CADENCE   0x1816
#define     BLE_UUID_DEVICE_INFORMATION_SERVICE   0x180A
#define     BLE_UUID_GLUCOSE_SERVICE   0x1808
#define     BLE_UUID_HEALTH_THERMOMETER_SERVICE   0x1809
#define     BLE_UUID_HEART_RATE_SERVICE   0x180D
#define     BLE_UUID_HUMAN_INTERFACE_DEVICE_SERVICE   0x1812
#define     BLE_UUID_IMMEDIATE_ALERT_SERVICE   0x1802
#define     BLE_UUID_LINK_LOSS_SERVICE   0x1803
#define     BLE_UUID_NEXT_DST_CHANGE_SERVICE   0x1807
#define     BLE_UUID_PHONE_ALERT_STATUS_SERVICE   0x180E
#define     BLE_UUID_REFERENCE_TIME_UPDATE_SERVICE   0x1806
#define     BLE_UUID_RUNNING_SPEED_AND_CADENCE   0x1814
#define     BLE_UUID_SCAN_PARAMETERS_SERVICE   0x1813
#define     BLE_UUID_TX_POWER_SERVICE   0x1804
#define     BLE_UUID_CGM_SERVICE   0x181A
