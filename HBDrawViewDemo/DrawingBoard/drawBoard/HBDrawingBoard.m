//
//  HBDrawingBoard.m
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/2.
//  Copyright (c) 2015年 HB. All rights reserved.
//

#import "HBDrawingBoard.h"
#import "UIView+WHB.h"
#import "HBBackImageBoard.h"
#import "UIColor+help.h"
#import "HBDrawPoint.h"
#import "MJExtension.h"


@interface HBDrawingBoard()
{
    UIColor *_lastColor;
    CGFloat _lastLineWidth;
}

@property (nonatomic, strong) NSMutableArray *paths;

@property (nonatomic, copy) drawStatusBlock statusBlock;

@property (nonatomic, copy) boardImageBlock boardImage;

@property (nonatomic, strong) NSMutableArray *tempPoints;

@property (nonatomic, strong) NSMutableArray *tempPath;

@end



@implementation HBDrawingBoard

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
         __weak typeof(self) weakSelf = self;
        //接受背景图片修改的通知
        [[NSNotificationCenter defaultCenter] addObserverForName:ImageBoardNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSString *str = [note.userInfo objectForKey:@"imageBoardName"];
            weakSelf.boardBackImage = [UIImage imageNamed:str];
        }];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
//
    for (HBPath *path in self.paths) {
        
        [path drawPath];
        
    }

}
#pragma mark - Public_Methd
- (void)clearAll
{
    
    [self.layer.sublayers  makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self.paths removeAllObjects];
    
    [self setNeedsDisplay];
}
- (void)backToLastDraw
{
    HBPath *lastpath = [self.paths lastObject];
    if (lastpath)
        [self.tempPath addObject:lastpath];
    
    [self.paths removeLastObject];
    
//    [lastpath.shape removeFromSuperlayer];
    
    [self setNeedsDisplay];
    
}
- (void)regeneration
{
    HBPath *lastpath = [self.tempPath lastObject];
    if (lastpath)
        [self.paths addObject:lastpath];
    
    [self.tempPath removeLastObject];
    
//    [self.layer addSublayer:lastpath.shape];
    [self setNeedsDisplay];
    
}
- (void)eraser
{
    if (!self.ise) {
        //保存上次绘制状态
        _lastColor = self.lineColor;
        _lastLineWidth = self.lineWidth;
        
        //设置橡皮擦属性
        self.lineColor = [UIColor clearColor];
        self.ise = YES;
        
    }else{
        
        self.ise = NO;
        self.shapType = HBDrawingShapeCurve;
        self.lineColor = _lastColor;
        self.lineWidth = _lastLineWidth;
        
    }

}
- (void)saveCurrentImageToAlbum
{
    CGSize screen_size = [UIScreen mainScreen].bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(screen_size.width * [UIScreen mainScreen].scale, screen_size.height * [UIScreen mainScreen].scale), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.superview.layer renderInContext:context];
    
    UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(getImage, nil, nil, nil);
    
}

- (void)drawingStatus:(drawStatusBlock)stautsBlock
{
    self.statusBlock = stautsBlock;
}
- (BOOL)drawWithPoints:(HBDrawModel *)model
{

    self.userInteractionEnabled = NO;
    
    //比值
    CGFloat xPix = ([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale);
    CGFloat yPix = ([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale);
    CGFloat xp = model.width.floatValue / xPix;
    CGFloat yp = model.hight.floatValue / yPix;
    
    HBDrawPoint *point = [model.pointList firstObject];
    
    HBPath *path = [HBPath pathToPoint:CGPointMake(point.x.floatValue * xp , point.y.floatValue * yp) pathWidth:model.paintSize.floatValue isEraser:self.ise];
    path.pathColor = [UIColor colorWithHexString:model.paintColor];
    path.isEraser = model.isEraser.boolValue;
    
    NSMutableArray *marray = [model.pointList mutableCopy];
    [marray removeObjectAtIndex:0];
    
    [self.paths addObject:path];
    
    [marray enumerateObjectsUsingBlock:^(HBDrawPoint *point, NSUInteger idx, BOOL *stop) {
        
        [path pathLineToPoint:CGPointMake(point.x.floatValue * xp , point.y.floatValue * yp) WithType:self.shapType];
        
        [self setNeedsDisplay];
        
    }];
    
    self.userInteractionEnabled = YES;
    return YES;
}
+ (HBDrawModel *)objectWith:(NSDictionary *)dic
{
    return [HBDrawModel objectWithKeyValues:dic];
}
- (void)getChangeBoardImage:(boardImageBlock)boardImage
{
    self.boardImage = boardImage;
}
#pragma mark - CustomMethd
- (CGPoint)getTouchSet:(NSSet *)touches{
    
    UITouch *touch = [touches anyObject];
     return [touch locationInView:self];

}
#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    CGPoint point = [self getTouchSet:touches];

    HBPath *path = [HBPath pathToPoint:point pathWidth:self.lineWidth isEraser:self.ise];

    path.shape.strokeColor = self.lineColor.CGColor;

    path.pathColor = self.lineColor;
    
    [self.paths addObject:path];
    
    [self.tempPoints addObject:[HBDrawPoint drawPoint:point]];
    
//    if (self.ise) {
        [self setNeedsDisplay];
//    }else{
//            [self.layer addSublayer:path.shape];
//    }

    if (self.statusBlock) {
        self.statusBlock(HBDrawingStatusMove,nil);
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

    CGPoint point = [self getTouchSet:touches];

    HBPath *path = [self.paths lastObject];
    
    [path pathLineToPoint:point WithType:self.shapType];
    
    if (self.shapType == HBDrawingShapeCurve) {
        [self.tempPoints addObject:[HBDrawPoint drawPoint:point]];
    }
    if (self.shapType == HBDrawingShapeLine || ((self.shapType == HBDrawingShapeRect)||((self.shapType == HBDrawingShapeEllipse) && !(self.tempPoints.count == 1)))) {
        [self.tempPoints removeLastObject];
    }
    
    [self setNeedsDisplay];

    [self.tempPoints addObject:[HBDrawPoint drawPoint:point]];
    
    if (self.statusBlock) {
        self.statusBlock(HBDrawingStatusMove,nil);
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];

    CGPoint point = [self getTouchSet:touches];
    
    [self.tempPoints addObject:[HBDrawPoint drawPoint:point]];
    
    HBDrawModel *model = [[HBDrawModel alloc] init];
    model.paintColor = [self.lineColor toColorString];
    model.paintSize = @(self.lineWidth);
    model.isEraser = [NSNumber numberWithBool:self.ise];
    model.pointList = self.tempPoints;
    model.shapType = [NSNumber numberWithInteger:self.shapType];
    
    if (self.statusBlock) {
        self.statusBlock(HBDrawingStatusEnd,model);
    }
    //清空
    [self.tempPoints removeAllObjects];

}

#pragma mark - Lazying
- (NSMutableArray *)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}
- (NSMutableArray *)tempPoints
{
    if (!_tempPoints) {
        _tempPoints = [NSMutableArray array];
    }
    return _tempPoints;
}
- (NSMutableArray *)tempPath
{
    if (!_tempPath) {
        _tempPath = [NSMutableArray array];
    }
    return _tempPath;
}
- (void)setShapType:(HBDrawingShapeType)shapType
{
    if (self.ise) {
        return;
    }
    _shapType = shapType;
}

- (void)setBoardBackImage:(UIImage *)boardBackImage
{
    _boardBackImage = boardBackImage;
    
    if (self.boardImage) {
        self.boardImage(boardBackImage);
    }
    
}
- (void)setLineColor:(UIColor *)lineColor
{
    if (self.ise) {
        
        _lastColor = lineColor;
        
        return;
    }
    
    _lineColor = lineColor;
}
- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    _lastLineWidth = lineWidth;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ImageBoardNotification object:nil];
}
@end

