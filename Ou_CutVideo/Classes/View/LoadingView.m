//
//  LoadingView.m
//  HHZcutvideo
//
//  Created by ouyangqi on 2019/12/6.
//  Copyright © 2019 ouyangqi. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView *showView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation LoadingView

static LoadingView *loadView = nil;

+ (instancetype)shareManager
{
    if (loadView == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            loadView = [[LoadingView alloc] init];
        });
    }
    return loadView;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setui];
    }
    return self;
}

- (void)setui
{
    self.frame = [UIScreen mainScreen].bounds;
    
    self.backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    
    self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
    self.showView.backgroundColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1];
    self.showView.center = self.backView.center;
    self.showView.layer.cornerRadius = 3;
    [self.backView addSubview:self.showView];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityView.center = CGPointMake(100, 40);
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.showView addSubview:self.activityView];
    
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    self.textLabel.center = CGPointMake(100, 90);
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.showView addSubview:self.textLabel];
    
}

- (void)onlyText:(NSString *)text
{
    self.activityView.hidden = YES;
    CGFloat width = [text boundingRectWithSize:CGSizeMake(999, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size.width;
    self.showView.frame = CGRectMake(0, 0, width + 80, 50);
    self.showView.center = self.backView.center;
    self.textLabel.text = text;
    self.textLabel.center = CGPointMake(self.showView.frame.size.width/2.0, self.showView.frame.size.height/2.0);
    [UIView animateWithDuration:0.5 animations:^{
        self.showView.alpha = 1;
    }];

}

- (void)activityText:(NSString *)text
{
    self.activityView.hidden = NO;
    self.showView.frame = CGRectMake(0, 0, 200, 120);
    self.showView.center = self.backView.center;
    self.textLabel.text = text;
    self.textLabel.frame = CGRectMake(0, 0, 200, 20);
    self.textLabel.center = CGPointMake(100, 90);
}

- (void)stopAnimation
{
    [self.activityView stopAnimating];
}

- (void)startAnimation
{
    [self.activityView startAnimating];
}


@end
