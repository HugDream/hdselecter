//
//  HDSelecterModel.h
//  hdselecter
//
//  Created by ybz on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HDSelecterItemModel : NSObject

@property(nonatomic,strong)NSString* title;
@property(nonatomic,assign,readonly)NSInteger index;
@property(nonatomic,strong,readonly)UIView* view;

-(instancetype)initWithTitle:(NSString*)title;
-(instancetype)initWithTitle:(NSString*)title customView:(UIView*)view;


@end

@interface HDSelecterModel : NSObject

@property(nonatomic,strong)NSArray<HDSelecterItemModel*>* items;

@end
