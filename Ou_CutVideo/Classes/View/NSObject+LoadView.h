//
//  NSObject+LoadView.h
//  HHZcutvideo
//
//  Created by ouyangqi on 2019/12/10.
//  Copyright © 2019 ouyangqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LoadView)

+ (void)ou_showTextLoading:(NSString *)text;

+ (void)ou_showAutoTextLoading:(NSString *)text;

+ (void)ou_showActivtyTextLoading:(NSString *)text;

+ (void)ou_hideAllLoading;


@end

NS_ASSUME_NONNULL_END
