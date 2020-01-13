//
//  CutVideosFrameView.m
//  cutMovie
//
//  Created by ouyangqi on 2019/3/22.
//  Copyright © 2019年 ouyangqi. All rights reserved.
//

#import "CutVideosFrameView.h"
#import "TJMediaManager.h"
#import "CutViewCell.h"
#import "CutVideoViewController.h"
#import "UIView+ClickEdgeInsets.h"
//#import "PhotoTool.h"
//#import "UIView+ClickEdgeInsets.h"

#define kControlViewInitLargin  37
#define kMinTime    [Util shareUtil].commonSet.videoExtendInfo.video_min_time
//#define kMaxTime    [Util shareUtil].commonSet.videoExtendInfo.video_max_time
#define kMinImgCount    10
#define kImgWidth   (self.frame.size.width - 47 * 2 - (kMinImgCount -1)) / kMinImgCount
#define kMaxLength  (self.frame.size.width - kControlViewInitLargin*2 - 20)

@interface CutVideosFrameView () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *leftControlView;
@property (weak, nonatomic) IBOutlet UIView *rightControlView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewRight;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic,assign) CGFloat startTime;
@property (nonatomic,assign) CGFloat endTime;
@property (nonatomic,assign) CGFloat totalTime;
@property (nonatomic,assign) CGFloat starDistant;
@property (nonatomic,assign) CGFloat minLength;

@property (nonatomic, strong) id playTimeObserver;

@property (weak, nonatomic) IBOutlet UIImageView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;


@end

@implementation CutVideosFrameView

- (void)dealloc {

    [self.player removeTimeObserver:_playTimeObserver]; // 移除playTimeObserver
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[CutVideosFrameView class]];
        NSString *path = [bundle pathForResource:@"CutResource" ofType:@"bundle"];
        NSBundle *b = [NSBundle bundleWithPath:path];
        
        UIView *view = [[b loadNibNamed:@"CutVideosFrameView" owner:self options:nil] firstObject];
        
        [self addSubview:view];
        view.frame = self.bounds;

        [self setInitData];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
      
        NSBundle *bundle = [NSBundle bundleForClass:[CutVideosFrameView class]];
        NSString *path = [bundle pathForResource:@"CutResource" ofType:@"bundle"];
        NSBundle *b = [NSBundle bundleWithPath:path];
        
        UIView *view = [[b loadNibNamed:@"CutVideosFrameView" owner:self options:nil] firstObject];
        
        [self addSubview:view];
        view.frame = self.bounds;
        

        [self setInitData];
    }
    return self;
}

-(void)setInitData
{
    NSBundle *bundle = [NSBundle bundleForClass:[CutVideosFrameView class]];
    NSString *path = [bundle pathForResource:@"CutResource" ofType:@"bundle"];
    NSBundle *b = [NSBundle bundleWithPath:path];
    
    //渐变色
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor, (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor];
    gradientLayer.locations = @[@0.05, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.frame = CGRectMake(0, 0, kWindowWidth, self.backView.frame.size.height);
    [self.backView.layer addSublayer:gradientLayer];
    
    NSString *name;
    if ([UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width > 2.0) {
        name = [NSString stringWithFormat:@"icon_video_bg@2x"];
        
    } else {
        name = [NSString stringWithFormat:@"icon_video_bg@3x"];
        
    }
    
    UIImage *img = [UIImage imageWithContentsOfFile:[b pathForResource:name ofType:@"png"]];
    CGFloat imageHeight = img.size.height;

    UIImage *resizableImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(imageHeight * 0.5,  20, imageHeight * 0.5, 20) resizingMode:UIImageResizingModeStretch];


    self.backImgView.image = resizableImage;
    
    
    
    
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    
    
    self.leftControlView.clickEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.rightControlView.clickEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    
    UIPanGestureRecognizer *leftTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapAction:)];
    [self.leftControlView addGestureRecognizer:leftTap];
    
    UIPanGestureRecognizer *rightTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapAction:)];
    [self.rightControlView addGestureRecognizer:rightTap];
    
    
    
    UINib *nib = [UINib nibWithNibName:@"CutViewCell" bundle:b];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"123"];
}


