//
//  UIButton+BinPerformanceOptimizeHelper.m
//  BinBlendHelper
//
//  Created by jerryzhang on 17/5/9.
//  Copyright © 2017年 jerryzhang. All rights reserved.
//

#import "UIButton+BinPerformanceOptimizeHelper.h"

@implementation UIButton (BinPerformanceOptimizeHelper)

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    self.titleLabel.backgroundColor = backgroundColor;
}

@end
