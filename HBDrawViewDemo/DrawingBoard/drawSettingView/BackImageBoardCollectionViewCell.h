//
//  BackImageBoardCollectionViewCell.h
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/6.
//  Copyright © 2015年 HB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackImageBoardCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *selectImage;
@property (nonatomic, copy) NSString * imageName;

@end
