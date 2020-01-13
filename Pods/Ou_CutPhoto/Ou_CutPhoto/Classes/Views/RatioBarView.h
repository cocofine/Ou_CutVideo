//
//  RatioBarView.h
//  HaoHaoZhu
//
//  Created by ouyangqi on 2018/10/31.
//  Copyright © 2018年 HaoHaoZhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOCropViewConstants.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BtnClickBlock)(NSInteger RatioType);
@interface RatioBarView : UIView

@property (nonatomic, copy) BtnClickBlock typeBlock;


/*
 0.  自由
 1.  1:1
 2.  3:4
 3.  4:3
 4.  9:16
 5.  16:9
 6.  旋转
 7.  还原
 8.  确认
 9.  取消
 
 */

@end

NS_ASSUME_NONNULL_END
