//
//  ViewController.m
//  ColorMisalignedImages研究
//
//  Created by jerryzhang on 17/5/11.
//  Copyright © 2017年 jerryzhang. All rights reserved.
//

#import "ViewController.h"
#import "BinViewController.h"
#import "BinPerformanceOptimizeHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    imageView.userInteractionEnabled = NO;
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor yellowColor    ];
    
    imageView.frame = CGRectMake(20, 30, 120, 80);
    [BinPerformanceOptimizeHelper bin_noBlendedMaskImageWithSize:CGSizeMake(120, 80) color:[UIColor lightGrayColor] cachePolicy:BinPerformanceOptimizeImageCachePolicyOnlyMemory cacheKey:@"fdskfjag" completionBlock:^(UIImage *image) {
        imageView.image = image;
    }];
    
//    [BinPerformanceOptimizeHelper bin_imageNamed:@"common_systemshare_fb" completionBlock:^(UIImage *image) {
//        imageView.image = image;
//    }];
    
    [self.view addSubview:imageView];
//    self.view.maskView = imageView;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 350, 100, 50);
    [button setTitle:@"Button" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)btn {
    [self presentViewController:[BinViewController new] animated:YES completion:nil];
}


- (UIImage *)handleImage:(UIImage *)image {
    CGRect rect = CGRectMake(0, 0, 140, 80);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 由于设置的是实体属性是YES，所以默认会变成黑色填充，把默认的颜色设置为白色填充
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextFillRect(context, rect);
    
    [image drawInRect:rect];
    UIImage *noBlendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return noBlendedImage;
}



@end
