//
//  ZXCustomWindow.m
//  MosterColock
//
//  Created by wuhongbin on 15/6/25.
//  Copyright (c) 2015年 wuhongbin. All rights reserved.
//

#import "ZXCustomWindow.h"


@interface ZXCustomWindow()

@property (nonatomic, weak) UIView *animationView;

@end

@implementation ZXCustomWindow

- (instancetype)initWithAnimationView:(UIView *)animationView
{
    if (self = [super initWithFrame:[[UIScreen mainScreen] bounds]]) {
        
        self.windowLevel = UIWindowLevelAlert;
        
        self.animationView = animationView;
        
        [self addSubview:self.animationView];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"hideTopWindow" object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [self hideWithAnimationTime:self.animationTime];
            
        }];
        
    }
    return self;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    if (!CGRectContainsPoint(self.animationView.frame, touchPoint))
        [self hideWithAnimationTime:self.animationTime];

//    for (UIView *view in self.subviews) {
////        if ([view isKindOfClass:[giftInfoView class]] || [view isKindOfClass:[putView class]]) {
//            [self hideWithAnimationTime:self.animationTime];
////        }
//    }
}

- (void)showWithAnimationTime:(NSTimeInterval)second
{
    self.animationTime  = second;
    [self makeKeyAndVisible];
    
//    if (!self.hidden) return;
    [UIView animateWithDuration:self.animationTime delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.animationView.transform = CGAffineTransformMakeTranslation(0, -self.animationView.bounds.size.height);
            
        }];
       
        
    } completion:^(BOOL finished) {
        
        
        self.hidden = NO;
        
    }];
    
}

- (void)hideWithAnimationTime:(NSTimeInterval)second
{
    self.animationTime  = second;
//    if (self.hidden) return;
    
    [UIView animateWithDuration:self.animationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.animationView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
            self.hidden = YES;
            //        whblog(@"隐藏");
            
        }];
        
    } completion:^(BOOL finished) {
        
     
//        self.hidden = YES;
////        whblog(@"隐藏");
        
    }];
    
}
#pragma mark - delloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideTopWindow" object:nil];
}

@end
