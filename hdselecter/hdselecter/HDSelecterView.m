//
//  HDSelecterView.m
//  hdselecter
//
//  Created by meng on 2017/12/18.
//  Copyright © 2017年 hugdream. All rights reserved.
//

#import "HDSelecterView.h"
#import "HDSelecterTabView.h"

const int HDSelecterViewNotHasNextNumber = -1;

@interface HDSelecterItemModel()
@property(nonatomic,assign,readwrite)NSInteger index;
@end

/**列表的Cell*/
@interface HDSelecterItemTableViewCell : UITableViewCell{
    @private
    UILabel *_label;
    /**选中的勾勾图片*/
    UIImageView *_selectedImageView;
}
@property(nonatomic,strong)NSString* title;
@end
@implementation HDSelecterItemTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 0, CGRectGetHeight(self.frame))];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:label];
        
        _label = label;
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self updateSelectImageViewFrame];
}
-(void)setTitle:(NSString *)title{
    _title = title;
    _label.text = title;
    CGRect rect = _label.frame;
    rect.size.width = _label.attributedText.size.width;
    _label.frame = rect;
    if (_selectedImageView && self.selected) {
        [self updateSelectImageViewFrame];
    }
}
-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (selected) {
        _selectedImageView = _selectedImageView ?: [[UIImageView alloc]init];
        _selectedImageView.image = [UIImage imageNamed:@"hdselecter.bundle/selected"];
        [self.contentView addSubview:_selectedImageView];
        [self updateSelectImageViewFrame];
    }else{
        if(_selectedImageView){
            [_selectedImageView removeFromSuperview];
            _selectedImageView = nil;
        }
    }
}
-(void)updateSelectImageViewFrame{
    _selectedImageView.frame = CGRectMake(CGRectGetMaxX(_label.frame) + 16, (CGRectGetHeight(self.contentView.frame) - _selectedImageView.image.size.height)/2, _selectedImageView.image.size.width, _selectedImageView.image.size.height);
}
@end


@class HDSelecterViewModel;

@protocol HDSelecterViewModelDelegate <NSObject>

@required
-(NSInteger)numberOfitems:(HDSelecterViewModel*)viewModel;
-(HDSelecterItemModel*)selecterViewModel:(HDSelecterViewModel*)viewModel itemAtIndex:(NSInteger)index;
@end


@interface HDSelecterViewModel : NSObject <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,weak)id<HDSelecterViewModelDelegate> delegate;
@property(nonatomic,strong)HDSelecterItemModel *selectItem;
@property(nonatomic,copy)void(^selectedItemBlock)(HDSelecterViewModel*model,HDSelecterItemModel*item);
@end
@implementation HDSelecterViewModel
-(void)setTableView:(UITableView *)tableView{
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[HDSelecterItemTableViewCell class] forCellReuseIdentifier:@"cell"];
}
-(void)setSelectItem:(HDSelecterItemModel *)selectItem{
    _selectItem = selectItem;
    if (self.tableView.indexPathForSelectedRow == nil || self.tableView.indexPathForSelectedRow.row != selectItem.index) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectItem.index inSection:0] animated:false scrollPosition:UITableViewScrollPositionMiddle];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.delegate numberOfitems:self];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDSelecterItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.title = [self.delegate selecterViewModel:self itemAtIndex:indexPath.row].title;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:true];
    HDSelecterItemModel *itemModel = [self.delegate selecterViewModel:self itemAtIndex:indexPath.row];
    self.selectItem = itemModel;
    if(self.selectedItemBlock)
        self.selectedItemBlock(self,itemModel);
}
@end




@interface HDSelecterView() <HDSelecterTabViewDelegate,UIScrollViewDelegate,HDSelecterViewModelDelegate>
@property(nonatomic,strong)HDSelecterTabView *tabView;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)NSMutableArray<HDSelecterViewModel*>* models;
@property(nonatomic,strong,readonly)NSArray<HDSelecterItemModel*>* currentSelected;
@property(nonatomic,assign)NSInteger currentShowIndex;
@end

@implementation HDSelecterView

#pragma -mark override super
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.tabView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 44);
    self.scrollView.frame = CGRectMake(0, CGRectGetHeight(self.tabView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.tabView.frame));
    for (NSInteger i = 0; i < self.models.count; i++) {
        self.models[i].tableView.frame = CGRectMake(i * CGRectGetWidth(self.scrollView.frame), 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    }
    if(self.scrollView.contentOffset.x != CGRectGetMinX(self.models[self.currentShowIndex].tableView.frame))
        [self.scrollView setContentOffset:CGPointMake(CGRectGetMinX(self.models[self.currentShowIndex].tableView.frame), 0) animated:false];
}

