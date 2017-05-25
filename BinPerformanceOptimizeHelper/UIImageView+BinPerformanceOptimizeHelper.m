//
//  UIImageView+BinPerformanceOptimizeHelper.m
//  ColorMisalignedImages研究
//
//  Created by jerryzhang on 17/5/12.
//  Copyright © 2017年 jerryzhang. All rights reserved.
//

#import "UIImageView+BinPerformanceOptimizeHelper.h"
#import "BinPerformanceOptimizeHelper.h"

@implementation UIImageView (BinPerformanceOptimizeHelper)

- (void)bin_setNoBlendedImageWithName:(NSString *)name {
    __weak typeof(self) weakSelf = self;
    [BinPerformanceOptimizeHelper bin_imageNamed:name completionBlock:^(UIImage *image) {
        weakSelf.image = image;
    }];
}

@end
