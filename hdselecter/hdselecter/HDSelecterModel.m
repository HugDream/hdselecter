//
//  HDSelecterModel.m
//  hdselecter
//
//  Created by ybz on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import "HDSelecterModel.h"

@interface HDSelecterItemModel()
@property(nonatomic,strong,readwrite)UIView *view;
@property(nonatomic,assign,readwrite)NSInteger index;
@end

@implementation HDSelecterItemModel
-(instancetype)initWithTitle:(NSString *)title{
    if (self = [super init]) {
        self.title = title;
        UILabel *label = [[UILabel alloc]init];
        label.text = title;
        self.view = label;
    }
    return self;
}
-(instancetype)initWithTitle:(NSString *)title customView:(UIView *)view{
    if (self = [super init]) {
        self.title = title;
        self.view = view;
    }
    return self;
}
@end

@implementation HDSelecterModel


@end
