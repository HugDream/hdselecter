//
//  HDSelecterViewController.h
//  hdselecter
//
//  Created by meng on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSelecterView.h"

@interface HDSelecterViewController : UIViewController

-(instancetype)initWithDefualtProvince:(NSString*)province city:(NSString*)city districts:(NSString*)districts;

@property(nonatomic,strong,readonly)HDSelecterView* selecterView;
@property(nonatomic,copy)void(^completeSelectBlock)(NSString*province,NSString*city,NSString*districts);

@end