-(void)setUIWithUrl:(NSURL *)videoUrl
{
    _videoUrl = videoUrl;
    
    self.tipTimeLabel.text = [NSString stringWithFormat:@"支持%ld秒以内的视频，请编辑后上传",(NSInteger)self.maxTime];
    
    self.totalTime = [TJMediaManager getVideoTimeWithURL:videoUrl];
    
    NSInteger count = self.totalTime > self.maxTime ? self.totalTime/(self.maxTime/kMinImgCount) : kMinImgCount;
    
    dispatch_queue_t queue = dispatch_queue_create("video", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i<count; i++)
        {
            @autoreleasepool {
                UIImage *img = self.totalTime > self.maxTime ? [TJMediaManager getCoverImage:videoUrl atTime:i * (self.maxTime/kMinImgCount) isKeyImage:NO maximumSize:CGSizeMake(100, 100)] : [TJMediaManager getCoverImage:videoUrl atTime:i*self.totalTime/kMinImgCount isKeyImage:NO maximumSize:CGSizeMake(100, 100)];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (img)
                    {
                        [self.dataArray addObject:img];
                    }
                    else
                    {
                        NSBundle *bundle = [NSBundle bundleForClass:[CutVideosFrameView class]];
                        NSString *path = [bundle pathForResource:@"CutResource" ofType:@"bundle"];
                        NSBundle *b = [NSBundle bundleWithPath:path];
                        [self.dataArray addObject:[UIImage imageWithContentsOfFile:[b pathForResource:@"select_image_blur@3x" ofType:@"png"]]];
                        
                    }
                    if (self.dataArray.count>0)
                    {
                        NSArray *array = @[[NSIndexPath indexPathForItem:self.dataArray.count - 1 inSection:0]];
                        if (array.count>0)
                        {
                            [self.collectionView insertItemsAtIndexPaths:array];
                        }
                    }
                   
                    
                });
            }
        }
    });
    

    
    if (self.totalTime > self.maxTime)
    {
        self.minLength = kMaxLength * self.minTime /self.maxTime;
        self.startTime = 0;
        self.endTime = self.maxTime;
        
        self.currentTimeLabel.text = [NSString stringWithFormat:@"已选视频时长 %@",[self timeStringWithDuration:self.maxTime]];
    }
    else
    {
        self.minLength = kMaxLength * self.minTime / self.totalTime;
        self.startTime = 0;
        self.endTime = self.totalTime;

        self.currentTimeLabel.text = [NSString stringWithFormat:@"已选视频时长 %@",[self timeStringWithDuration:self.totalTime]];
    }
    
    [self.collectionView reloadData];
    
//---------------
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    //控制进度条
    __weak typeof(self) weakSelf = self;
    self.playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        //视频的总时间
        NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.asset.duration);

        if (currentTime >= weakSelf.endTime - 0.01)
        {
            [weakSelf playbackFinished];
        }

        [weakSelf moveProgressViewTotalTime:totalTime Current:currentTime];
        
    }];

}

-(void)moveProgressViewTotalTime:(NSTimeInterval)totalTime Current:(NSTimeInterval)currentTime
{
    if (totalTime > self.maxTime)
    {
        self.progressCenter.constant = kMaxLength / self.maxTime * (currentTime - self.startTime) + 10;
    }
    else
    {
        self.progressCenter.constant = (currentTime - self.startTime)/totalTime * kMaxLength + 10;
    }
    
    [self layoutIfNeeded];
}

#pragma mark - Delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CutViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"123" forIndexPath:indexPath];
    cell.imgView.image = self.dataArray[indexPath.row];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kImgWidth, 50);
}

