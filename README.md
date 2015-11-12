# HBDrawingBoardDemo
画板 涂鸦 Demo
## 画板（涂鸦）实现
---
### 需求
* 更换`画布背景`（获取 **拍照** 或者 **相册** 的图像）
* 具有`拍照` `截屏`保存功能
* 不同的`画笔颜色，线宽`
* 具有`撤销` `返回` `清屏` `擦除`功能

### 思路
主要分三大块

* 背景
* 画布
* 画笔的功能界面

1.首先获取用户触摸事件`开始`

```
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
```
`HBPath`封装的`NSObject`对象

`paths`：装有`HBPath`对象

```
#pragma mark - HBPath
@interface HBPath : NSObject

@property (nonatomic, strong) UIColor *pathColor;//画笔颜色
@property (nonatomic, assign) BOOL isEraser;//橡皮擦

+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth;//初始化对象
- (void)pathLineToPoint:(CGPoint)movePoint;//画线
- (void)drawPath;//绘制
@end

```
2.`移动`

```
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

```
3.`结束`

```
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

```
>***其中***`HBDrawModel`***对象的作用是：操作结束后传递给外界操作的参数*** 

拥有以下属性：

```
/**所有点的集合***/
@property (nonatomic, strong) NSArray * pointList;
/**画笔的颜色***/
@property (nonatomic, copy) NSString * paintColor;
/**背景图片***/
@property (nonatomic, copy) NSString * background;
/**动作 （返回 前进 画 改变背景 清屏）默认是 Action_playing ***/
@property (nonatomic, copy) NSString * action;
/**画笔大小***/
@property (nonatomic, strong) NSNumber * paintSize;
/**设备分辨率 宽***/
@property (nonatomic, strong) NSNumber * width;
/**设备分辨率 高***/
@property (nonatomic, strong) NSNumber * hight;
/**是不是橡皮擦***/
@property (nonatomic, strong) NSNumber * isEraser;

```
4.`绘制`

```
- (void)drawRect:(CGRect)rect
{

    for (HBPath *path in self.paths) {
        
        [path drawPath];//对象方法
        
    }
    
}
```
>**最后强调一下关于橡皮擦的注意点！**

>**和绘制线是一样的，区别在于绘制的时候加上下面这句代码。**

```
    if (self.isEraser) 
    [self.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];


```
**真正的擦除你已经画的线，跟你画布的背景`是不是白色，或者其他颜色`没有关系！如果你的背景是图片，设置画笔的颜色与画布的颜色一致，就不会奏效了。** 

当然除了上面是使用`贝塞尔路径`绘制以外，你也可以使用上下文去实现，找准这个属性。妈妈再也不用担心橡皮擦啦~~~

>如果这个文章帮到了你，一定给我`Star`哦！

>[我的简书](http://www.jianshu.com/users/4d868865a987/latest_articles) **欢迎围观**！！
