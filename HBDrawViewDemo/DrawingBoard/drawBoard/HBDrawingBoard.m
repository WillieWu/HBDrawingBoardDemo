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

static BOOL ise = NO;

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

    for (HBPath *path in self.paths) {
        
        [path drawPath];
        
    }
    
}
#pragma mark - Public_Methd
- (void)clearAll
{
    [self.paths removeAllObjects];
    
    [self setNeedsDisplay];
}
- (void)backToLastDraw
{
    if ([self.paths lastObject])
        [self.tempPath addObject:[self.paths lastObject]];
    
    [self.paths removeLastObject];
    
    [self setNeedsDisplay];
    
}
- (void)regeneration
{
    if ([self.tempPath lastObject])
        [self.paths addObject:[self.tempPath lastObject]];
    
    [self.tempPath removeLastObject];
    
    [self setNeedsDisplay];
    
}
- (void)eraser
{
    if (!ise) {
        //保存上次绘制状态
        _lastColor = self.lineColor;
        _lastLineWidth = self.lineWidth;
        
        //设置橡皮擦属性
        self.lineColor = [UIColor clearColor];
        ise = YES;
        
    }else{
        
        ise = NO;
        
        self.lineColor = _lastColor;
        self.lineWidth = _lastLineWidth;
        
    }

}
- (void)saveCurrentImageToAlbum
{

    UIGraphicsBeginImageContext(self.bounds.size);
    
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
    
    HBPath *path = [HBPath pathToPoint:CGPointMake(point.x.floatValue * xp , point.y.floatValue * yp) pathWidth:model.paintSize.floatValue];
    path.pathColor = [UIColor colorWithHexString:model.paintColor];
    path.isEraser = model.isEraser.boolValue;
    
    NSMutableArray *marray = [model.pointList mutableCopy];
    [marray removeObjectAtIndex:0];
    
    [self.paths addObject:path];
    
    [marray enumerateObjectsUsingBlock:^(HBDrawPoint *point, NSUInteger idx, BOOL *stop) {
        
        [path pathLineToPoint:CGPointMake(point.x.floatValue * xp , point.y.floatValue * yp)];
        
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
- (CGPoint)getTouchSet:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
     return [touch locationInView:self];

}

#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    CGPoint point = [self getTouchSet:touches];

    HBPath *path = [HBPath pathToPoint:point pathWidth:self.lineWidth];
    
    path.pathColor = self.lineColor;

    [self.paths addObject:path];
    
    [self.tempPoints addObject:[HBDrawPoint drawPoint:point]];
    
    [self setNeedsDisplay];
    
    if (self.statusBlock) {
        self.statusBlock(HBDrawingStatusMove,nil);
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

    CGPoint point = [self getTouchSet:touches];

    HBPath *path = [self.paths lastObject];
    
    [path pathLineToPoint:point];
    
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
    model.isEraser = [NSNumber numberWithBool:ise];
    model.pointList = self.tempPoints;
    
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
- (void)setBoardBackImage:(UIImage *)boardBackImage
{
    _boardBackImage = boardBackImage;
    
    if (self.boardImage) {
        self.boardImage(boardBackImage);
    }
    
}
- (void)setLineColor:(UIColor *)lineColor
{
    if (ise) {
        
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

@end

@implementation HBPath

+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth
{
    HBPath *path = [[HBPath alloc] init];
    path.isEraser = ise;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    bezierPath.lineWidth = pathWidth;
    [bezierPath moveToPoint:beginPoint];
    path.bezierPath = bezierPath;

    return path;
}
- (void)pathLineToPoint:(CGPoint)movePoint
{
    [self.bezierPath addLineToPoint:movePoint];

}
- (void)drawPath
{

    [self.pathColor set];
    if (self.isEraser) [self.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
    [self.bezierPath stroke];
}
@end
