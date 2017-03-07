# HBDrawingBoardDemo
## 画板（涂鸦）实现
---

![设置面板.png](http://upload-images.jianshu.io/upload_images/620797-e1ad3a155ac6ca04.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![背景.png](http://upload-images.jianshu.io/upload_images/620797-fd9af1591c471961.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##2017.3.7更新
* 不使用`drawRect`
* 内存消耗低 （把demo中XIB删除掉，内存大概在15M左右）

```
//橡皮擦
- (void)setEraseBrush:(HBPath *)path{

UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0);

[self.drawImage.image drawInRect:self.bounds];

[[UIColor clearColor] set];

path.bezierPath.lineWidth = _lineWidth;

[path.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];

[path.bezierPath stroke];

self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();

UIGraphicsEndImageContext();

}


```

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

HBPath *path = [HBPath pathToPoint:point pathWidth:_lineWidth isEraser:self.ise];

path.pathColor = _lineColor;

path.imagePath = [NSString stringWithFormat:@"%@.png",[self getTimeString]];

[self.paths addObject:path];

[self.tempPoints addObject:[HBDrawPoint drawPoint:point]];

if ([self.delegate respondsToSelector:@selector(drawBoard:drawingStatus:model:)]) {
[self.delegate drawBoard:self drawingStatus:HBDrawingStatusBegin model:nil];
}
}
```
`HBPath`封装的`NSObject`对象

`paths`：装有`HBPath`对象

```
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

```
2.`移动`

```
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

CGPoint point = [self getTouchSet:touches];

HBPath *path = [self.paths lastObject];

[path pathLineToPoint:point WithType:self.shapType];

if (self.ise) {
[self setEraseBrush:path];
}else{
[self.drawView setBrush:path];
}

[self.tempPoints addObject:[HBDrawPoint drawPoint:point]];

if ([self.delegate respondsToSelector:@selector(drawBoard:drawingStatus:model:)]) {
[self.delegate drawBoard:self drawingStatus:HBDrawingStatusMove model:nil];
}
}

```
3.`结束`

```
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
[self touchesMoved:touches withEvent:event];

HBPath *path = [self.paths lastObject];

UIImage *image = [self screenshot:self.drawImage];

self.drawImage.image = image;

[self.drawView setBrush:nil];

NSData *imageData = UIImagePNGRepresentation(image);//UIImageJPEGRepresentation(image, 0.4);

NSString *filePath = [ThumbnailPath stringByAppendingPathComponent:path.imagePath];

BOOL isSave = [NSFileManager hb_saveData:imageData filePath:filePath];

if (isSave) {

NSLog(@"%@", [NSString stringWithFormat:@"保存成功: %@",filePath]);
}
HBDrawModel *model = [[HBDrawModel alloc] init];
model.paintColor = [_lineColor toColorString];
model.paintSize = @(_lineWidth);
model.isEraser = [NSNumber numberWithBool:path.isEraser];
model.pointList = self.tempPoints;
model.shapType = [NSNumber numberWithInteger:self.shapType];

if ([self.delegate respondsToSelector:@selector(drawBoard:drawingStatus:model:)]) {
[self.delegate drawBoard:self drawingStatus:HBDrawingStatusEnd model:model];
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
- (void)setBrush:(HBPath *)path
{
CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;

shapeLayer.strokeColor = path.pathColor.CGColor;
shapeLayer.fillColor = [UIColor clearColor].CGColor;
shapeLayer.lineJoin = kCALineJoinRound;
shapeLayer.lineCap = kCALineCapRound;
shapeLayer.lineWidth = path.bezierPath.lineWidth;
((CAShapeLayer *)self.layer).path = path.bezierPath.CGPath;


}
```
>**最后强调一下关于橡皮擦的注意点！**

>**和绘制线是一样的，区别在于绘制的时候加上下面这句代码。**

~~if (self.isEraser)~~
~~[self.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];~~
更新->在最上面

**真正的擦除你已经画的线，跟你画布的背景`是不是白色，或者其他颜色`没有关系！如果你的背景是图片，设置画笔的颜色与画布的颜色一致，就不会奏效了。** 

当然除了上面是使用`贝塞尔路径`绘制以外，你也可以使用上下文去实现，找准这个属性。妈妈再也不用担心橡皮擦啦~~~

#### 问题
**当两个设备中，一端正在画，另一端绘制对方画的线。如果对方先慢画，后快画。怎么在另一端也绘制出这种速度感？？**
**如您知道的话，希望在评论中可以给我一些思路。**
####解决
在这里感谢 [@柯拉Sir](http://www.jianshu.com/users/96c00c918ccd) [@梦的森林](http://www.jianshu.com/u/ef83770663b8) 提供的思路。最新的代码已经更新，需要的朋友自取哈。

>如果这个文章帮到了你，一定给我`Star`哦！

>[GitHub](https://github.com/WillieWu/HBDrawingBoardDemo.git) **欢迎围观**！！
