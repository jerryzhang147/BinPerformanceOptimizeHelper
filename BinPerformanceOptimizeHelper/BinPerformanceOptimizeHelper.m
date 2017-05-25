//
//  BinPerformanceOptimizeHelper.m
//  BinBlendHelper
//
//  Created by jerryzhang on 17/5/8.
//  Copyright © 2017年 jerryzhang. All rights reserved.
//

#import "BinPerformanceOptimizeHelper.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>

#define BinDefaultCacheImageKey @"BinDefaultCacheImageKey"

@interface BinPerformanceOptimizeHelper ()
@property (nonatomic, strong) NSOperationQueue *performanceOptimizeQueue;

@end

@implementation BinPerformanceOptimizeHelper

singleImplementation(BinPerformanceOptimizeHelper)

- (instancetype)init {
    if (self = [super init]) {
        _performanceOptimizeQueue = [NSOperationQueue new];
    }
    return self;
}

+ (BinPerformanceOptimizeOpreation *)bin_imageNamed:(NSString *)name completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock {
    // to do 3x
    NSString *imageFileName = [NSString stringWithFormat:@"%@@2x.png",name];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[self imageCacheKeyWithFileName:imageFileName]];
    if (image && completionBlock) {
        completionBlock(image);
        return nil;
    }
    
    if (!name.length || !name) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return nil;
    }

    BinPerformanceOptimizeOpreation *opreation = [BinPerformanceOptimizeOpreation blockOperationWithBlock:^{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:nil];
        [self bin_noBlendedImageWithImage:[[UIImage alloc]initWithContentsOfFile:imagePath] cachePolicy:0 cacheKey:[self imageCacheKeyWithFileName:imageFileName] completionBlock:completionBlock];
    }];
    
    [[BinPerformanceOptimizeHelper sharedBinPerformanceOptimizeHelper].performanceOptimizeQueue addOperation:opreation];
    
    return opreation;
}

+ (NSString *)imageCacheKeyWithFileName:(NSString *)fileName {
    return [NSString stringWithFormat:@"%@%@", BinDefaultCacheImageKey, fileName];
}

+ (BinPerformanceOptimizeOpreation *)bin_noBlendedImageWithImage:(UIImage *)image cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock {
    if (!image) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return nil;
    }
    
    BinPerformanceOptimizeOpreation *opreation = [BinPerformanceOptimizeOpreation blockOperationWithBlock:^{
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        // 这里必须要设置为YES，表示为实体，原本图片的所有透明像素会被黑色（系统规定的）填充，防止新绘制的图片有透明像素
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // 由于上面会把原本图片的透明像素使用黑色填充，所以这里我们使用标准的白色进行填充，那么就看不出来了
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, rect);
        
        // 绘制图片到新的区域
        [image drawInRect:rect];
        UIImage *noBlendedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(noBlendedImage);
            }
            
            [self cacheImageWithImage:image cacheKey:cacheKey cachePolicy:cachePolicy];
        });
    }];
    
    [[BinPerformanceOptimizeHelper sharedBinPerformanceOptimizeHelper].performanceOptimizeQueue addOperation:opreation];
    
    return opreation;
}

+ (void)cacheImageWithImage:(UIImage *)image cacheKey:(NSString *)cacheKey cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy {
    switch (cachePolicy) {
        case BinPerformanceOptimizeImageCachePolicyNoCache:
            break;
        case BinPerformanceOptimizeImageCachePolicyOnlyMemory: {
            [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey toDisk:NO completion:nil];
        }
            break;
        case BinPerformanceOptimizeImageCachePolicyMemoryAndDisk: {
            [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey toDisk:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

+ (BinPerformanceOptimizeOpreation *)bin_noBlendedMaskImageWithSize:(CGSize)size color:(UIColor *)color cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock {
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
    if (cacheImage && completionBlock) {
        completionBlock(cacheImage);
        return nil;
    }
    
    BinPerformanceOptimizeOpreation *opreation = [BinPerformanceOptimizeOpreation blockOperationWithBlock:^{
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // 由于设置的是实体属性是YES，所以默认会变成黑色填充，把默认的颜色设置为白色填充
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, rect);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        UIImage *noBlendedMaskImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(noBlendedMaskImage);
            }
            
            [self cacheImageWithImage:noBlendedMaskImage cacheKey:cacheKey cachePolicy:cachePolicy];
        });
    }];
    
    [[BinPerformanceOptimizeHelper sharedBinPerformanceOptimizeHelper].performanceOptimizeQueue addOperation:opreation];
    
    return opreation;
}

