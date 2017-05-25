//
//  BinTableViewCell.m
//  BinBlendHelper
//
//  Created by jerryzhang on 17/5/5.
//  Copyright © 2017年 jerryzhang. All rights reserved.
//

#import "BinTableViewCell.h"
#import "BinPerformanceOptimizeHelper.h"

@interface BinTableViewCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImageView *iconView1;
@property (nonatomic, strong) UIImageView *iconView2;
@property (nonatomic, strong) UIImageView *iconView3;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIImage *image;

@end

@implementation BinTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.iconView = [[UIImageView alloc]init];
        self.iconView.backgroundColor = [UIColor lightGrayColor];
        
        self.iconView.frame = CGRectMake(10, 10, 100, 100);
        [self.contentView addSubview:self.iconView];
        
        self.iconView1 = [[UIImageView alloc]init];
        self.iconView1.backgroundColor = [UIColor lightGrayColor];
        
        self.iconView1.frame = CGRectMake(50, 10, 100, 100);
        [self.contentView addSubview:self.iconView1];
        
        self.iconView2 = [[UIImageView alloc]init];
        self.iconView2.backgroundColor = [UIColor lightGrayColor];
        self.iconView2.frame = CGRectMake(100, 10, 100, 100);
        [self.contentView addSubview:self.iconView2];
        
        self.iconView3 = [[UIImageView alloc]init];
        self.iconView3.backgroundColor = [UIColor lightGrayColor];
        
        self.iconView3.frame = CGRectMake(170, 10, 100, 100);
        [self.contentView addSubview:self.iconView3];
        
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(220, 20, 100, 60)];
        self.label.text = @"fdksfjdksdkfjsdklajggj";
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
        
    }
    return self;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
   
    UIImage *image = [UIImage imageNamed:@"03"];
//    self.iconView.image = image;
//    self.iconView1.image = image;
//    self.iconView2.image = image;
//    self.iconView3.image = image;
    
    if (self.image == nil) {
        self.image = [self handleImage:image];
    }
    
    [BinPerformanceOptimizeHelper bin_noMisalignedImageWithImage:image size:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleToFill cachePolicy:BinPerformanceOptimizeImageCachePolicyOnlyMemory cacheKey:@"fjdsklfjklsdajfklasjgkl" completionBlock:^(UIImage *image) {
        self.iconView.image = image;
        self.iconView1.image = image;
        self.iconView2.image = image;
        self.iconView3.image = image;
    }];
}

- (UIImage *)handleImage:(UIImage *)image {
    CGRect rect = CGRectMake(0, 0, 100, 100);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 由于设置的是实体属性是YES，所以默认会变成黑色填充，把默认的颜色设置为白色填充
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    //    CGContextSetFillColorWithColor(context, color.CGColor);
    //    CGContextFillRect(context, rect);
    [image drawInRect:rect];
    UIImage *noBlendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return noBlendedImage;
}

- (UIImage *)imageByAmend:(UIImage *)image {
    CGRect rect = CGRectMake(0, 0, 100, 100);
    // 这里必须要设置为YES，防止新绘制的图片有透明像素
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 先填充颜色，保证原本的png透明像素被这里的背景色填充，然后进行裁剪，和image的draw操作
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextFillRect(context, rect);
    
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