-(void)leftTapAction:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture translationInView:self];
    
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.starDistant = self.imgViewLeft.constant;
        self.progressView.hidden = YES;
        [self.player pause];
    }
    
    self.imgViewLeft.constant = point.x + self.starDistant;
    
    if (self.imgViewLeft.constant <= kControlViewInitLargin)
    {
        self.imgViewLeft.constant = kControlViewInitLargin;
    }
    else if (self.imgViewLeft.constant >= self.frame.size.width - self.imgViewRight.constant - 20  - self.minLength)
    {
        self.imgViewLeft.constant = self.frame.size.width - self.imgViewRight.constant - 20  - self.minLength;
    }
    
    
    //    NSLog(@"%f",self.leftConstraint.constant);
    //    NSLog(@"point = %@",NSStringFromCGPoint(ps));
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {

        [self caculateStartAndEndTime];
        [self jumpTotime:self.startTime];
    }
}

-(void)rightTapAction:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture translationInView:self];
    
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.starDistant = self.imgViewRight.constant;
        self.progressView.hidden = YES;
        [self.player pause];
    }
    
    self.imgViewRight.constant =  -point.x + self.starDistant;
    
    if (self.imgViewRight.constant <= kControlViewInitLargin)
    {
        self.imgViewRight.constant = kControlViewInitLargin;
    }
    else if (self.imgViewRight.constant >= self.frame.size.width - self.imgViewLeft.constant - 20 - self.minLength)
    {
        self.imgViewRight.constant = self.frame.size.width - self.imgViewLeft.constant - 20  - self.minLength;
    }
    

    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {

        [self caculateStartAndEndTime];
        
        [self jumpTotime:self.startTime];
    }
}

-(void)jumpTotime:(CGFloat)time
{
    [self.player pause];
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:CMTimeMake(time * 30, 30) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.player play];
        if (weakSelf.timeBlock) {
            weakSelf.timeBlock(weakSelf.startTime, weakSelf.endTime);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.progressView.hidden = NO;
        });
    }];

    self.currentTimeLabel.text = [NSString stringWithFormat:@"已选视频时长 %@",[self timeStringWithDuration:(self.endTime - self.startTime)]];
}

-(void)playbackFinished{
    
    NSLog(@"视频播放完成.");
    // 播放完成后重复播放
    // 跳到剪切开始处
    [self.player seekToTime:CMTimeMake(self.startTime*30, 30) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
}

#pragma mark - ScrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.player pause];
    self.progressView.hidden = YES;

    [self caculateStartAndEndTime];

    [self.player seekToTime:CMTimeMake(self.startTime * 30, 30) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self jumpTotime:self.startTime];
    }
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self jumpTotime:self.startTime];
}



-(void)caculateStartAndEndTime
{

    if (self.totalTime > self.maxTime)
    {
        self.startTime =   self.maxTime / kMaxLength * (self.imgViewLeft.constant - kControlViewInitLargin + self.collectionView.contentOffset.x);
        
        self.endTime = self.maxTime - (self.imgViewRight.constant - kControlViewInitLargin - self.collectionView.contentOffset.x) * self.maxTime / kMaxLength;
    }
    else
    {
        self.startTime = self.totalTime / kMaxLength * (self.imgViewLeft.constant - kControlViewInitLargin + self.collectionView.contentOffset.x);
        
        self.endTime = self.totalTime - self.totalTime / kMaxLength * (self.imgViewRight.constant - kControlViewInitLargin - self.collectionView.contentOffset.x);
    }

    if (self.totalTime > 6.01 && self.endTime < self.totalTime - 0.01 && self.endTime - self.startTime < 6) {
        self.endTime = self.endTime + 0.01;
    }
}

- (NSString *)timeStringWithDuration:(NSTimeInterval)duration
{
    NSTimeInterval time = duration;
    int hour = (int)(time / 3600);
    int minute = (int)(time - hour * 3600) / 60;
    int second = time - hour * 3600 - minute * 60;
    
    if (hour > 0)
    {
        return [NSString stringWithFormat:@"%d:%.2d:%.2d",hour,minute,second];
    }
    else if (minute > 0)
    {
        return [NSString stringWithFormat:@"%d:%.2d",minute,second];
    }
    else
    {
        return [NSString stringWithFormat:@"0:%.2d",second];
    }
}


-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}



@end
