//
//  HDSelecterTabView.h
//  hdselecter
//
//  Created by meng on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HDSelecterTabView;

@protocol HDSelecterTabViewDelegate <NSObject>
@optional
-(void)HDSelecterTabView:(HDSelecterTabView*)tabView didSelectAtIndex:(NSInteger)index;
-(void)HDSelecterTabView:(HDSelecterTabView*)tabView didCreateTitleLabel:(UILabel*)label;
@end

@interface HDSelecterTabView : UIView

@property(nonatomic,strong)UIColor *tintColor;
@property(nonatomic,strong)NSArray<NSString*>* titles;
@property(nonatomic,weak)id<HDSelecterTabViewDelegate> delegate;
@property(nonatomic,assign)NSInteger currentIndex;

-(void)setCurrentIndex:(NSInteger)currentIndex animation:(BOOL)animation;
-(void)reloadData;

@end
