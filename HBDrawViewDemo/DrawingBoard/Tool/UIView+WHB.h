//
//  UIView+WHB.h
//  zhaopianbaocunfree
//
//  Created by WHB on 14-11-12.
//  Copyright (c) 2014年 WHB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WHB)
// 只会生成方法的声明, 不会生成方法的实现和成员变量
@property(nonatomic,assign) CGFloat x;
@property(nonatomic,assign) CGFloat y;


@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;

@property(nonatomic,assign) CGFloat centerX;
@property(nonatomic,assign) CGFloat centerY;

@property(nonatomic,assign) CGSize size;

@end
