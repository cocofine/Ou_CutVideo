//
//  CutVideoViewController.m
//  HaoHaoZhu
//
//  Created by ouyangqi on 2019/3/26.
//  Copyright © 2019年 HaoHaoZhu. All rights reserved.
//

#import "CutVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TJMediaManager.h"
#import "TJPhotoManager.h"
#import "CutVideosFrameView.h"
#import "SDAVAssetExportSession.h"
#import "NSObject+LoadView.h"

//#define kMaxTime    [Util shareUtil].commonSet.videoExtendInfo.video_max_time

typedef NS_ENUM(NSUInteger, ResolutionType) {
    ResolutionType540P,
    ResolutionType720P,
    ResolutionType1080P,
    ResolutionTypeGreater,
//    ResolutionType2K,
//    ResolutionType4K,
};

@interface CutVideoViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottom;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic,strong) AVPlayer *player;
@property(nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;


@property (nonatomic,assign) CGFloat startTime;             //裁剪开始时间点
@property (nonatomic,assign) CGFloat endTime;               //裁剪结束时间点

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backTop;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;


typedef void(^VideoCompressBlock)(AVAssetExportSessionStatus status);
@property (nonatomic, copy) VideoCompressBlock videoCompressBlock;

@property (nonatomic, assign) CGFloat originSize;

@property (nonatomic, strong) NSString *originPath;
@property (nonatomic, assign) ResolutionType resolutionType;

@end

@implementation CutVideoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

      NSBundle *bundle = [NSBundle bundleForClass:[CutVideoViewController class]];
      NSString *path = [bundle pathForResource:@"CutResource" ofType:@"bundle"];
      NSBundle *b = [NSBundle bundleWithPath:path];
    
    if (self = [super initWithNibName:@"CutVideoViewController" bundle:b]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewBottom.constant = kTabBarBottom;
    self.backTop.constant = kStatusBarHeight + 12;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, kWindowWidth, kWindowHeight-23-kTabBarBottom);
    [self.backView.layer addSublayer:self.playerLayer];
    
    [self.player play];
    
    CGFloat totalTime = [TJMediaManager getVideoTimeWithURL:self.videoUrl];
    
    self.startTime = 0;
    self.endTime = self.maxTime > totalTime ? totalTime : self.maxTime;
     
    __weak typeof(self) weakSelf = self;
    CutVideosFrameView *cutView = [[CutVideosFrameView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 156)];
    cutView.maxTime = self.maxTime;
    cutView.minTime = self.minTime;
    cutView.player = self.player;
    [cutView setUIWithUrl:self.videoUrl];
    [cutView setTimeBlock:^(CGFloat startT, CGFloat endT) {
        weakSelf.startTime = startT;
        weakSelf.endTime = endT;
    }];
    [self.controlView addSubview:cutView];
    
    self.topViewHeight.constant = kStatusBarHeight + 82;
    //渐变色
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor, (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor];
    gradientLayer.locations = @[@0.05, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(0, 0);
    gradientLayer.frame = CGRectMake(0, 0, kWindowWidth, self.topView.frame.size.height);
    [self.topView.layer addSublayer:gradientLayer];
    
    //gio埋点
//    [StatManager statGrowingioPage:@"videoPublisherEdit" controller:self referrPageName:nil params:nil];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    });
}

- (IBAction)backAction:(UIButton *)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)enterAction:(UIButton *)sender
{
//    CGFloat s = [self fileSizeAtPath:@"/var/mobile/Media/DCIM/100APPLE/IMG_0007.MP4"];
//    NSLog(@"初始：----%f",s);
    
    [self.player pause];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject ou_showActivtyTextLoading:@"正在处理中..."];
    });

        
    TimeRange timeRange = {_startTime,_endTime-_startTime};
    
    __weak typeof(self) weakSelf = self;
    [TJMediaManager addBackgroundMiusicWithVideoUrlStr:self.videoUrl audioUrl:nil andCaptureVideoWithRange:timeRange completion:^(NSString *strPath,AVAssetExportSession *assetExportSession) {
        NSLog(@"error==%@,strPath=%@",assetExportSession.error,strPath);
        
        if (assetExportSession.status == AVAssetExportSessionStatusCompleted)
        {
            NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:strPath];
            NSURL *url = [NSURL fileURLWithPath:exportPath];
            self.originPath = exportPath;
            CGFloat m = [weakSelf fileSizeAtPath:exportPath];
            NSLog(@"video 容量 %f", m/1024/1024);
            self.originSize = m;
            [weakSelf compressVideoWithUrl:url];
            
//            if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
//            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSObject ou_showAutoTextLoading:@"裁切失败，请重试"];
            });
            
        }

    }];

    
    
}

