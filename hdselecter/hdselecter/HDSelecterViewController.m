//
//  HDSelecterViewController.m
//  hdselecter
//
//  Created by meng on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import "HDSelecterViewController.h"

@interface HDSelecterViewController ()<UIViewControllerTransitioningDelegate,UIPopoverPresentationControllerDelegate,HDSelecterViewDataSource,HDSelecterViewDelegate>
@property(nonatomic,strong,readwrite)HDSelecterView* selecterView;
@property(nonatomic,strong)NSArray* addressDatas;
@property(nonatomic,strong)UIView* contentView;
@property(nonatomic,strong)NSString *defualtProvince;
@property(nonatomic,strong)NSString *defualtCiry;
@property(nonatomic,strong)NSString *defualtDistricts;
@end



/**
 转场动画
 */
@interface HDSelecterViewControllerAnimatedTransitioningObject : NSObject <UIViewControllerAnimatedTransitioning,CAAnimationDelegate>
@property(nonatomic,weak)HDSelecterViewController *selecterViewController;
@end

@implementation HDSelecterViewControllerAnimatedTransitioningObject

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 1;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *from_vc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to_vc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    //present
    if (to_vc == self.selecterViewController) {
        [containerView addSubview:to_vc.view];
        from_vc.view.layer.zPosition = -10000;
        
        CAKeyframeAnimation *rotation_animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.x"];
        NSNumber *value1 = [NSNumber numberWithFloat:0];
        NSNumber *value2 = [NSNumber numberWithFloat:M_PI/180*30];
        NSNumber *value3 = [NSNumber numberWithFloat:0];
        rotation_animation.values = @[value1,value2,value3];
        
        CABasicAnimation *scale_animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale_animation.toValue = [NSNumber numberWithFloat:0.9];
        
        CAAnimationGroup *animation = [[CAAnimationGroup alloc]init];
        animation.duration = [self transitionDuration:transitionContext];
        animation.delegate = self;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = false;
        animation.animations = @[rotation_animation,scale_animation];
        
        [from_vc.view.layer addAnimation:animation forKey:@"test"];
        
        to_vc.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.selecterViewController.contentView.frame.size.height, [UIScreen mainScreen].bounds.size.width, self.selecterViewController.contentView.frame.size.height);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            to_vc.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }completion:^(BOOL finished) {
            from_vc.view.layer.zPosition = 0;
            [transitionContext completeTransition:finished];
        }];
    }else{
        to_vc.view.layer.zPosition = -10000;
        
        CAKeyframeAnimation *rotation_animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.x"];
        NSNumber *value1 = [NSNumber numberWithFloat:0];
        NSNumber *value2 = [NSNumber numberWithFloat:M_PI/180*30];
        NSNumber *value3 = [NSNumber numberWithFloat:0];
        rotation_animation.values = @[value1,value2,value3];
        
        CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation1.fromValue = [NSNumber numberWithFloat:0.9];
        animation1.toValue = [NSNumber numberWithFloat:1];
        
        CAAnimationGroup *animation = [[CAAnimationGroup alloc]init];
        animation.duration = [self transitionDuration:transitionContext];
        animation.delegate = self;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = false;
        animation.animations = @[rotation_animation,animation1];
        
        [to_vc.view.layer addAnimation:animation forKey:@"test"];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            from_vc.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }completion:^(BOOL finished) {
            to_vc.view.layer.zPosition = 0;
            [transitionContext completeTransition:finished];
        }];
    }
}
@end

