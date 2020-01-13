//
//  RatioBarView.m
//  HaoHaoZhu
//
//  Created by ouyangqi on 2018/10/31.
//  Copyright © 2018年 HaoHaoZhu. All rights reserved.
//

#import "RatioBarView.h"
#import "RatioImgModel.h"
#import "RatioCell.h"

@interface RatioBarView () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *rotateView;
@property (weak, nonatomic) IBOutlet UIView *reSetView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, strong) NSMutableArray *ratioArr;

@property (nonatomic, assign) TOCropViewControllerAspectRatioPreset currentType;

@property (nonatomic, assign) NSInteger rotateCount;

@end

@implementation RatioBarView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    NSArray *imgArr = @[@"ziyou",@"Ratio_1_1",@"Ratio_3_4",@"Ratio_4_3",@"Ratio_9_16",@"Ratio_16_9"];
    NSArray *textArr = @[@"自由",@"1:1",@"3:4",@"4:3",@"9:16",@"16:9"];
    for (NSInteger i = 0; i<imgArr.count; i++)
    {
        RatioImgModel *model = [[RatioImgModel alloc] init];
        model.text = textArr[i];
        model.imgName = imgArr[i];
        model.isSelect = NO;
        [self.ratioArr addObject:model];
    }
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UITapGestureRecognizer *rotateGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rotateAction:)];
    [self.rotateView addGestureRecognizer:rotateGesture];
    UITapGestureRecognizer *restoreGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(restoreAction:)];
    [self.reSetView addGestureRecognizer:restoreGesture];
    
    [self restoreAction:nil];
    
    NSBundle *bundle = [NSBundle bundleForClass:[RatioCell class]];
    NSString *path = [bundle pathForResource:@"Ou_CutPics" ofType:@"bundle"];
    NSBundle *b = [NSBundle bundleWithPath:path];


    UINib *nib = [UINib nibWithNibName:@"RatioCell" bundle:b];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"123"];

}

#pragma mark - collectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.ratioArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RatioImgModel *model = self.ratioArr[indexPath.row];
    
    RatioCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"123" forIndexPath:indexPath];
    cell.textLabel.text = model.text;
    cell.imgView.image = [self imageWithModel:model];
    cell.textLabel.textColor = model.isSelect ? [UIColor colorWithRed:31/255.0f green:183/255.0f blue:182/255.0f alpha:1] : [UIColor whiteColor];
    
    return cell;
}

- (UIImage *)imageWithModel:(RatioImgModel *)model
{
    NSBundle *bundle = [NSBundle bundleForClass:[RatioBarView class]];
    NSString *path = [bundle pathForResource:@"Ou_CutPics" ofType:@"bundle"];
    NSBundle *b = [NSBundle bundleWithPath:path];
    NSString *name;
    if ([UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width > 2.0) {
        name = model.isSelect ? [NSString stringWithFormat:@"%@_blue@3x",model.imgName] : [NSString stringWithFormat:@"%@@2x",model.imgName];
    } else {
        name = model.isSelect ? [NSString stringWithFormat:@"%@_blue",model.imgName] : [NSString stringWithFormat:@"%@",model.imgName];
    }
    
    
    NSString *p = [b pathForResource:name ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:p];

    return img;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(52, 60);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    for (RatioImgModel *model in self.ratioArr) {
        model.isSelect = NO;
    }
    RatioImgModel *model = self.ratioArr[indexPath.row];
    model.isSelect = YES;
    
    [self.collectionView reloadData];
    
    if (self.typeBlock)
    {
        self.typeBlock(indexPath.row);
        self.currentType = indexPath.row;
    }
    
}


- (IBAction)sureAction:(id)sender
{
    if (self.typeBlock) {
        self.typeBlock(8);
    }
}


- (IBAction)cancelAction:(id)sender
{
    if (self.typeBlock) {
        self.typeBlock(9);
    }
}

//旋转
-(void)rotateAction:(UIGestureRecognizer *)gesture
{

    if (self.typeBlock) {
        self.typeBlock(6);
        
        switch (self.currentType) {
            case TOCropViewControllerAspectRatioPreset3x4:
                [self rotateWithIndex:3];
                self.currentType = TOCropViewControllerAspectRatioPreset4x3;
                break;
            case TOCropViewControllerAspectRatioPreset4x3:
                [self rotateWithIndex:2];
                self.currentType = TOCropViewControllerAspectRatioPreset3x4;
                break;
            case TOCropViewControllerAspectRatioPreset9x16:
                [self rotateWithIndex:5];
                self.currentType = TOCropViewControllerAspectRatioPreset16x9;
                break;
            case TOCropViewControllerAspectRatioPreset16x9:
                [self rotateWithIndex:4];
                self.currentType = TOCropViewControllerAspectRatioPreset9x16;
                break;
            default:
                break;
                
        }
    }
    


}

-(void)rotateWithIndex:(NSInteger)index
{
    
    for (RatioImgModel *model in self.ratioArr) {
        model.isSelect = NO;
    }
    RatioImgModel *model = self.ratioArr[index];
    model.isSelect = YES;
    [self.collectionView reloadData];
}

//还原
-(void)restoreAction:(UIGestureRecognizer *)gesture
{

    if (self.typeBlock) {
        self.typeBlock(7);
    }
    
    for (RatioImgModel *model in self.ratioArr) {
        model.isSelect = NO;
    }
    RatioImgModel *model = self.ratioArr[0];
    model.isSelect = YES;
    [self.collectionView reloadData];
}


-(NSMutableArray *)ratioArr
{
    if (!_ratioArr) {
        _ratioArr = [NSMutableArray array];
    }
    return _ratioArr;
}



@end
