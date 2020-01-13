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
    self.navigationController.navigationBarHidden = YES;
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
            
            CGFloat m = [weakSelf fileSizeAtPath:exportPath];
            NSLog(@"video 容量 %f", m/1024/1024);

            [weakSelf compressVideoWithUrl:url];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
            }
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
            [NSObject ou_hideAllLoading];
            
            if (status == AVAssetExportSessionStatusCompleted)
            {
                CGFloat m = [weakSelf fileSizeAtPath:resultPath];
                NSLog(@"video output 容量 %f", m/1024/1024);

                UIImage *img = [TJMediaManager getCoverImage:newUrl atTime:0 isKeyImage:NO maximumSize:CGSizeMake(1080, 1080)];
                
                if (weakSelf.videoBlock)
                {
                    weakSelf.videoBlock(newUrl,img,weakSelf.endTime - weakSelf.startTime);
                }
                
                [weakSelf dismissViewControllerAnimated:YES completion:nil];

                
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
    if (oriData.length/1024/1024<=self.compress_min_size)
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
        
        
    }else
    {
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
        //获取视频尺寸
        NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = tracks[0];
        CGSize size = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
        size = CGSizeMake(fabs(size.width), fabs(size.height));
        CGFloat maxWidth = 960;
        CGFloat maxHeight = 540;
        
        
        if ([self caculateScaleLeftNum:size.width*9 Right:size.height*16])  //16:9
        {
            maxWidth = 960;
            maxHeight = 540;
        }
        else if ([self caculateScaleLeftNum:size.width*16 Right:size.height*9]) //9:16
        {
            maxWidth = 540;
            maxHeight = 960;
        }
        else if ([self caculateScaleLeftNum:size.width*3 Right:size.height*4])  //4:3
        {
            maxWidth = 640;
            maxHeight = 480;
        }
        else if ([self caculateScaleLeftNum:size.width*4 Right:size.height*3])  //3:4
        {
            maxWidth = 480;
            maxHeight = 640;
        }
        else if(size.width/size.height<1)
        {
            maxWidth = MIN(size.width, 750);
            maxHeight = (maxWidth*size.height)/(size.width);
        }else
        {
            maxHeight = MIN(750, size.height);
            maxWidth = (maxHeight*size.width)/(size.height);
        }
        NSInteger numPixels = maxWidth * maxHeight;
        //每像素比特
        CGFloat bitsPerPixel = 6.0;//值越小，压缩越厉害，也越不清晰
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        
        SDAVAssetExportSession *encoder = [[SDAVAssetExportSession alloc] initWithAsset:avAsset];
        encoder.outputFileType = AVFileTypeMPEG4;
        encoder.outputURL = outUrl;
        encoder.videoSettings = @
        {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: @(maxWidth),//输出视频宽度
        AVVideoHeightKey: @(maxHeight),//输出视频高度
        AVVideoCompressionPropertiesKey: @
            {
            AVVideoAverageBitRateKey: @(bitsPerSecond),//视频尺寸*比率
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
             exportBlock(encoder.status);
             if (encoder.status == AVAssetExportSessionStatusCompleted)
             {
                 NSLog(@"Video export succeeded");
             }
             else if (encoder.status == AVAssetExportSessionStatusCancelled)
             {
                 NSLog(@"Video export cancelled");
             }
             else
             {
                 NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
             }
         }];
    }
    
}


-(BOOL)caculateScaleLeftNum:(double)leftnum Right:(double)rightnum
{
    if ((leftnum + 16) > rightnum && (leftnum - 16) < rightnum ) {
        return YES;
    }
    return NO;
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
