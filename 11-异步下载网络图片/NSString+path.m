//
//  NSString+path.m
//  11-异步下载网络图片
//
//  Created by zhangjie on 16/8/4.
//  Copyright © 2016年 zhangjie. All rights reserved.
//

#import "NSString+path.h"

@implementation NSString (path)

- (NSString *)appendCache
{
    // 获取cache文件路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    // 从图片地址里面获取图片名
    NSString *fileName = [self lastPathComponent];
    
    // 拼接缓存路径
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    return filePath;
}

@end
