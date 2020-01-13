//
//  UIView+ClickEdgeInsets.h
//  HaoHaoZhu
//
//  Created by ouyangqi on 2019/4/16.
//  Copyright © 2019 HaoHaoZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ClickEdgeInsets)

/** 上左下右分别增加或减小多少  正数为增加 负数为减小*/
@property (nonatomic, assign) UIEdgeInsets clickEdgeInsets;

@end

NS_ASSUME_NONNULL_END
