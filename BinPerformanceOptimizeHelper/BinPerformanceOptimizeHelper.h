//
//  BinPerformanceOptimizeHelper.h
//  BinBlendHelper
//
//  Created by jerryzhang on 17/5/8.
//  Copyright © 2017年 jerryzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BinSingleInstance.h"

typedef NSBlockOperation BinPerformanceOptimizeOpreation;
typedef void(^BinPerformanceOptimizeCompletionBlock)(UIImage *image);

typedef NS_ENUM(NSUInteger, BinPerformanceOptimizeGradientDirection) {
    BinPerformanceOptimizeGradientDirectionTopToBottom = 0,
    BinPerformanceOptimizeGradientDirectionBottomToTop,
    BinPerformanceOptimizeGradientDirectionLeftToRight,
    BinPerformanceOptimizeGradientDirectionRightToLeft
};

typedef NS_ENUM(NSInteger, BinPerformanceOptimizeImageCachePolicy) {
    BinPerformanceOptimizeImageCachePolicyNoCache = -1,
    BinPerformanceOptimizeImageCachePolicyOnlyMemory = 0,
    BinPerformanceOptimizeImageCachePolicyMemoryAndDisk
};

@interface BinPerformanceOptimizeHelper : NSObject

singleInterface(BinPerformanceOptimizeHelper)

+ (BinPerformanceOptimizeOpreation *)bin_imageNamed:(NSString *)name completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock;

+ (BinPerformanceOptimizeOpreation *)bin_noBlendedImageWithImage:(UIImage *)image cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock;

+ (BinPerformanceOptimizeOpreation *)bin_noMisalignedImageWithImage:(UIImage *)image size:(CGSize)size contentMode:(UIViewContentMode)contentMode cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock;

+ (BinPerformanceOptimizeOpreation *)bin_noBlendedMaskImageWithSize:(CGSize)size color:(UIColor *)color cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock;

+ (BinPerformanceOptimizeOpreation *)bin_noBlendedGradientMaskImageWithSize:(CGSize)size colors:(NSArray<UIColor *> *)colors locations:(NSArray *)locations direction:(BinPerformanceOptimizeGradientDirection)direction cachePolicy:(BinPerformanceOptimizeImageCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey completionBlock:(BinPerformanceOptimizeCompletionBlock)completionBlock;

+ (void)cancelAllPerformanceOptimizeOpreations;

@end