-(void)compressVideoWithUrl:(NSURL *)url
{
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    

    NSString *strPath = [NSString stringWithFormat:@"%ld.mp4",(long)[[NSDate date] timeIntervalSince1970]];
    //创建目录
    NSString *createPath = [NSString stringWithFormat:@"%@/Video", pathDocuments];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"FileImage is exists.");
    }
    NSString *resultPath = [createPath stringByAppendingPathComponent:[NSString stringWithFormat:@"HHZ_Output_%@", strPath]];
    NSLog(@"%@",resultPath);
    
    NSURL *newUrl = [NSURL fileURLWithPath:resultPath];
    

    __weak typeof(self) weakSelf = self;
    [self compressVideo:url withOutputUrl:newUrl completed:^(AVAssetExportSessionStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (status == AVAssetExportSessionStatusCompleted)
            {
                CGFloat m = [weakSelf fileSizeAtPath:resultPath];
                NSLog(@"video output 容量 %f", m/1024/1024);
                
                [NSObject ou_hideAllLoading];
                
                //保存本地
//                    BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(resultPath);
//                    if (compatible) {
//                        UISaveVideoAtPathToSavedPhotosAlbum(resultPath,self,@selector(savedVideoPhotoImage:didFinishSavingWithError:contextInfo:),nil);
//                    }


                UIImage *img = [TJMediaManager getCoverImage:newUrl atTime:0 isKeyImage:NO maximumSize:CGSizeMake(1080, 1080)];
                
                if (weakSelf.videoBlock)
                {
                    weakSelf.videoBlock(newUrl,img,weakSelf.endTime - weakSelf.startTime);
                }
                
                [weakSelf dismissViewControllerAnimated:YES completion:nil];

                if ([[NSFileManager defaultManager] fileExistsAtPath:self.originPath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:self.originPath error:nil];
                }
            }
            else
            {
                [NSObject ou_showAutoTextLoading:@"压缩失败，请重试"];
            }
            
            
        });
        

        
    }];
    
    
    
}

/*
 压缩视频,
videoUrl:原视频地址
outUrl:输出视频地址
返回值:encoder.status
      AVAssetExportSessionStatusCompleted,成功，其他失败
*/
- (void)compressVideo:(NSURL *)videoUrl withOutputUrl:(NSURL *)outUrl completed:(void(^)(AVAssetExportSessionStatus status))exportBlock
{
    NSData * oriData = [NSData dataWithContentsOfURL:videoUrl];

    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    //获取视频尺寸
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = tracks[0];
    CGSize size = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    size = CGSizeMake(fabs(size.width), fabs(size.height));
    NSLog(@"video size %@", NSStringFromCGSize(size));
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
    AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    NSLog(@"帧率：%f，比特率：%f", assetVideoTrack.nominalFrameRate,assetVideoTrack.estimatedDataRate);
    
    CGFloat maxW = size.width;
    CGFloat maxH = size.height;
    if (fabs(size.width) > fabs(size.height)) {
        if (fabs(size.height) > 1080) {
            maxH = 1080;
            maxW = fabs(size.width) / fabs(size.height) * maxH;
        }
    } else {
        if (fabs(size.width) > 1080) {
            maxW = 1080;
            maxH = fabs(size.height) / fabs(size.width) * maxW;
        }
    }
    
    //    4000000 max_code_rate
    CGFloat bitRate = self.max_code_rate > 0 ? (self.max_code_rate * 1000) : 4000000;
    if (assetVideoTrack.estimatedDataRate < bitRate) {
        bitRate = assetVideoTrack.estimatedDataRate;
    }
    
    SDAVAssetExportSession *encoder = [[SDAVAssetExportSession alloc] initWithAsset:avAsset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = outUrl;
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @(maxW),//输出视频宽度
    AVVideoHeightKey: @(maxH),//输出视频高度
    AVVideoScalingModeKey: AVVideoScalingModeResizeAspect,
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @(bitRate),//视频尺寸*比率
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @(2),//通道数
    AVSampleRateKey: @(44100),//采样率 一般用44100
    AVEncoderBitRateKey: @(128000),//比特采样率 一般是128000
        //    AVLinearPCMBitDepthKey,  // 比特率 一般设16 32
        //    AVEncoderAudioQualityKey, // 质量
    };
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         if (encoder.status == AVAssetExportSessionStatusCompleted)
         {
             exportBlock(encoder.status);
             NSLog(@"Video export succeeded");
         }
         else if (encoder.status == AVAssetExportSessionStatusCancelled)
         {
             exportBlock(encoder.status);
             NSLog(@"Video export cancelled");
         }
         else
         {
             [self compressVideoSystemMethod:videoUrl withOutputUrl:outUrl completed:^(AVAssetExportSessionStatus status) {
                 exportBlock(status);
             }];
             NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
         }
     }];

    
}

- (void)compressVideoSystemMethod:(NSURL *)videoUrl withOutputUrl:(NSURL *)outUrl completed:(void(^)(AVAssetExportSessionStatus status))exportBlock
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];

    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = outUrl;
        NSLog(@"exportPath :%@", outUrl.absoluteString);
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{

            exportBlock([exportSession status]);

            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"转换成功%@",outUrl.absoluteString);


                    break;
                default:
                    break;
            }


        }];
    }
}

- (ResolutionType)resolutionWithWidth:(CGFloat)width {
    
    if (fabs(width - 540) < fabs(width - 720)) {
        return ResolutionType540P;
    } else if (fabs(width - 720) < fabs(width - 1080)) {
        return ResolutionType720P;
    } else if (fabs(width - 1080) < fabs(width - 1440)) {
        return ResolutionType1080P;
    } else {
        return ResolutionTypeGreater;
    }
}

- (CGFloat)caculateCompressRat
{
    CGFloat rate = self.compress_rate;
    CGFloat m = self.originSize/1024/1024;
    while (m * rate > 100) {
        rate = rate * 0.9;
    }
    return rate;
}

- (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


@end
