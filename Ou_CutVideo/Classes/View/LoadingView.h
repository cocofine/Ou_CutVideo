//
//  LoadingView.h
//  HHZcutvideo
//
//  Created by ouyangqi on 2019/12/6.
//  Copyright © 2019 ouyangqi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingView : UIView

+ (instancetype)shareManager;

- (void)onlyText:(NSString *)text;

- (void)activityText:(NSString *)text;

- (void)stopAnimation;

- (void)startAnimation;

@end

NS_ASSUME_NONNULL_END
