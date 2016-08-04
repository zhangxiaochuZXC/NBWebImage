//
//  AppInfo.m
//  11-异步下载网络图片
//
//  Created by zhangjie on 16/8/4.
//  Copyright © 2016年 zhangjie. All rights reserved.
//

#import "AppInfo.h"

@implementation AppInfo

+ (instancetype)appInfoWithDict:(NSDictionary *)dict
{
    // 创建模型对象
    AppInfo *app = [[AppInfo alloc] init];
    
    // KVC实现字典转模型
    [app setValuesForKeysWithDictionary:dict];
    
    // 返回模型对象
    return app;
}

@end
