//
//  ACCalendarCell.h
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/24.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCalendarModel.h"
#import "NSDate+DateTools.h"
#define ACCalendarCellHeight 40.0f
#define ACCalendarHeadViewHeight 60.0f

@interface ACCalendarCell : UICollectionViewCell

@property (nonatomic, strong) ACCalendarModel *model;

@end
