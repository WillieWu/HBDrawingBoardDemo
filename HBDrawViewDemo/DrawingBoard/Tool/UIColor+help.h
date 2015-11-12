//
//  UIColor+help.h
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/9.
//  Copyright © 2015年 HB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (help)

+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

- (NSString *)toColorString;

@end