+ (BinPerformanceOptimizeOpreation *)bin_noBlendedGradientMaskImageWithSize:(CGSize)size colors:(NSArray<UIColor *> *)colors locations:(NSArray *) locations direction:(BinPerformanceOptimizeGradientDirection)direction cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock {
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
    if (cacheImage && completionBlock) {
        completionBlock(cacheImage);
        return nil;
    }
    
    if ((colors.count != locations.count) || !colors.count || !locations.count) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return nil;
    }
    
    BinPerformanceOptimizeOpreation *opreation = [BinPerformanceOptimizeOpreation blockOperationWithBlock:^{
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // 由于设置的是实体属性是YES，所以默认会变成黑色填充，把默认的颜色设置为白色填充
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, rect);
        
        // 添加渐变
        NSMutableArray *conponents = [NSMutableArray arrayWithCapacity:colors.count * 4];
        
        for (UIColor *color in colors) {
            CGFloat red = 0.f;
            CGFloat green = 0.f;
            CGFloat blue = 0.f;
            CGFloat alpha = 0.f;
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            
            [conponents addObjectsFromArray:@[@(red), @(green), @(blue), @(alpha)]];
        }
        
        CGFloat *cConponents = (CGFloat *)calloc(conponents.count, sizeof(CGFloat));
        
        for(NSInteger i = 0; i < conponents.count; i++) {
            *(cConponents + i) = [conponents[i] floatValue];
        }
        
        CGFloat *cLocations = (CGFloat *)calloc(locations.count, sizeof(CGFloat));
        
        for(NSInteger i = 0; i < locations.count; i++) {
            *(cLocations + i) = [locations[i] floatValue];
        }
        
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, cConponents, cLocations, locations.count);
        
        CGPoint startPoint = CGPointZero;
        CGPoint endPoint = CGPointZero;
        
        switch (direction) {
            case BinPerformanceOptimizeGradientDirectionTopToBottom: {
                startPoint = CGPointMake(0, 0);
                endPoint = CGPointMake(0, size.height);
            }
                break;
            case BinPerformanceOptimizeGradientDirectionBottomToTop: {
                startPoint = CGPointMake(0, size.height);
                endPoint = CGPointMake(0, 0);
            }
                break;
            case BinPerformanceOptimizeGradientDirectionLeftToRight: {
                startPoint = CGPointMake(0, 0);
                endPoint = CGPointMake(size.width, 0);
            }
                break;
            case BinPerformanceOptimizeGradientDirectionRightToLeft: {
                startPoint = CGPointMake(size.width, 0);
                endPoint = CGPointMake(0, 0);
            }
                
            default:
                break;
        }
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
        free(cConponents); // 释放c内存，因为使用calloc方法，分配的空间是在堆区
        
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
        
        UIImage *noBlendedGradientMaskImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(noBlendedGradientMaskImage);
            }
            
            [self cacheImageWithImage:noBlendedGradientMaskImage cacheKey:cacheKey cachePolicy:cachePolicy];
        });
    }];
    
    [[BinPerformanceOptimizeHelper sharedBinPerformanceOptimizeHelper].performanceOptimizeQueue addOperation:opreation];
    
    return opreation;
}

