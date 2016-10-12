//
//  CenterBLE_VC.m
//  MyBlueTooth
//
//  Created by 郑冰津 on 16/4/29.
//  Copyright © 2016年 JiangMen. All rights reserved.
//

#import "CenterBLE_VC.h"
#import "Header.h"
#import "SAndC_VC.h"

@interface CenterBLE_VC ()<UITableViewDataSource,UITableViewDelegate>{
    __weak NSMutableArray <CBPeripheral *> *peripheralArray;
    UITableView *tableViewPeripheral;
}

@end

@implementation CenterBLE_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"中心设备";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64) style:UITableViewStyleGrouped];
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    tableViewPeripheral =tableView;
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchPerioheral)];
}
#pragma mark -------------------------UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripheralArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell=@"IDCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:IDCell];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDCell];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    CBPeripheral *aPeripheral = peripheralArray[indexPath.row];
    cell.textLabel.text=aPeripheral.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral *aPeripheral = peripheralArray[indexPath.row];
    [[CentralModel sharedCentralModel] connectAPeripheral:aPeripheral back:^(BOOL isConnectSuccess) {
        if (isConnectSuccess) {
            [self.navigationController pushViewController:[SAndC_VC new] animated:YES];
        }else{
//            [[CentralModel sharedCentralModel] scanPeripherals];
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"和外设连接断开" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            [self.navigationController popToViewController:self animated:YES];
        }
    }];
}

#pragma mark --------------搜索外设
-(void)searchPerioheral{
    __weak typeof(tableViewPeripheral)aTable = tableViewPeripheral;
    [[CentralModel sharedCentralModel] getAllPeripheralBack:^(NSMutableArray<CBPeripheral *> *array) {
        peripheralArray=array;
        [aTable reloadData];
    }];
}

@end
