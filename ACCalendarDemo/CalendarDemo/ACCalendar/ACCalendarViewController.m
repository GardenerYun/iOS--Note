//
//  ACCalendarViewController.m
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/24.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import "ACCalendarViewController.h"
#import "ACCalendarCell.h"
#import "ACCalendarHeadView.h"
#import "ACCalendarModel.h"
#import "NSDate+DateTools.h"

@interface ACCalendarViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {

    NSString *_cellIdentify;
    NSString *_headViewIdentify;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@end

@implementation ACCalendarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"日历";
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initSubViews];
    
    [self _calculateDate];
}

- (void)_initSubViews {

    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    collectionViewFlowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width/7.0, ACCalendarCellHeight); // 每个cell的大小
    collectionViewFlowLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, ACCalendarHeadViewHeight); //头部视图的框架大小
    collectionViewFlowLayout.minimumLineSpacing = 0.0f; //每行的最小间距
    collectionViewFlowLayout.minimumInteritemSpacing = 0.0f; //每列的最小间距
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical; // collectionView 滑动的方向
    collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //网格视图的/上/左/下/右,的边距
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    _cellIdentify = NSStringFromClass([ACCalendarCell class]);
    [self.collectionView registerClass:[ACCalendarCell class] forCellWithReuseIdentifier:_cellIdentify];
    
    _headViewIdentify = NSStringFromClass([ACCalendarHeadView class]);
    [self.collectionView registerClass:[ACCalendarHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_headViewIdentify];
    
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return self.dateArray.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    NSArray *array = self.dateArray[section];
    
    return array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ACCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentify forIndexPath:indexPath];

    NSArray *array = self.dateArray[indexPath.section];
    cell.model = array[indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    ACCalendarHeadView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_headViewIdentify forIndexPath:indexPath];
        
        NSArray *array = self.dateArray[indexPath.section];
        reusableview.model = array[15];
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    ACCalendarModel *model = self.dateArray[indexPath.section][indexPath.item];
    
    
    if (model.type == ACCalendarCellTypeDefault) {
        
        model.type = ACCalendarCellTypeSelect;
        
        ACCalendarModel *oldModel = self.dateArray[self.selectIndexPath.section][self.selectIndexPath.item];
        oldModel.type = ACCalendarCellTypeDefault;
        
        self.dateArray[indexPath.section][indexPath.item] = model;
        self.dateArray[self.selectIndexPath.section][self.selectIndexPath.item] = oldModel;
        
        self.selectIndexPath = indexPath;
        
        [collectionView reloadData];
        
        
        if (self.block) {
            self.block(model);
            self.title = model.dateString;
        }
    }

}

#pragma mark - Date calculate logic
- (void)_calculateDate {

    if (self.showDays == 0) {
        self.showDays = 365;
    }
    if (self.selectedDays == nil) {
        self.selectedDays = [NSDate date];
    }
    
    self.dateArray = [NSMutableArray array];
    
    NSDate *todate = [NSDate date];
    NSDate *lastDay = [todate dateByAddingYears:1];
    NSInteger months = [lastDay monthsLaterThan:todate];
    
    for (int i = 0; i <= months; i++) {
        
        NSDate *monthDate = [todate dateByAddingMonths:i];

        NSMutableArray *monthDateArray = [NSMutableArray array];
        
        /**
         *  计算上个月
         */
        NSDate *monthFirstDay = [NSDate dateWithYear:monthDate.year month:monthDate.month day:1];
        NSDate *previousMonthDay = [monthFirstDay dateByAddingMonths:-1];
        for (NSInteger j = previousMonthDay.daysInMonth-(monthFirstDay.weekday-1)+1; j<=previousMonthDay.daysInMonth; j++) {
            NSDate *previousDate = [NSDate dateWithYear:previousMonthDay.year month:previousMonthDay.month day:j];
            ACCalendarModel *model = [ACCalendarModel initWithDate:previousDate];
            model.type = ACCalendarCellTypeNone;
            [monthDateArray addObject:model];
        }
        /**
         *  计算本月
         */
        for (int j = 1; j <= monthDate.daysInMonth; j++) {
            NSDate *currentDate = [NSDate dateWithYear:monthDate.year month:monthDate.month day:j];
            ACCalendarModel *model = [ACCalendarModel initWithDate:currentDate];
            model.type = ACCalendarCellTypeDefault;
            NSDate *today = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
            if ([today isLaterThan:model.date]) {
                model.type = ACCalendarCellTypeGray;
            }
            if ([model.date isSameDay:self.selectedDays]) {
                model.type = ACCalendarCellTypeSelect;
                self.selectIndexPath = [NSIndexPath indexPathForItem:monthDateArray.count inSection:i];
            }
            [monthDateArray addObject:model];
        }
        [self.dateArray addObject:monthDateArray];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
