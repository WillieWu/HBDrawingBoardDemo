//
//  HBDrawingBoard.h
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/2.
//  Copyright (c) 2015年 HB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBDrawModel.h"

typedef NS_ENUM(NSInteger, HBDrawingStatus)
{
    HBDrawingStatusBegin,//准备绘制
    HBDrawingStatusMove,//正在绘制
    HBDrawingStatusEnd//结束绘制

};

typedef NS_ENUM(NSInteger, HBDrawingShapeType)
{
    HBDrawingShapeCurve = 0,//曲线
    HBDrawingShapeLine,//直线
    HBDrawingShapeEllipse,//椭圆
    HBDrawingShapeRect,//矩形
    
};
typedef NS_ENUM(NSInteger, actionOpen) {
    actionOpenAlbum,
    actionOpenCamera
};




@class HBDrawingBoard;

@protocol HBDrawingBoardDelegate <NSObject>

- (void)drawBoard:(HBDrawingBoard *)drawView action:(actionOpen)action;
- (void)drawBoard:(HBDrawingBoard *)drawView drawingStatus:(HBDrawingStatus)drawingStatus model:(HBDrawModel *)model;

@end

@interface HBDrawingBoard : UIView

@property (nonatomic, assign) BOOL ise;

@property (nonatomic, assign) HBDrawingShapeType shapType;

@property (nonatomic, strong) UIImageView *backImage;

@property (nonatomic, weak) id<HBDrawingBoardDelegate> delegate;
/**
 *  根据点的集合绘制      
 *
 *  @param points    ["{x,y}"...]
 *  @param lineColor 颜色
 *  @param lineWidth 线宽
 *
 *  @return YES -> 绘制完成  反之
 */
- (BOOL)drawWithPoints:(HBDrawModel *)model;
- (void)showSettingBoard;
- (void)hideSettingBoard;

+ (HBDrawModel *)objectWith:(NSDictionary *)dic;
@end

#pragma mark - HBPath
@interface HBPath : NSObject

@property (nonatomic, strong) UIColor *pathColor;//画笔颜色
@property (nonatomic, assign) CGFloat lineWidth;//线宽
@property (nonatomic, assign) BOOL isEraser;//橡皮擦
@property (nonatomic, assign) HBDrawingShapeType shapType;//绘制样式
@property (nonatomic, copy) NSString *imagePath;//图片路径
@property (nonatomic, strong) UIBezierPath *bezierPath;


+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth isEraser:(BOOL)isEraser;//初始化对象
- (void)pathLineToPoint:(CGPoint)movePoint WithType:(HBDrawingShapeType)shapeType;//画

@end

@interface HBDrawView : UIView

- (void)setBrush:(HBPath *)path;

@end

