//
//  ACCalendarCell.m
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/24.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import "ACCalendarCell.h"

@implementation ACCalendarCell {

    UILabel *_gregorianLabel;
    UILabel *_chineseLabel;
    UIView *_selectBgView;
}

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews {
    
    _selectBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.height, self.contentView.bounds.size.height)];
    _selectBgView.center = self.contentView.center;
    _selectBgView.backgroundColor = [UIColor redColor];
    _selectBgView.layer.cornerRadius = _selectBgView.frame.size.width/2.0;
    [self.contentView addSubview:_selectBgView];
    
    _gregorianLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 20)];
    _gregorianLabel.font = [UIFont systemFontOfSize:18];
    _gregorianLabel.textColor = [UIColor blackColor];
    _gregorianLabel.textAlignment = NSTextAlignmentCenter;
    _gregorianLabel.text = @"";
    [self.contentView addSubview:_gregorianLabel];
    
    _chineseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.bounds.size.width, 10)];
    _chineseLabel.font = [UIFont systemFontOfSize:10];
    _chineseLabel.textColor = [UIColor darkGrayColor];
    _chineseLabel.textAlignment = NSTextAlignmentCenter;
    _chineseLabel.text = @"";
    [self.contentView addSubview:_chineseLabel];
    
    
}

- (void)setModel:(ACCalendarModel *)model {

    if (_model != model) {
        _model = model;
        
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    _gregorianLabel.text = [NSString stringWithFormat:@"%ld",self.model.day];

    _chineseLabel.text = [NSString stringWithFormat:@"%@",self.model.lunarDay];
    

    
    
    if (self.model.type == ACCalendarCellTypeNone) {
        self.contentView.hidden = YES;
    }
    else if (self.model.type == ACCalendarCellTypeGray) {
        self.contentView.hidden = NO;
        _gregorianLabel.textColor = [UIColor lightGrayColor];
        _chineseLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        self.contentView.hidden = NO;
    }
    
    switch (self.model.type) {
        
        case ACCalendarCellTypeNone:
            self.contentView.hidden = YES;
            _selectBgView.hidden = YES;
            break;
            
        case ACCalendarCellTypeGray:
            self.contentView.hidden = NO;
            _selectBgView.hidden = YES;
            if (self.model.holiday.length > 0) {
                _chineseLabel.text = self.model.holiday;
            }
            else if ([self.model.lunarDay isEqualToString:@"初一"]) {
                _chineseLabel.text = self.model.lunarMonth;
            }
            else if (self.model.lunarSolarTerms.length > 0) {
                _chineseLabel.text = self.model.lunarSolarTerms;
            }
            _gregorianLabel.textColor = [UIColor lightGrayColor];
            _chineseLabel.textColor = [UIColor lightGrayColor];
            break;
            
        case ACCalendarCellTypeDefault:
            self.contentView.hidden = NO;
            _selectBgView.hidden = YES;
            if (self.model.holiday.length > 0) {
                _chineseLabel.text = self.model.holiday;
                _chineseLabel.textColor = [UIColor redColor];
            }
            else if ([self.model.lunarDay isEqualToString:@"初一"]) {
                _chineseLabel.text = self.model.lunarMonth;
                _chineseLabel.textColor = [UIColor orangeColor];
            }
            else if (self.model.lunarSolarTerms.length > 0) {
                _chineseLabel.text = self.model.lunarSolarTerms;
                _chineseLabel.textColor = [UIColor colorWithRed:65/255.0 green:190/255.0 blue:65/255.0 alpha:1];
            }
            else {
                _chineseLabel.textColor = [UIColor darkGrayColor];
            }
            _gregorianLabel.textColor = [UIColor blackColor];
            break;
            
        case ACCalendarCellTypeSelect:
            self.contentView.hidden = NO;
            _selectBgView.hidden = NO;
            if (self.model.holiday.length > 0) {
                _chineseLabel.text = self.model.holiday;
            }
            else if ([self.model.lunarDay isEqualToString:@"初一"]) {
                _chineseLabel.text = self.model.lunarMonth;
            }
            else if (self.model.lunarSolarTerms.length > 0) {
                _chineseLabel.text = self.model.lunarSolarTerms;
            }
            _chineseLabel.textColor = [UIColor whiteColor];
            _gregorianLabel.textColor = [UIColor whiteColor];
            
            break;
            
        default:
            break;
    }
    
}


@end