-(void)reoloadUseSelectedIndexs:(NSArray<NSNumber *> *)selectIndexs{
    [self popAllSelectViewModel];
    for (NSNumber *numer in selectIndexs) {
        HDSelecterViewModel *viewModel = [self createViewModel];
        
        NSInteger index = numer.integerValue;
        HDSelecterItemModel *itemModel = nil;
        if ([self.datasource respondsToSelector:@selector(HDSelecterView:itemWithLastSelected:atIndex:)]) {
            itemModel = [self.datasource HDSelecterView:self itemWithLastSelected:self.currentSelected atIndex:index];
        }else if ([self.datasource respondsToSelector:@selector(HDSelecterView:titlesWithLastSelected:atIndex:)]){
            itemModel = [self titleToItemModel:[self.datasource HDSelecterView:self titlesWithLastSelected:self.currentSelected atIndex:index]];
        }else{
            @throw [NSException exceptionWithName:@"HDSelecterView Exception" reason:@"datasource error" userInfo:nil];
        }
        itemModel.index = index;
        [self pushSelectViewModel:viewModel animation:false];
        
        viewModel.selectItem = itemModel;
    }
    //如果还有
    if ([self.datasource numberOfItems:self lastSelected:self.currentSelected] != HDSelecterViewNotHasNextNumber) {
        [self pushSelectViewModel:[self createViewModel] animation:true];
    }
    [self updateTopTabTitles];
}

#pragma -mark delegates
/**点击上方的tab*/
-(void)HDSelecterTabView:(HDSelecterTabView *)tabView didSelectAtIndex:(NSInteger)index{
    [self setCurrentShowIndex:index animation:true];
}
/**滚动结束时*/
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setCurrentShowIndex:scrollView.contentOffset.x/scrollView.frame.size.width animation:true];
}

#pragma -mark get set
-(void)setDatasource:(id<HDSelecterViewDataSource>)datasource{
    _datasource = datasource;
    [self popAllSelectViewModel];
    HDSelecterViewModel* defualtViewModel = [self createViewModel];
    [self pushSelectViewModel:defualtViewModel animation:false];
}
/**设置当前显示的index*/
-(void)setCurrentShowIndex:(NSInteger)currentShowIndex{
    [self setCurrentShowIndex:currentShowIndex animation:false];
}
/**设置当前显示的index，是否使用动画*/
-(void)setCurrentShowIndex:(NSInteger)currentShowIndex animation:(BOOL)animation{
    _currentShowIndex = currentShowIndex;
    if(currentShowIndex == -1){
        self.tabView.currentIndex = -1;
        return;
    }
    if(self.tabView.currentIndex != currentShowIndex)
        [self.tabView setCurrentIndex:currentShowIndex animation:animation];
    if(self.scrollView.contentOffset.x != CGRectGetMinX(self.models[currentShowIndex].tableView.frame))
        [self.scrollView setContentOffset:CGPointMake(CGRectGetMinX(self.models[currentShowIndex].tableView.frame), 0) animated:animation];
}
/**当前选择的items*/
-(NSArray<HDSelecterItemModel*>*)currentSelected{
    NSMutableArray<HDSelecterItemModel*>* array = [NSMutableArray array];
    for (HDSelecterViewModel *viewModel in self.models) {
        if (viewModel.selectItem) {
            [array addObject:viewModel.selectItem];
        }
    }
    return array;
}

#pragma -mark delegate methods
-(NSInteger)numberOfitems:(HDSelecterViewModel*)viewModel{
    NSAssert([self.models containsObject:viewModel], @"");
    NSMutableArray<HDSelecterItemModel*>* selectedItems = [NSMutableArray array];
    for (HDSelecterViewModel *model in self.models) {
        if (model == viewModel) {
            break;
        }else if(model.selectItem){
            [selectedItems addObject:model.selectItem];
        }
    }
    return [self.datasource numberOfItems:self lastSelected:selectedItems];
}
-(HDSelecterItemModel*)selecterViewModel:(HDSelecterViewModel*)viewModel itemAtIndex:(NSInteger)index{
    NSAssert([self.models containsObject:viewModel], @"");
    NSMutableArray<HDSelecterItemModel*>* selectedItems = [NSMutableArray array];
    for (HDSelecterViewModel *model in self.models) {
        if (model == viewModel) {
            break;
        }else if(model.selectItem){
            [selectedItems addObject:model.selectItem];
        }
    }
    
    HDSelecterItemModel *itemModel = nil;
    if ([self.datasource respondsToSelector:@selector(HDSelecterView:itemWithLastSelected:atIndex:)]) {
        itemModel = [self.datasource HDSelecterView:self itemWithLastSelected:selectedItems atIndex:index];
    }else if ([self.datasource respondsToSelector:@selector(HDSelecterView:titlesWithLastSelected:atIndex:)]){
        itemModel = [self titleToItemModel:[self.datasource HDSelecterView:self titlesWithLastSelected:selectedItems atIndex:index]];
    }else{
        @throw [NSException exceptionWithName:@"HDSelecterView Exception" reason:@"datasource error" userInfo:nil];
    }
    itemModel.index = index;
    return itemModel;
}

