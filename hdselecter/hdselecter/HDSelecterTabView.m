//
//  HDSelecterTabView.m
//  hdselecter
//
//  Created by meng on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import "HDSelecterTabView.h"

@interface HDSelecterTabView(){
    NSMutableArray<UILabel*>* _reusLabels;
}

@property(nonatomic,strong)UIView* bottomView;
@end

@implementation HDSelecterTabView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _reusLabels = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor redColor];
    }
    return self;
}

-(void)setTitles:(NSArray<NSString *> *)titles{
    _titles = titles;
    [self reloadData];
}

-(void)reloadData{
    [self cacheLabels];
    [_reusLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat xPoint = 0;
    for (NSInteger i = 0; i < self.titles.count; i++) {
        UILabel *label = [self createTitleLabel];
        if ([self.delegate respondsToSelector:@selector(HDSelecterTabView:didCreateTitleLabel:)]) {
            [self.delegate HDSelecterTabView:self didCreateTitleLabel:label];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTitle:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = true;
        label.tag = 10086+i;
        label.font = [UIFont systemFontOfSize:12];
        label.text = self.titles[i];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        CGFloat width = label.attributedText.size.width + 32;
        label.frame = CGRectMake(xPoint, 0, width, CGRectGetHeight(self.frame));
        xPoint+=width;
    }
    if (self.currentIndex >= self.titles.count) {
        self.currentIndex = self.titles.count - 1;
    }else if (self.titles.count <= 0) {
        self.currentIndex = -1;
    }else{
        //更新一下bottomView
        self.currentIndex = self.currentIndex;
    }
    [self clearCaches];
}
-(void)setCurrentIndex:(NSInteger)currentIndex{
    [self setCurrentIndex:currentIndex animation:false];
}
-(void)setCurrentIndex:(NSInteger)currentIndex animation:(BOOL)animation{
    _currentIndex = currentIndex;
    if (currentIndex == -1) {
        self.bottomView.hidden = true;
        return;
    }
    self.bottomView.hidden = false;
    UILabel *label = (UILabel*)[self viewWithTag:10086 + currentIndex];
    CGRect bottomViewFrame = self.bottomView.frame;
    bottomViewFrame.origin.x = label ? CGRectGetMinX(label.frame) : 0;
    bottomViewFrame.origin.y = label ? CGRectGetHeight(label.frame)-CGRectGetHeight(bottomViewFrame) : 0;
    bottomViewFrame.size.width = label ? CGRectGetWidth(label.frame) : 0;
    
    if(animation){
        [UIView animateWithDuration:.5f animations:^{
            self.bottomView.frame = bottomViewFrame;
        }];
    }else{
        self.bottomView.frame = bottomViewFrame;
    }
}
-(UIView*)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.frame = CGRectMake(0, 0, 0, 1);
        [self addSubview:_bottomView];
    }
    _bottomView.backgroundColor = self.tintColor;
    return _bottomView;
}

-(void)clickTitle:(UITapGestureRecognizer*)tap{
    NSInteger index = tap.view.tag - 10086;
    [self setCurrentIndex:index animation:true];
    if ([self.delegate respondsToSelector:@selector(HDSelecterTabView:didSelectAtIndex:)]) {
        [self.delegate HDSelecterTabView:self didSelectAtIndex:index];
    }
}

-(UILabel*)createTitleLabel{
    UILabel *label = nil;
    if (_reusLabels.count) {
        label = _reusLabels.firstObject;
        for (id obj in label.gestureRecognizers) {
            [label removeGestureRecognizer:obj];
        }
        [_reusLabels removeObject:label];
    }else{
        label = [[UILabel alloc]init];
    }
    return label;
}
-(void)cacheLabels{
    for (UIView *subView in self.subviews) {
        if([subView isKindOfClass:[UILabel class]] && subView.tag >= 10086)
            [_reusLabels addObject:(UILabel*)subView];
    }
    
}
-(void)clearCaches{
    [_reusLabels removeAllObjects];
}

@end
