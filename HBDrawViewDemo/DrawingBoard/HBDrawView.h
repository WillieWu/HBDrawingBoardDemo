//
//  HBDrawView.h
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/11.
//  Copyright © 2015年 HB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HBDrawView;

typedef NS_ENUM(NSInteger, actionOpen) {
    actionOpenAlbum,
    actionOpenCamera
};

@protocol HBDrawViewDelegate <NSObject>

- (void)drawView:(HBDrawView *)drawView action:(actionOpen)action;

@end

@interface HBDrawView : UIView

- (void)showSettingBoard;
- (void)hideSettingBoard;

/**设置背景图片***/
- (void)setDrawBoardImage:(UIImage *)image;

@property (nonatomic, weak) id<HBDrawViewDelegate>  delegate;

@end
