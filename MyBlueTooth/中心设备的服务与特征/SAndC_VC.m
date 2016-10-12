//
//  SAndC_VC.m
//  MyBlueTooth
//
//  Created by 郑冰津 on 16/4/29.
//  Copyright © 2016年 JiangMen. All rights reserved.
//

#import "SAndC_VC.h"
#import "Header.h"

@interface SAndC_VC ()<UITableViewDataSource,UITableViewDelegate>{
    __weak NSArray <CBService *> *pServicesArray;
//    __weak NSMutableArray <CBCharacteristic *> *pChArray;
    
    UITableView *tableViewSC;
}

@end

@implementation SAndC_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"服务与特征";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchSC)];
    UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64) style:UITableViewStyleGrouped];
    tableView.delegate=self;
    tableView.dataSource=self;
    [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];
    [self.view addSubview:tableView];
    tableViewSC =tableView;
}
#pragma mark -------------------------UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return pServicesArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return pServicesArray[section].characteristics.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView=[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    headerView.textLabel.text=[NSString stringWithFormat:@"服务特征:%@",pServicesArray[section].UUID];
    headerView.textLabel.textColor = [UIColor purpleColor];
    return headerView;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell=@"IDCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:IDCell];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDCell];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines=0;
    }
   CBCharacteristic *characteristics= pServicesArray[indexPath.section].characteristics[indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@",characteristics.UUID];
    if (indexPath.section==1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"外设电量:%@",[[NSString alloc]initWithData:characteristics.value encoding:NSUTF16StringEncoding]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CBCharacteristic *characteristics= pServicesArray[indexPath.section].characteristics[indexPath.row];
//    char strcommand1[2]={'A','T'};
//    strcommand1[0] =0X0D;
//    strcommand1[1] =0X0A;
//    NSData *cmdData1 = [NSData dataWithBytes:strcommand1 length:2];

    char strcommand[10]={'A','T','1','2','3','4','5','6','7','8'};
    NSData *cmdData = [NSData dataWithBytes:strcommand length:10];
    [[CentralModel sharedCentralModel] writePeripheralData:cmdData forCharacteristic:characteristics back:^(BOOL succeed) {
        if (succeed) {
            NSLog(@"发送成功");
        }
    }];

}

#pragma mark -----------------搜索服务与特征
-(void)searchSC{
    __weak typeof(tableViewSC)aTable = tableViewSC;
    [[CentralModel sharedCentralModel] discoverServicesAndCharacteristicsBack:^(NSArray<CBService *> *services) {
        pServicesArray =services;
        [aTable reloadData];
    } receive:^(BOOL isSubscribe, NSData *data, CBCharacteristic *characteristic) {
        if (isSubscribe) {
            NSLog(@"%@  %@",characteristic.UUID,data);
            [aTable reloadData];
        }
    }];
}

@end
