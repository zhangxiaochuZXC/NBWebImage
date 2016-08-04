//
//  NSString+path.h
//  11-异步下载网络图片
//
//  Created by zhangjie on 16/8/4.
//  Copyright © 2016年 zhangjie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (path)

/**
 *  生成cache缓存文件路径
 *
 *  @return 返回沙盒缓存路径
 */
- (NSString *)appendCache;

@end
