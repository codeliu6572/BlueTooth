//
//  CenterModel.h
//  MyBlueTooth
//
//  Created by 郑冰津 on 16/4/29.
//  Copyright © 2016年 JiangMen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

//http://www.jianshu.com/p/a5e25206df39

@interface CentralModel : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>{
    @public
    ///设置手机为中心设备
    CBCentralManager *centralManager;
    ///装载外围设备的容器
    NSMutableArray <CBPeripheral *> *peripheralArray;
}

+ (CentralModel *)sharedCentralModel;
///扫描外设
-(void)scanPeripherals;
///停止扫描外设
-(void)stopScanPeripherals;
///销毁所有,中心设备,外设容器等等
-(void)destroyAll;
///获取所有的外设设备
-(void)getAllPeripheralBack:(void(^)(NSMutableArray <CBPeripheral *>*array))block;
///连接一个外设设备
-(void)connectAPeripheral:(CBPeripheral *)aPeripheral back:(void(^)(BOOL isConnectSuccess))block;
///连接成功的外设
- (CBPeripheral *)connectSuccessPeripheral;
///发现服务与特征
-(void)discoverServicesAndCharacteristicsBack:(void(^)(NSArray<CBService *>*services))block receive:(void(^)(BOOL isSubscribe,NSData *data ,CBCharacteristic *characteristic))receiveBlock;
///向外设写入数据
-(void)writePeripheralData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic back:(void(^)(BOOL succeed))writeData;
@end




