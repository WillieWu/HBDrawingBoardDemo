//
//  HBDrawPoint.m
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/9.
//  Copyright © 2015年 HB. All rights reserved.
//

#import "HBDrawPoint.h"


@implementation HBDrawPoint
+ (instancetype)drawPoint:(CGPoint)point
{
    HBDrawPoint *drawPoint = [[HBDrawPoint alloc] init];
    drawPoint.x = @(point.x);
    drawPoint.y = @(point.y);
    return drawPoint;
}

@end
