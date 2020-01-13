//
//  CutVideosFrameView.h
//  cutMovie
//
//  Created by ouyangqi on 2019/3/22.
//  Copyright © 2019年 ouyangqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TimeBlock)(CGFloat startT, CGFloat endT);

@interface CutVideosFrameView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressCenter;

@property (nonatomic,strong) AVPlayer *player;

@property (nonatomic,copy) TimeBlock timeBlock;

@property (nonatomic, assign) CGFloat maxTime;
@property (nonatomic, assign) CGFloat minTime;

-(void)setUIWithUrl:(NSURL *)videoUrl;

@end

NS_ASSUME_NONNULL_END
