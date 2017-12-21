//
//  ViewController.m
//  hdselecter
//
//  Created by meng on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import "ViewController.h"
#import "HDSelecterView.h"

#import "HDSelecterViewController.h"

@interface ViewController () <CAAnimationDelegate>
@property(nonatomic,strong)NSString *defualtProvince;
@property(nonatomic,strong)NSString *defualtCity;
@property(nonatomic,strong)NSString *defualtDistricts;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [testButton setTitle:@"Test" forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(clickTest:) forControlEvents:UIControlEventTouchUpInside];
    testButton.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:testButton];
}


-(void)clickTest:(id)sender{
    HDSelecterViewController *vc = [[HDSelecterViewController alloc]initWithDefualtProvince:self.defualtProvince city:self.defualtCity districts:self.defualtDistricts];
    vc.title = @"请选择地址";
    __weak typeof(self) weakSelf = self;
    [vc setCompleteSelectBlock:^(NSString *province, NSString *city, NSString *districts) {
        weakSelf.defualtProvince = province;
        weakSelf.defualtCity = city;
        weakSelf.defualtDistricts = districts;
        NSLog(@"%@,%@,%@",province,city,districts);
        [weakSelf dismissViewControllerAnimated:true completion:nil];
    }];
    [self presentViewController:vc animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
