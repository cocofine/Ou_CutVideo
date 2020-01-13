//
//  UIView+ClickEdgeInsets.m
//  HaoHaoZhu
//
//  Created by ouyangqi on 2019/4/16.
//  Copyright © 2019 HaoHaoZhu. All rights reserved.
//

#import "UIView+ClickEdgeInsets.h"
#import <objc/runtime.h>

@implementation UIView (ClickEdgeInsets)


- (UIEdgeInsets)clickEdgeInsets
{
    return [objc_getAssociatedObject(self, @selector(clickEdgeInsets)) UIEdgeInsetsValue];
}

- (void)setClickEdgeInsets:(UIEdgeInsets)clickEdgeInsets
{
    objc_setAssociatedObject(self, @selector(clickEdgeInsets), [NSValue valueWithUIEdgeInsets:clickEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    UIEdgeInsets insets = UIEdgeInsetsMake(-self.clickEdgeInsets.top, -self.clickEdgeInsets.left, -self.clickEdgeInsets.bottom, -self.clickEdgeInsets.right);
    CGRect large = UIEdgeInsetsInsetRect(self.bounds, insets);
    return CGRectContainsPoint(large, point) ? YES : NO;
    
}


@end
