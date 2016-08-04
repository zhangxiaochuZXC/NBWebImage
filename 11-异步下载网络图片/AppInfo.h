//
//  AppInfo.h
//  11-异步下载网络图片
//
//  Created by zhangjie on 16/8/4.
//  Copyright © 2016年 zhangjie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject

/// name
@property (nonatomic,copy) NSString *name;
/// download
@property (nonatomic,copy) NSString *download;
/// icon
@property (nonatomic,copy) NSString *icon;

/**
 *  供外界快速实现字典转模型的方法
 *
 *  @param dict 传入转模型的字典
 *
 *  @return 返回一个模型对象
 */
+ (instancetype)appInfoWithDict:(NSDictionary *)dict;

@end
