//
//  NSObject+LoadView.m
//  HHZcutvideo
//
//  Created by ouyangqi on 2019/12/10.
//  Copyright © 2019 ouyangqi. All rights reserved.
//

#import "NSObject+LoadView.h"


@implementation NSObject (LoadView)


+ (void)ou_showTextLoading:(NSString *)text
{
    [[LoadingView shareManager] onlyText:text];
    
    for (UIWindow *win in [UIApplication sharedApplication].windows) {
        if (win) {
            [win addSubview:[LoadingView shareManager]];
            return;
        }
    }
}

+ (void)ou_showAutoTextLoading:(NSString *)text
{
    [self ou_showTextLoading:text];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ou_hideAllLoading];
    });
}

+ (void)ou_showActivtyTextLoading:(NSString *)text
{
    [[LoadingView shareManager] activityText:text];
    [[LoadingView shareManager] startAnimation];
    for (UIWindow *win in [UIApplication sharedApplication].windows) {
        if (win) {
            [win addSubview:[LoadingView shareManager]];
            return;
        }
    }
}

+ (void)ou_hideAllLoading
{
    [[LoadingView shareManager] stopAnimation];
    [[LoadingView shareManager] removeFromSuperview];
}


@end
