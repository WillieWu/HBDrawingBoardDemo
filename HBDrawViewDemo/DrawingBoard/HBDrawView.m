//
//  HBDrawView.m
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/11.
//  Copyright © 2015年 HB. All rights reserved.
//

#import "HBDrawView.h"
#import "HBDrawSettingBoard.h"
#import "ZXCustomWindow.h"


@interface HBDrawView ()
@property (nonatomic, strong) UIImageView *boardImage;
@property (nonatomic, strong) HBDrawingBoard *drawBoard;
@property (nonatomic, strong) HBDrawSettingBoard *settingBoard;
@property (nonatomic, strong) ZXCustomWindow *drawWindow;

@end

@implementation HBDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //1.添加背景
        [self addSubview:self.boardImage];
        //2.添加画板
        [self addSubview:self.drawBoard];
        
        __weak typeof(self) weakSelf = self;
        //接受画笔修改的通知
        [[NSNotificationCenter defaultCenter] addObserverForName:SendColorAndWidthNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            weakSelf.drawBoard.lineColor = [weakSelf.settingBoard getLineColor];
            weakSelf.drawBoard.lineWidth = [weakSelf.settingBoard getLineWidth];
            
        }];
        
    }
    return self;
}
- (void)showSettingBoard
{
    [self.drawWindow showWithAnimationTime:0.25];
}
- (void)hideSettingBoard
{
    [self.drawWindow hideWithAnimationTime:0.25];
}
- (void)setDrawBoardImage:(UIImage *)image
{
    self.boardImage.image = image;
}
/**设置画笔形状***/
- (void)setDrawBoardShapeType:(HBDrawingShapeType )shapType
{
    self.drawBoard.shapType = shapType;
}

#pragma mark - getter
- (UIImageView *)boardImage
{
    if (!_boardImage) {
        _boardImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _boardImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _boardImage;
}
- (HBDrawingBoard *)drawBoard
{
    if (!_drawBoard) {
        _drawBoard = [[HBDrawingBoard alloc] initWithFrame:self.bounds];
        
        [_drawBoard drawingStatus:^(HBDrawingStatus drawingStatus, HBDrawModel *model) {
            switch (drawingStatus) {
                case HBDrawingStatusBegin:
                    //                NSLog(@"开始");
                    break;
                case HBDrawingStatusMove:
                    //                NSLog(@"移动");
                    break;
                case HBDrawingStatusEnd:
                    NSLog(@"结束 ： %@ - %@ - %@",model.pointList,model.isEraser,model.paintColor);
                    break;
                    
                default:
                    break;
            }
        }];
        
        __block UIImageView *imageboard = self.boardImage;
        [_drawBoard getChangeBoardImage:^(UIImage *boardBackImage) {
            imageboard.image = boardBackImage;
        }];
    }
    return _drawBoard;
}
- (HBDrawSettingBoard *)settingBoard
{
    if (!_settingBoard) {
        
        _settingBoard = [[[NSBundle mainBundle] loadNibNamed:@"HBDrawSettingBoard" owner:nil options:nil] firstObject];
        _settingBoard.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 191);
        
        __weak typeof(self) weakSelf = self;
        [_settingBoard getSettingType:^(setType type) {
            
            switch (type) {
                case setTypePen:
                {
                    self.drawBoard.ise = NO;
                    self.drawBoard.lineColor = [UIColor whiteColor];
                    self.drawBoard.shapType = HBDrawingShapeCurve;
                    self.drawBoard.lineWidth = 1.5;
                }
                    break;
                case setTypeCamera:
                {
                    [self hideSettingBoard];

                    if ([self.delegate respondsToSelector:@selector(drawView:action:)]) {
                        [self.delegate drawView:self action:actionOpenCamera];
                    }
                    
                }
                    break;
                case setTypeAlbum:
                {
                    [self hideSettingBoard];
                    
                    if ([self.delegate respondsToSelector:@selector(drawView:action:)]) {
                        [self.delegate drawView:self action:actionOpenAlbum];
                    }
                }
                    break;
                case setTypeSave:
                {
                    [weakSelf.drawWindow hideWithAnimationTime:0.25];
                    [weakSelf.drawBoard saveCurrentImageToAlbum];
                }
                    break;
                case setTypeEraser:
                {
                    
                    [weakSelf.drawBoard eraser];
                    
                }
                    break;
                case setTypeBack:
                {

                    [weakSelf.drawBoard backToLastDraw];
                }
                    break;
                case setTyperegeneration:
                {

                    [weakSelf.drawBoard regeneration];
                }
                    break;
                case setTypeClearAll:
                {

                    [weakSelf.drawBoard clearAll];
                }
                    break;
                    
                default:
                    break;
            }
        }];
        
    }
    return _settingBoard;
}
- (ZXCustomWindow *)drawWindow
{
    if (!_drawWindow) {
        _drawWindow = [[ZXCustomWindow alloc] initWithAnimationView:self.settingBoard];
    }
    return _drawWindow;
}
#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SendColorAndWidthNotification object:nil];
}
@end
