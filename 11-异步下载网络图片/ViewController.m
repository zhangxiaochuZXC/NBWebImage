//
//  ViewController.m
//  11-异步下载网络图片
//
//  Created by zhangjie on 16/8/4.
//  Copyright © 2016年 zhangjie. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AppInfo.h"
#import "AppCell.h"
#import "NSString+path.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

/// 数据源数组
@property (nonatomic,strong) NSArray *dataSourceArr;
/// 全局队列
@property (nonatomic,strong) NSOperationQueue *queue;
/// 图片缓存池
@property (nonatomic,strong) NSMutableDictionary *imagesCache;
/// 下载操作缓存池
@property (nonatomic,strong) NSMutableDictionary *OPCache;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 实例化全局队列
    _queue = [[NSOperationQueue alloc] init];
    // 实例化图片缓存池
    _imagesCache = [[NSMutableDictionary alloc] init];
    // 实例化下载操作缓存池
    _OPCache = [[NSMutableDictionary alloc] init];
    
    [self loadAppInfo];
}

/// 使用AFN加载apps.json数据
- (void)loadAppInfo
{
    // 创建网络请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 发送网络请求
    [manager GET:@"https://raw.githubusercontent.com/zhangxiaochuZXC/ServerFile/master/apps.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // AFN给返回的是字典数组
//        NSLog(@"%@ %@",[responseObject class],responseObject);
        
        // 可以搞个数组接收下,也可以不接收直接使用
        NSArray *dictArr = responseObject;
        
        // 定义可变数组保存模型对象
        NSMutableArray *tmpM = [NSMutableArray array];
        
        // 遍历字典数组,实现字典转模型
        [dictArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // obj 是字典数组里面遍历出来的字典
            // 拿到字典转模型
            AppInfo *app = [AppInfo appInfoWithDict:obj];
            // 把模型对象保存到数组
            [tmpM addObject:app];
        }];
        
        // 查看结果
//        NSLog(@"%@",tmpM);
        
        // 字典转模型完成之后,把可变的模型数组赋值给数据源数组
        _dataSourceArr = tmpM.copy;
        
        // 拿到数据源数组之后,就需要刷新列表
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

#pragma 数据源方法 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArr.count;
}

/*
 NSBlockOperation异步下载网络图片
 1.当有网络延迟时,cell一旦复用,就会出现cell上图片的切换闪动;
    解决办法 : 占位图
 2.图片每次展示时都要重复下载,浪费用户流量
    解决办法 : 内存缓存(字典实现内存缓存池)
 3.当有网络延迟时,cell来回滚动会出现重复建立下载操作的问题
    解决办法 : 下载操作缓存池
 4.当有网络延迟时,cell来回滚动会出现图片错行的问题
    解决办法 : 刷新对应行
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 创建cell
    AppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell" forIndexPath:indexPath];
    
    // 获取cell对应的模型数据
    AppInfo *app = _dataSourceArr[indexPath.row];
    
    cell.nameLabel.text = app.name;
    cell.downloadLabel.text = app.download;
    
    // 在建立下载操作之前,判断图片缓冲池里面有没有要准备下载的图片
    UIImage *memoryImage = [self.imagesCache objectForKey:app.icon];
    if (memoryImage != nil) {
        NSLog(@"从内存中加载...%@",app.name);
        cell.iconImgView.image = memoryImage;
        return cell;
    }
    
    // 在建立下载操作之前,内存缓存判断之后,判断沙盒里面是否缓存的图片对象
    UIImage *cacheImage = [UIImage imageWithContentsOfFile:[app.icon appendCache]];
    if (cacheImage != nil) {
        NSLog(@"从沙盒中加载...%@",app.name);
        // 在内存中保存一份
        [self.imagesCache setObject:cacheImage forKey:app.icon];
        // 赋值给cell
        cell.iconImgView.image = cacheImage;
        // 返回cell
        return cell;
    }
    
    // 在建立下载操作之前,判断本次要下载的图片有没有在下载中
    NSBlockOperation *downloadingOP = [self.OPCache objectForKey:app.icon];
    if (downloadingOP != nil) {
        NSLog(@"正在玩儿命下载中...%@",app.name);
        return cell;
    }
    
    // 设置占位图
    cell.iconImgView.image = [UIImage imageNamed:@"user_default"];
    
    // 使用NSOperation下载图片
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"从网络中加载...%@",app.name);
        
        // 模拟网络延迟
        if (indexPath.row > 9) {
            [NSThread sleepForTimeInterval:5.0];
        }
        
        // 获取URL
        NSURL *URL = [NSURL URLWithString:app.icon];
        // 获取图片的二进制数据
        NSData *data = [NSData dataWithContentsOfURL:URL];
        // 把二进制数据转成image
        UIImage *image = [UIImage imageWithData:data];
        
        // 图片下载完成保存到图片缓存池 : 字典里面不能放空对象
        if (image != nil) {
            // 把图片保存到图片缓存池
            [self.imagesCache setObject:image forKey:app.icon];
            
            // 把图片缓存到沙盒
            [data writeToFile:[app.icon appendCache] atomically:YES];
        }
        
        // 图片下载完成之后,将对应的下载操作从缓存池里面移除
        [self.OPCache removeObjectForKey:app.icon];
        
        // 回到主线程更新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
            // 图片对象有值才刷新
            if (image != nil) {
                // 下载完一行就刷新一行
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }];
    
    // 把操作添加到操作缓存池
    [self.OPCache setObject:op forKey:app.icon];
    
    // 把操作添加到队列
    [_queue addOperation:op];
    
    // 返回cell
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%tu",_queue.operationCount);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // 移除缓存池里面的图片对象
    [self.imagesCache removeAllObjects];
    // 移除缓存池里面的下载操作
    [self.OPCache removeAllObjects];
    // 取消队列里所有的下载操作
    [self.queue cancelAllOperations];
}

@end
