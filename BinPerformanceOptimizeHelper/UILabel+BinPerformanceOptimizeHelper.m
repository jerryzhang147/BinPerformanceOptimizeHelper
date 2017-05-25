//
//  UILabel+BinPerformanceOptimizeHelper.m
//  BinBlendHelper
//
//  Created by jerryzhang on 17/5/8.
//  Copyright © 2017年 jerryzhang. All rights reserved.
//

#import "UILabel+BinPerformanceOptimizeHelper.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation UILabel (BinPerformanceOptimizeHelper)
+ (void)load
{
    // Swizzling done as described on NSHipster
    // http://nshipster.com/method-swizzling/
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        orSwizzleInstanceMethod([self class], @selector(initWithFrame:), @selector(bin_initWithFrame:));
    });
}

- (instancetype)bin_initWithFrame:(CGRect)frame {
    [self bin_initWithFrame:frame];
    
    // *** 默认设置成白色，可以避免blend layer的产生
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

static void orSwizzleInstanceMethod(Class klass, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(klass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(klass, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(klass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(klass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
