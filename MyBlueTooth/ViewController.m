//
//  ViewController.m
//  MyBlueTooth
//
//  Created by 郑冰津 on 16/4/29.
//  Copyright © 2016年 JiangMen. All rights reserved.
//

#import "ViewController.h"
#import "CenterBLE_VC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"蓝牙";
    self.automaticallyAdjustsScrollViewInsets = NO;
    for (NSInteger i =0; i<2; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 200 + 60*i, 200, 40)];
        [button setTitle:@[@"中心设备",@"外设"][i] forState:UIControlStateNormal];
        button.backgroundColor=[UIColor orangeColor];
        [button addTarget:self action:@selector(aaaaaa:) forControlEvents:UIControlEventTouchUpInside];
        button.tag  = 123+i;
        [self.view addSubview:button];
    }
}

-(void)aaaaaa:(UIButton *)button{
    switch (button.tag) {
        case 123:
        {
            [self.navigationController pushViewController:[CenterBLE_VC new] animated:YES];
        }
            break;
        case 124:
        {
            [self.navigationController pushViewController:[CenterBLE_VC new] animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
