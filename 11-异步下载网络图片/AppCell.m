//
//  AppCell.m
//  11-异步下载网络图片
//
//  Created by zhangjie on 16/8/4.
//  Copyright © 2016年 zhangjie. All rights reserved.
//

#import "AppCell.h"
#import "UIImageView+WebCache.h"

@implementation AppCell

- (void)setApp:(AppInfo *)app
{
    _nameLabel.text = app.name;
    _downloadLabel.text = app.download;
    
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:app.icon]];
}

@end
