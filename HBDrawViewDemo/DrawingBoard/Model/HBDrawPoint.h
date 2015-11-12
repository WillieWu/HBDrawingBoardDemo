//
//  HBDrawPoint.h
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/9.
//  Copyright © 2015年 HB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HBDrawPoint : NSObject

+ (instancetype)drawPoint:(CGPoint)point;

@property (nonatomic, strong) NSNumber * x;

@property (nonatomic, strong) NSNumber * y;

@end
