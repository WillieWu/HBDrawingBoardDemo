//
//  HBDrawSettingBoard.m
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/4.
//  Copyright © 2015年 HB. All rights reserved.
//

#import "HBDrawSettingBoard.h"
#import "UIView+WHB.h"
#import "MJExtension.h"
#import "HBBallColorModel.h"
#import "HBBackImageBoard.h"
#import "UIColor+help.h"

static NSString * const collectionCellID = @"collectionCellID";

@interface HBDrawSettingBoard()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSIndexPath *_lastIndexPath;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionImageBoardView;
@property (weak, nonatomic) IBOutlet HBColorBall *ballView;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *colorSelectModels;
@property (weak, nonatomic) IBOutlet UIButton *pickImageButton;
@property (weak, nonatomic) IBOutlet HBBackImageBoard *backImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomViewH;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (nonatomic, copy) boardSettingBlock stype;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@end


@implementation HBDrawSettingBoard

- (void)awakeFromNib
{
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.pickImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.collectionImageBoardView.backgroundColor = self.backImageView.backgroundColor;
    
    [self.collectionImageBoardView registerNib:[UINib nibWithNibName:@"BackImageBoardCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CollectionImageBoardViewID];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellID];
    
    self.backImageView.collectionView = self.collectionImageBoardView;
    
    self.backImageView.hidden = YES;
    self.centerView.hidden = self.collectionView.hidden = NO;
    

}
- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat normalW = self.width * 0.25;
    
    UIButton *btn = [self.buttomView.subviews firstObject];
    
    self.buttomViewH.constant = normalW * btn.currentImage.size.height / btn.currentImage.size.width;
    
    if (!_lastIndexPath){
        //设置默认是属性
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        self.ballView.ballSize = 0;
    }

}
- (void)getSettingType:(boardSettingBlock)type
{
    self.stype = type;
}
- (CGFloat)getLineWidth
{
    return self.ballView.lineWidth;
}
- (UIColor *)getLineColor
{
    return self.ballView.ballColor;
}
- (IBAction)penSetting:(id)sender {
    
    self.backImageView.hidden = YES;
    self.centerView.hidden = self.collectionView.hidden = NO;
    
    if (self.stype) {
        self.stype(setTypePen);
    }
}
- (IBAction)openCamera:(id)sender {
    
    if (self.stype) {
        self.stype(setTypeCamera);
    }
}
- (IBAction)openAlbum:(UIButton *)sender {
    
    
    self.backImageView.hidden = NO;
    self.centerView.hidden = self.collectionView.hidden = YES;

    if (sender.tag) return;
    
    if (self.stype) {
        self.stype(setTypeAlbum);
    }
    
}
- (IBAction)saveImage:(id)sender {
    
    if (self.stype) {
        self.stype(setTypeSave);
    }
}
- (IBAction)eraser:(id)sender {
   
    if (self.stype) {
        self.stype(setTypeEraser);
    }
}
- (IBAction)back:(id)sender {
    
    if (self.stype) {
        self.stype(setTypeBack);
    }
}
- (IBAction)revocation:(id)sender {
    
    if (self.stype) {
        self.stype(setTyperegeneration);
    }
}
- (IBAction)clearAll:(id)sender {
    
    if (self.stype) {
        self.stype(setTypeClearAll);
    }
}
- (IBAction)sliderView:(UISlider *)sender {
    
    self.ballView.ballSize = sender.value;
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colorSelectModels.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    HBBallColorModel *model = self.colorSelectModels[indexPath.item];
    cell.backgroundColor = [UIColor colorWithHexString:self.colors[[model.ballColor integerValue]]];
    cell.layer.cornerRadius = 3;
    if (model.isBallColor) {
        cell.layer.borderWidth = 3;
        cell.layer.borderColor = [UIColor purpleColor].CGColor;
    }else{
        cell.layer.borderWidth = 0;
    }
    cell.layer.masksToBounds = YES;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_lastIndexPath) {
         HBBallColorModel *lastModel = self.colorSelectModels[_lastIndexPath.item];
        lastModel.isBallColor = NO;
        [self.collectionView reloadItemsAtIndexPaths:@[_lastIndexPath]];
    }
    _lastIndexPath = indexPath;
    
    HBBallColorModel *model = self.colorSelectModels[indexPath.item];
    self.ballView.ballColor = [UIColor colorWithHexString:self.colors[[model.ballColor integerValue]]];;
    model.isBallColor = YES;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - lazy
- (NSArray *)colorSelectModels
{
/*
 ed4040 237 64 64
 f5973c 245 151 60
 efe82e 239 232 46
 7ce331 124 227 49
 48dcde 72 220 222
 2877e3 40 119 227
 9b33e4 155 51 228
 */
    if (!_colorSelectModels) {
//        isBallColor
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@(0),@"ballColor", nil];
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:@(1),@"ballColor", nil];
        NSDictionary *dic3 = [NSDictionary dictionaryWithObjectsAndKeys:@(2),@"ballColor", nil];
        NSDictionary *dic4 = [NSDictionary dictionaryWithObjectsAndKeys:@(3),@"ballColor", nil];
        NSDictionary *dic5 = [NSDictionary dictionaryWithObjectsAndKeys:@(4),@"ballColor", nil];
        NSDictionary *dic6 = [NSDictionary dictionaryWithObjectsAndKeys:@(5),@"ballColor", nil];
        NSDictionary *dic7 = [NSDictionary dictionaryWithObjectsAndKeys:@(6),@"ballColor", nil];
        NSArray *array = [NSArray arrayWithObjects:dic1,
                                            dic2,
                                            dic3,
                                            dic4,
                                            dic5,
                                            dic6,
                                            dic7,
                                            nil];
        _colorSelectModels = [HBBallColorModel objectArrayWithKeyValuesArray:array];
    }
    return _colorSelectModels;
}
- (NSArray *)colors
{
    if (!_colors) {
        _colors = [NSArray arrayWithObjects:@"#ed4040",
                                            @"#f5973c",
                                            @"#efe82e",
                                            @"#7ce331",
                                            @"#48dcde",
                                            @"#2877e3",
                                            @"#9b33e4",
                                            nil];
    }
    return _colors;
}
@end


@interface HBColorBall()
@property (nonatomic, strong) CAShapeLayer *shape;
@end

@implementation HBColorBall

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self.layer addSublayer:self.shape];

}
/*
    1 3 5 7
 */

- (void)setBallColor:(UIColor *)ballColor
{
    _ballColor = ballColor;
    
    self.shape.fillColor = self.ballColor.CGColor;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SendColorAndWidthNotification object:nil];
}
- (void)setBallSize:(CGFloat)ballSize
{
    _ballSize = ballSize;
    
    //缩放
    CGFloat vaule = 0.3 * (1 - ballSize) + ballSize;
    self.transform = CGAffineTransformMakeScale(vaule, vaule);
    
    NSLog(@"画笔宽度:%.f",self.width / 2.0);
    
    self.lineWidth = self.width / 2.0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SendColorAndWidthNotification object:nil];
}
- (CAShapeLayer *)shape
{
    if (!_shape) {
        _shape = [[CAShapeLayer alloc] init];
        _shape.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
    }
    return _shape;
}
@end
