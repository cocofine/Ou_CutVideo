//
//  CutVideoViewController.h
//  HaoHaoZhu
//
//  Created by ouyangqi on 2019/3/26.
//  Copyright © 2019年 HaoHaoZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kWindowWidth        [UIScreen mainScreen].bounds.size.width
#define kWindowHeight       [UIScreen mainScreen].bounds.size.height
#define kISiPhoneX           (kWindowHeight/kWindowWidth>2)
#define kTabBarBottom        (kISiPhoneX ? 34 : 0)
#define kStatusBarHeight     (kISiPhoneX ? 44 : 20)

typedef void(^VideoBlock)(NSURL *newVideoUrl, UIImage *newImg, CGFloat newTotalTime);

@interface CutVideoViewController : UIViewController

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, copy) VideoBlock videoBlock;

@property (nonatomic, assign) CGFloat maxTime;
@property (nonatomic, assign) CGFloat minTime;

@property (nonatomic, assign) CGFloat compress_min_size;//视频最小size
@property (nonatomic, assign) BOOL is_open_compress; //是否要压缩
@property (nonatomic, assign) CGFloat compress_rate;    //视频压缩比例
@property (nonatomic, assign) CGFloat max_code_rate;    //视频压缩最大码率

@end

NS_ASSUME_NONNULL_END