#pragma -mark private methods
/**初始化*/
-(void)setup{
    self.models = [NSMutableArray array];
    self.defualtTitle = @"请选择";
    
    HDSelecterTabView *tabView = [[HDSelecterTabView alloc]init];
    tabView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 44);
    tabView.delegate = self;
    [self addSubview:tabView];
    self.tabView = tabView;
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.pagingEnabled = true;
    scrollView.delegate = self;
    scrollView.frame = CGRectMake(0, CGRectGetHeight(tabView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(tabView.frame));
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}
-(HDSelecterViewModel*)createViewModel{
    __weak typeof(self) weakSelf = self;
    HDSelecterViewModel *viewModel = [[HDSelecterViewModel alloc]init];
    //点击选择项目
    [viewModel setSelectedItemBlock:^(HDSelecterViewModel *model,HDSelecterItemModel *item) {
        //移除之后的
        while (weakSelf.models.lastObject != model) {
            [weakSelf popSelectViewModel:false];
        }
        if ([self.delegate respondsToSelector:@selector(HDSelecterView:didSelectItem:)]) {
            [self.delegate HDSelecterView:self didSelectItem:self.selectedItems];
        }
        if ([self.datasource numberOfItems:self lastSelected:self.selectedItems] == HDSelecterViewNotHasNextNumber) {
            if ([self.delegate respondsToSelector:@selector(HDSelecterView:completeSelected:)]) {
                [self.delegate HDSelecterView:self completeSelected:self.selectedItems];
            }
        }else{
            [weakSelf pushSelectViewModel:[self createViewModel] animation:true];
        }
        [weakSelf updateTopTabTitles];
    }];
    return viewModel;
}
-(void)updateTopTabTitles{
    NSMutableArray<NSString*>* newTabTitles = [NSMutableArray array];
    for (HDSelecterViewModel *viewModel in self.models) {
        [newTabTitles addObject:viewModel.selectItem ? viewModel.selectItem.title : self.defualtTitle];
    }
    self.tabView.titles = newTabTitles;
}
/**追加一个ViewModel*/
-(void)pushSelectViewModel:(HDSelecterViewModel*)m animation:(BOOL)animation{
    [self.models addObject:m];
    m.delegate = self;
    m.tableView = [[UITableView alloc]init];
    
    //修改scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.models.count,CGRectGetHeight(self.scrollView.frame));
    //添加tableView
    m.tableView.frame = CGRectMake((self.models.count - 1) * CGRectGetWidth(self.scrollView.frame), 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    [self.scrollView addSubview:m.tableView];
    [self updateTopTabTitles];
    //当前显示的viewModel移动当push的viewModel
    [self setCurrentShowIndex:self.models.count - 1 animation:animation];
}
/**移除最后一个ViewModel*/
-(void)popSelectViewModel:(BOOL)animation{
    if(self.models.count <= 0) return;
    
    //移除viewModel
    HDSelecterViewModel *lastViewModel = self.models.lastObject;
    [self.models removeObject:lastViewModel];
    [lastViewModel.tableView removeFromSuperview];
    
    //更新顶部tabView
    [self updateTopTabTitles];
    
    //更新scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake((MIN(0,self.models.count - 1)) * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    //如果当前显示的是最后一个(被移除的那一个)
    if (self.currentShowIndex == self.models.count) {
        [self setCurrentShowIndex:self.models.count - 1 animation:animation];
    }
}
/**移除所有ViewModel*/
-(void)popAllSelectViewModel{
    [self.models removeAllObjects];
    [self updateTopTabTitles];
    self.currentShowIndex = -1;
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetHeight(self.scrollView.frame));
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
-(NSString*)itemModelToTitle:(HDSelecterItemModel*)itemModel{
    return itemModel.title;
}
-(NSArray<NSString*>*)itemModelsToTitles:(NSArray<HDSelecterItemModel*>*)itemModels{
    NSMutableArray<NSString*>* titles = [NSMutableArray array];
    for (HDSelecterItemModel *itemModel in itemModels) {
        [titles addObject:[self itemModelToTitle:itemModel]];
    }
    return titles;
}
-(HDSelecterItemModel*)titleToItemModel:(NSString*)title{
    return [[HDSelecterItemModel alloc]initWithTitle:title];
}
-(NSArray<HDSelecterItemModel*>*)titlesToItemModels:(NSArray<NSString*>*)titles{
    NSMutableArray<HDSelecterItemModel*>* itemModels = [NSMutableArray array];
    for (NSString *title in titles) {
        [itemModels addObject:[self titleToItemModel:title]];
    }
    return itemModels;
}
-(NSArray<NSString*>*)selectedTitles{
    return [self itemModelsToTitles: self.currentSelected];
}
-(NSArray<HDSelecterItemModel*>*)selectedItems{
    return self.currentSelected;
}


@end