#pragma mark - HBPath
@interface HBPath()

@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat pathWidth;

@end

@implementation HBPath


+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth isEraser:(BOOL)isEraser
{
    HBPath *path = [[HBPath alloc] init];
    path.beginPoint = beginPoint;
    path.pathWidth = pathWidth;
    path.isEraser = isEraser;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = pathWidth;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    [bezierPath moveToPoint:beginPoint];
    path.bezierPath = bezierPath;
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = pathWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.path = bezierPath.CGPath;
    path.shape = shapeLayer;
    
    
    return path;
}
//HBDrawingShapeCurve = 0,//曲线
//HBDrawingShapeLine,//直线
//HBDrawingShapeEllipse,//椭圆
//HBDrawingShapeRect,//矩形
- (void)pathLineToPoint:(CGPoint)movePoint WithType:(HBDrawingShapeType)shapeType
{
    //判断绘图类型
    _shapType = shapeType;
    switch (shapeType) {
        case HBDrawingShapeCurve:
        {
            [self.bezierPath addLineToPoint:movePoint];
            if (self.isEraser) [self.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
        }
            break;
        case HBDrawingShapeLine:
        {
            self.bezierPath = [UIBezierPath bezierPath];
            self.bezierPath.lineCapStyle = kCGLineCapRound;
            self.bezierPath.lineJoinStyle = kCGLineJoinRound;
            self.bezierPath.lineWidth = self.pathWidth;
            [self.bezierPath moveToPoint:self.beginPoint];
            [self.bezierPath addLineToPoint:movePoint];
        }
            break;
        case HBDrawingShapeEllipse:
        {
            self.bezierPath = [UIBezierPath bezierPathWithRect:[self getRectWithStartPoint:self.beginPoint endPoint:movePoint]];
            self.bezierPath.lineCapStyle = kCGLineCapRound;
            self.bezierPath.lineJoinStyle = kCGLineJoinRound;
            self.bezierPath.lineWidth = self.pathWidth;
        }
            break;
        case HBDrawingShapeRect:
        {
            self.bezierPath = [UIBezierPath bezierPathWithOvalInRect:[self getRectWithStartPoint:self.beginPoint endPoint:movePoint]];
            self.bezierPath.lineCapStyle = kCGLineCapRound;
            self.bezierPath.lineJoinStyle = kCGLineJoinRound;
            self.bezierPath.lineWidth = self.pathWidth;
        }
            break;
        default:
            break;
    }
    self.shape.path = self.bezierPath.CGPath;
}
- (void)drawPath
{
    [self.pathColor set];
    if (self.isEraser) [self.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
    [self.bezierPath stroke];
}

- (CGRect)getRectWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGPoint orignal = startPoint;
    if (startPoint.x > endPoint.x) {
        orignal = endPoint;
    }
    CGFloat width = fabs(startPoint.x - endPoint.x);
    CGFloat height = fabs(startPoint.y - endPoint.y);
    return CGRectMake(orignal.x , orignal.y , width, height);
}

@end
