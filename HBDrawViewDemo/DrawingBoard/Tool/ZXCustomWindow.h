//
//  ZXCustomWindow.h
//  MosterColock
//
//  Created by wuhongbin on 15/6/25.
//  Copyright (c) 2015年 wuhongbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXCustomWindow : UIWindow

- (instancetype)initWithAnimationView:(UIView *)animationView;

@property (nonatomic, assign) NSTimeInterval animationTime;

- (void)showWithAnimationTime:(NSTimeInterval)second;

- (void)hideWithAnimationTime:(NSTimeInterval)second;



@end
