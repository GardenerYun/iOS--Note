//
//  ACCalendarViewController.h
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/24.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+DateTools.h"
@class ACCalendarModel;

typedef void(^ACCalendarBlock)(ACCalendarModel *model);
/**
 *  日历类
 */
@interface ACCalendarViewController : UIViewController


/**
 *  showDays 可供选择的日期长度 
 *           默认为 365天
 */
@property (nonatomic, assign) NSInteger showDays;

/**
 *  selectedDays 被选中的日期
 *               默认为 今天
 */
@property (nonatomic, strong) NSDate *selectedDays;

@property (nonatomic, copy) ACCalendarBlock block;

@end
