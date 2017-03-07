//
//  BackImageBoardCollectionViewCell.m
//  DemoAntiAliasing
//
//  Created by 伍宏彬 on 15/11/6.
//  Copyright © 2015年 HB. All rights reserved.
//

#import "BackImageBoardCollectionViewCell.h"

@interface BackImageBoardCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *backImage;

@end

@implementation BackImageBoardCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 3;
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.masksToBounds = YES;
    self.selectImage.hidden = YES;
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    self.backImage.image = [UIImage imageNamed:imageName];
    
}
@end
