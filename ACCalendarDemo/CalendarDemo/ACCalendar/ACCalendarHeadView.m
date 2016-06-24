//
//  ACCalendarHeadView.m
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/25.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import "ACCalendarHeadView.h"
#import "ACCalendarCell.h"

@implementation ACCalendarHeadView {

    UILabel *_yearTitleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews {

    NSArray *weeks = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width/7.0;
    CGFloat labelHeight = 25.0;
    
    for (int i=0; i<weeks.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*labelWidth, self.frame.size.height-labelHeight, labelWidth, labelHeight)];
        label.text = weeks[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        if (i==0 || i==6) {
            label.textColor = [UIColor redColor];
        } else {
            label.textColor = [UIColor darkGrayColor];
        }
        [self addSubview:label];
    }
    
    UIView *seqView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
    seqView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:seqView];
    
    _yearTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height-labelHeight)];
    _yearTitleLabel.text = @"";
    _yearTitleLabel.font = [UIFont systemFontOfSize:16];
    _yearTitleLabel.textAlignment = NSTextAlignmentCenter;
//    _yearTitleLabel.backgroundColor = [UIColor orangeColor];
    [self addSubview:_yearTitleLabel];
}

- (void)setModel:(ACCalendarModel *)model {

    if (_model != model) {
        _model = model;
        
        _yearTitleLabel.text = [NSString stringWithFormat:@"%ld年 %ld月", self.model.year, self.model.month];
    }
    
}


@end