+ (BinPerformanceOptimizeOpreation *)bin_noMisalignedImageWithImage:(UIImage *)image size:(CGSize)size contentMode:(UIViewContentMode)contentMode cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock {
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
    if (cacheImage && completionBlock) {
        completionBlock(cacheImage);
        return nil;
    }
    
    if (!image) {
        if (completionBlock) {
            completionBlock(image);
        }
        return nil;
    }
    
    BinPerformanceOptimizeOpreation *opreation = [BinPerformanceOptimizeOpreation blockOperationWithBlock:^{
        CGRect contextRect = CGRectMake(0, 0, size.width, size.height);
        CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
        BOOL isNeedClip = NO;
        
        switch (contentMode) {
            case UIViewContentModeScaleToFill:
                contextRect = CGRectMake(0, 0, size.width, size.height);
                break;
            case UIViewContentModeScaleAspectFit: {
                // 表示等比例进行缩放的时候，宽度方向是被填满，高度方向无法填充满
                if (size.width / size.height < image.size.width / image.size.height) {
                    CGFloat height = (size.width / image.size.width) * image.size.height;
                    imageRect = CGRectMake(0, (size.height - height) * 0.5f, size.width, height);
                } else { // 表示等比例进行缩放的时候，高度方向是被填满，宽度方向无法填充满
                    CGFloat width = (size.height / image.size.height) * image.size.width;
                    imageRect = CGRectMake((size.width - width) * 0.5f, 0, width, size.height);
                }
            }
                break;
            case UIViewContentModeScaleAspectFill: {
                if (size.width / size.height < image.size.width / image.size.height) {
                    CGFloat width = (size.height / image.size.height) * image.size.width;
                    imageRect = CGRectMake(0, 0, width, size.height);
                    contextRect = imageRect;
                    isNeedClip = YES;
                } else {
                    CGFloat height = (size.width / image.size.width) * image.size.height;
                    imageRect = CGRectMake(0, 0, size.width, height);
                    contextRect = imageRect;
                    isNeedClip = YES;
                }
            }
                break;
            default:
                break;
        }
        
        UIGraphicsBeginImageContextWithOptions(contextRect.size, YES, 0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // 由于设置的是实体属性是YES，所以默认会变成黑色填充，把默认的颜色设置为白色填充
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, contextRect);
        
        [image drawInRect:imageRect];
        UIImage *noMisalignedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        // 如果是UIViewContentModeScaleAspectFill，我们需要先把图片进行等比例的放大（这种放大是上下文context的绘图区域已经超出了size），所以需要把当前生成的图片进行二次裁剪
        if (contentMode == UIViewContentModeScaleAspectFill && isNeedClip) {
            [self clipImageWithImage:noMisalignedImage size:CGSizeMake(size.width, size.height) completionBlock:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(noMisalignedImage);
                    }
                    
                    [self cacheImageWithImage:noMisalignedImage cacheKey:cacheKey cachePolicy:cachePolicy];
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(noMisalignedImage);
                }
                
                [self cacheImageWithImage:noMisalignedImage cacheKey:cacheKey cachePolicy:cachePolicy];
            });
        }
    }];
    
    [[BinPerformanceOptimizeHelper sharedBinPerformanceOptimizeHelper].performanceOptimizeQueue addOperation:opreation];
    
    return opreation;
}

+ (void)clipImageWithImage:(UIImage *)image size:(CGSize)size completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock {
    CGRect contextRect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(contextRect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat wOffset = 0.f;
    CGFloat hOffset = 0.f;
    
    if (image.size.width != contextRect.size.width) {
        wOffset = (image.size.width - contextRect.size.width) * 0.5f;
    } else if (image.size.height != contextRect.size.height) {
        hOffset = (image.size.height - contextRect.size.height) * 0.5f;
        
    }
    CGContextTranslateCTM(context, -wOffset, -hOffset);
    CGContextClipToRect(context, CGRectMake(wOffset, hOffset, contextRect.size.width, contextRect.size.height));
    
    [image drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (completionBlock) {
        completionBlock(clipImage);
    }
}

+ (void)cancelAllPerformanceOptimizeOpreations {
    [[BinPerformanceOptimizeHelper sharedBinPerformanceOptimizeHelper].performanceOptimizeQueue cancelAllOperations];
}

@end
