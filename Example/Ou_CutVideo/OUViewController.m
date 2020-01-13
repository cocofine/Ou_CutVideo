//
//  OUViewController.m
//  Ou_CutVideo
//
//  Created by 1096438749@qq.com on 01/11/2020.
//  Copyright (c) 2020 1096438749@qq.com. All rights reserved.
//

#import "OUViewController.h"
#import "CutVideoViewController.h"

@interface OUViewController ()

@end

@implementation OUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"53e7565f3d8f43ff90caefee493c399d-25e594092d7b29a285dd6b1dc396d875-sd" ofType:@"mp4"];
    NSURL  *movieURL = [NSURL fileURLWithPath:path];
    
    CutVideoViewController *vc = [[CutVideoViewController alloc] init];
    vc.videoUrl = movieURL;
    vc.maxTime = 60;
    vc.minTime = 6;
    vc.compress_min_size = 1024;
    vc.videoBlock = ^(NSURL * _Nonnull newVideoUrl, UIImage * _Nonnull newImg, CGFloat newTotalTime) {
        
    };
    
    [self presentViewController:vc animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