@implementation HDSelecterViewController
-(instancetype)init{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}
-(instancetype)initWithDefualtProvince:(NSString *)province city:(NSString *)city districts:(NSString *)districts{
    if (self = [self init]) {
        self.defualtProvince = province;
        self.defualtCiry = city;
        self.defualtDistricts = districts;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.transitioningDelegate = self;
    
    CGFloat titleHeight = 32;
    CGFloat contentHeight = 450;
    
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle]URLForResource:@"hdselecter" withExtension:@"bundle"]];
    NSArray *array = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfURL:[bundle URLForResource:@"Address" withExtension:@"plist"]] options:NSPropertyListImmutable format:NULL error:NULL];
    self.addressDatas = array;
    
    NSMutableArray<NSNumber*>* defualtSelectIndexs = [NSMutableArray array];
    if (self.defualtProvince) {
        for (NSInteger i = 0; i < self.addressDatas.count; i++) {
            if ([self.addressDatas[i][@"province"] isEqualToString:self.defualtProvince]) {
                [defualtSelectIndexs addObject:[NSNumber numberWithInteger:i]];
            }
        }
    }
    if(self.defualtProvince && self.defualtCiry && defualtSelectIndexs.count > 0){
        for (NSInteger i = 0; i < [self.addressDatas[defualtSelectIndexs[0].integerValue][@"citys"] count]; i++) {
            if ([self.addressDatas[defualtSelectIndexs[0].integerValue][@"citys"][i][@"city"] isEqualToString:self.defualtCiry]) {
                [defualtSelectIndexs addObject:[NSNumber numberWithInteger:i]];
            }
        }
    }
    if (self.defualtProvince && self.defualtCiry && self.defualtDistricts && defualtSelectIndexs.count > 1) {
        for (NSInteger i = 0; i < [self.addressDatas[defualtSelectIndexs[0].integerValue][@"citys"][defualtSelectIndexs[1].integerValue][@"districts"] count]; i++) {
            if ([self.addressDatas[defualtSelectIndexs[0].integerValue][@"citys"][defualtSelectIndexs[1].integerValue][@"districts"][i] isEqualToString:self.defualtDistricts]) {
                [defualtSelectIndexs addObject:[NSNumber numberWithInteger:i]];
            }
        }
    }
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - contentHeight, [UIScreen mainScreen].bounds.size.width, contentHeight)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    contentView.layer.shadowOffset = CGSizeMake(3, 3);
    contentView.layer.shadowOpacity = 0.5;
    [self.view addSubview:contentView];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.title;
    [contentView addSubview:titleLabel];
    titleLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, titleHeight);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(clickClose:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"hdselecter.bundle/close"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - titleHeight, 0, titleHeight, titleHeight);
    [contentView addSubview:closeButton];
    
    UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleHeight - 1, [UIScreen mainScreen].bounds.size.width, 1)];
    bottomLineView.backgroundColor = [UIColor colorWithRed:0xF3/255.0 green:0xF3/255.0 blue:0xF3/255.0 alpha:1];
    [contentView addSubview:bottomLineView];
    
    HDSelecterView *selecterView = [[HDSelecterView alloc]init];
    selecterView.datasource = self;
    selecterView.delegate = self;
    selecterView.frame = CGRectMake(0, 32, [UIScreen mainScreen].bounds.size.width, contentHeight - titleHeight);
    [contentView addSubview:selecterView];
    
    [selecterView reoloadUseSelectedIndexs:defualtSelectIndexs];
    
    self.selecterView = selecterView;
    self.contentView = contentView;
}
-(NSString*)HDSelecterView:(HDSelecterView*)selecterView titlesWithLastSelected:(NSArray<HDSelecterItemModel*>*)lastSelecter atIndex:(NSInteger)index{
    if(lastSelecter.count == 0){
        return self.addressDatas[index][@"province"];
    }else if (lastSelecter.count == 1){
        return self.addressDatas[lastSelecter[0].index][@"citys"][index][@"city"];
    }else if (lastSelecter.count == 2){
        return self.addressDatas[lastSelecter[0].index][@"citys"][lastSelecter[1].index][@"districts"][index];
    }else{
        return nil;
    }
}
-(NSInteger)numberOfItems:(HDSelecterView *)selecterView lastSelected:(NSArray<HDSelecterItemModel *> *)lastSelecter{
    if (lastSelecter.count == 0) {
        return self.addressDatas.count;
    }else if (lastSelecter.count == 1){
        return [self.addressDatas[lastSelecter[0].index][@"citys"] count];
    }else if (lastSelecter.count == 2){
        return [[self.addressDatas[lastSelecter[0].index][@"citys"] objectAtIndex:lastSelecter[1].index][@"districts"] count];
    }else{
        return HDSelecterViewNotHasNextNumber;
    }
}
-(void)HDSelecterView:(HDSelecterView *)selecterView completeSelected:(NSArray<HDSelecterItemModel *> *)selectItems{
    if (self.completeSelectBlock) {
        self.completeSelectBlock(self.addressDatas[selectItems[0].index][@"province"], self.addressDatas[selectItems[0].index][@"citys"][selectItems[1].index][@"city"], self.addressDatas[selectItems[0].index][@"citys"][selectItems[1].index][@"districts"][selectItems[2].index]);
    }
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!CGRectContainsPoint(self.contentView.frame, [[touches anyObject]locationInView:self.view])) {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}
-(void)clickClose:(id)sender{
    [self dismissViewControllerAnimated:true completion:nil];
}
/**present*/
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    HDSelecterViewControllerAnimatedTransitioningObject *obj = [[HDSelecterViewControllerAnimatedTransitioningObject alloc]init];
    obj.selecterViewController = self;
    return obj;
}
/**dismiss*/
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    HDSelecterViewControllerAnimatedTransitioningObject *obj = [[HDSelecterViewControllerAnimatedTransitioningObject alloc]init];
    obj.selecterViewController = self;
    return obj;
}

@end
