//
//  HDSelecterView.h
//  hdselecter
//
//  Created meng ybz on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSelecterModel.h"

FOUNDATION_EXPORT const int HDSelecterViewNotHasNextNumber;

@class HDSelecterView;

@protocol HDSelecterViewDataSource <NSObject>

@optional

-(NSInteger)numberOfItems:(HDSelecterView*)selecterView lastSelected:(NSArray<HDSelecterItemModel*>*)lastSelecter;

/**
 返回下一个列表的titles

 @param selecterView selecterView
 @param lastSelecter 当前已经选择的title集合，以选择顺序排列
 @return 下一个选择项的标题集合，如果返回nil则表示没有下一个选择项了，此时会触发选择结束
 */
-(NSString*)HDSelecterView:(HDSelecterView*)selecterView titlesWithLastSelected:(NSArray<HDSelecterItemModel*>*)lastSelecter atIndex:(NSInteger)index;

/**
 返回下一个列表的items，与返回列表titles方法类似，此方法具有更多的自定义性。此方法优先于title

 @param selecterView selecterView
 @param lastItem 当前已经选择的item集合，以选择顺序排列
 @return 下一个选择项的item集合，如果返回nil则表示没有下一个选择项了，此时会触发选择结束
 */
-(HDSelecterItemModel*)HDSelecterView:(HDSelecterView*)selecterView itemWithLastSelected:(NSArray<HDSelecterItemModel*>*)lastItem atIndex:(NSInteger)index;
@end

@protocol HDSelecterViewDelegate <NSObject>
@optional
/**
 当选择某一个item触发，与选择title类似

 @param selecterView selecterView
 @param selectItems 当前已经选择的item集合
 */
-(void)HDSelecterView:(HDSelecterView*)selecterView didSelectItem:(NSArray<HDSelecterItemModel*>*)selectItems;

/**
 选择完成时调用

 @param selecterView selecterView
 @param selectItems 选择的item集合
 */
-(void)HDSelecterView:(HDSelecterView*)selecterView completeSelected:(NSArray<HDSelecterItemModel*>*)selectItems;
@end

@interface HDSelecterView : UIView

@property(nonatomic,weak)id<HDSelecterViewDataSource> datasource;
@property(nonatomic,weak)id<HDSelecterViewDelegate> delegate;
@property(nonatomic,copy)NSString* defualtTitle;

-(NSArray<NSString*>*)selectedTitles;
-(NSArray<HDSelecterItemModel*>*)selectedItems;

/**使用指定的选择的index刷新*/
-(void)reoloadUseSelectedIndexs:(NSArray<NSNumber*>*)selectIndex;

@end
