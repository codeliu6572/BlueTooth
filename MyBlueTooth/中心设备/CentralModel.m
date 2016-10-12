//
//  CenterModel.m
//  MyBlueTooth
//
//  Created by 郑冰津 on 16/4/29.
//  Copyright © 2016年 JiangMen. All rights reserved.
//

#import "CentralModel.h"

static CentralModel *cBLE = nil;

@implementation CentralModel{
    ///所有的外设
    void(^allPeripheralBlock)(NSMutableArray *array);
    ///是否连接成功
    void(^connectBlock)(BOOL status);
    ///搜查到服务与外设之后,装载容器
    void(^SCBlock)(NSArray<CBService *>*services);
    ///向外设写入数据是否成功
    void(^writeDataBlock)(BOOL succeed);
    ///外设发过来的数据,订阅了
    void(^receiveDataBlock)(BOOL isSubscribe,NSData *data ,CBCharacteristic *characteristic);
    ///连接成功的外设,只有在成功的时候才有这个
    CBPeripheral *connectPeripheral;
}


+(CentralModel *)sharedCentralModel{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cBLE = [[CentralModel alloc]init];
    });
    return cBLE;
}


#pragma mark --------CBCentralManagerDelegate/中心设备代理-----------
///中心服务器状态更新后调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"中心设备蓝牙已经打开,开始扫描...");
        [self scanPeripherals];
    }else if (central.state == CBCentralManagerStateResetting){
        
    }
}
///当管理中心恢复时会调用如下代理：
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    NSLog(@"管理中心恢复了");
}
///发现外设设备/连接外设,advertisementData特征数据   RSSI信号质量（信号强度）
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%@ %@",peripheral.name,advertisementData);
    if (peripheral && peripheral.name && [advertisementData[@"kCBAdvDataIsConnectable"] boolValue] ) {
        if (![peripheralArray containsObject:peripheral] ) {
            [peripheralArray addObject:peripheral];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            allPeripheralBlock(peripheralArray);
        });
    }
}
///连接到外围设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self stopScanPeripherals];
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (peripheral && peripheral.name) {
            connectPeripheral = peripheral;
            connectBlock(YES);
        }else{
            connectPeripheral=nil;
            connectBlock(NO);
        }
    });
}
///连接外围设备失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self stopScanPeripherals];
    dispatch_sync(dispatch_get_main_queue(), ^{
        connectPeripheral=nil;
        connectBlock(NO);
    });
    dispatch_sync(dispatch_get_main_queue(), ^{
        [peripheralArray removeAllObjects];
        allPeripheralBlock(peripheralArray);
    });
    NSLog(@"连接外围设备失败:%@",peripheral.name);
}
///断开外设连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    [self stopScanPeripherals];
    dispatch_sync(dispatch_get_main_queue(), ^{
        connectPeripheral=nil;
        connectBlock(NO);
    });
    dispatch_sync(dispatch_get_main_queue(), ^{
        [peripheralArray removeAllObjects];
        allPeripheralBlock(peripheralArray);
    });
    NSLog(@"断开外设连接:%@",peripheral.name);
}
#pragma mark ~~~~~~~~~~~~~~~~~~CBPeripheral/外围设备代理~~~~~~~~~~~~~~~~~~
///外围设备寻找到服务后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if(error){
        NSLog(@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        NSMutableArray *uuidsArray =@[].mutableCopy;
        for (CBCharacteristic *UUIDs in service.characteristics) {
            //外围设备查找指定服务中的特征:(读,写,订阅)
            [uuidsArray addObject:UUIDs.UUID];
        }
        [peripheral discoverCharacteristics:uuidsArray forService:service];
    }
}

///外围设备寻找到特征后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    for (CBService *s in peripheral.services) {
        for (CBCharacteristic *cha in s.characteristics) {
            if (cha.isNotifying) {
                [peripheral setNotifyValue:YES forCharacteristic:cha];
            }else if ([cha.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]){
                [peripheral setNotifyValue:YES forCharacteristic:cha];
            }else if ([cha.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]){
                [connectPeripheral readValueForCharacteristic:cha];
            }
        }
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        SCBlock(peripheral.services);
    });
}
///订阅的通知
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"外设向我发送信息错误:%@",error.localizedDescription);
        receiveDataBlock(NO,nil,characteristic);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]){
            ///订阅
            NSLog(@"已订阅特征通知");
            receiveDataBlock(YES,nil,characteristic);
        }else{
            receiveDataBlock(NO,nil,characteristic);
        }
    });
}
///更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"更新特征值时发生错误%@，错误信息：%@",characteristic.UUID,error.localizedDescription);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (characteristic.value) {
            receiveDataBlock(YES,characteristic.value,characteristic);
        }
    });
}

///向外设发送data成功的方法的代理
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"给外设发送data，错误信息：%@",error.localizedDescription);
        writeDataBlock(NO);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]] ){
            ///写到外设
            writeDataBlock(YES);
        }else{
            writeDataBlock(NO);
        }
    });
}
#pragma mark >>>>>使用的工具
///扫描外设
-(void)scanPeripherals{
    [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey :@NO}];
}
///停止扫描外设
-(void)stopScanPeripherals{
    [peripheralArray removeAllObjects];
    [centralManager stopScan];
}
///初始化中心设备
-(void)stupCentralManager{
    peripheralArray = @[].mutableCopy;
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 2) options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
}
///销毁所有,中心设备,外设容器等等
-(void)destroyAll{
    peripheralArray=nil;
    centralManager=nil;
}
///连接成功的外设
- (CBPeripheral *)connectSuccessPeripheral{
    if (connectPeripheral) {
        return connectPeripheral;
    }
    return nil;
}
///向外设写入数据
-(void)writePeripheralData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic back:(void(^)(BOOL succeed))writeData{
    if (data) {
        [connectPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        writeDataBlock=writeData;
    }else{
        writeData(NO);
    }
}
#pragma mark >>>>>block回调
///获取所有的外设设备
-(void)getAllPeripheralBack:(void(^)(NSMutableArray <CBPeripheral *>*array))block{
    [self destroyAll];
    [self stupCentralManager];
    allPeripheralBlock=block;
}
///连接一个外设设备
-(void)connectAPeripheral:(CBPeripheral *)aPeripheral back:(void(^)(BOOL isConnectSuccess))block{
    for (CBPeripheral *peri in peripheralArray) {
        [centralManager cancelPeripheralConnection:peri];
    }
    [centralManager connectPeripheral:aPeripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES}];
    connectBlock=block;
}
///发现服务与特征
-(void)discoverServicesAndCharacteristicsBack:(void(^)(NSArray<CBService *>*services))block receive:(void(^)(BOOL isSubscribe,NSData *data ,CBCharacteristic *characteristic))receiveBlock{
    if (connectPeripheral) {
        connectPeripheral.delegate=self;
        [connectPeripheral discoverServices:nil];
        SCBlock=block;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [peripheralArray removeAllObjects];
            allPeripheralBlock(peripheralArray);
            connectBlock(NO);
        });
    }
    if (receiveBlock) {
        receiveDataBlock=receiveBlock;
    }
}
                                               
@end
