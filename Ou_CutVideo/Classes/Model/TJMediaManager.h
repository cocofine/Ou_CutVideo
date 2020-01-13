//
//  TJMediaManager.h
//  TJVideoEditer
//
//  Created by TanJian on 17/2/10.
//  Copyright © 2017年 Joshpell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


typedef struct _TimeRange {
    CGFloat location;
    CGFloat length;
} TimeRange;

@interface TJMediaManager : NSObject

/**
 截取视频并可以添加三方音频
 */
+ (void)addBackgroundMiusicWithVideoUrlStr:(NSURL *)videoUrl audioUrl:(NSURL *)audioUrl andCaptureVideoWithRange:(TimeRange)videoRange completion:(void(^)(NSString *strPath,AVAssetExportSession *assetExportSession))completionHandle;

/**
 获取多媒体时长
 */
+ (CGFloat)getMediaDurationWithMediaUrl:(NSString *)mediaUrlStr;


/**
 获取传入时间节点的帧图片（可控制是否为关键帧）
 */
+(UIImage *)getCoverImage:(NSURL *)outMovieURL atTime:(CGFloat)time isKeyImage:(BOOL)isKeyImage maximumSize:(CGSize) maximumSize;
//根据url获取时长
//获取视频时长
+(CGFloat)getVideoTimeWithURL:(NSURL *)videoURL;
@end
