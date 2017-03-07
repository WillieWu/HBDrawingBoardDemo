//
//  NSFileManager_Helper.h
//  FirstVideo
//
//  Created by doorxp1 on 14-7-9.
//  Copyright (c) 2014年 doorxp1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSFileManager(Helper)

/**
 *  检测指定全路径的文件是否存在
 *
 *  @param  path 文件的全路径
 *  @return BOOL 存在还回YES,否则返回NO
 */
+ (BOOL)fileExist:(NSString *)path;

/**
 *  检测指定全路径的目录是否存在
 *
 *  @param  path 目录的全路径
 *  @return BOOL 存在还回YES,否则返回NO
 */
+ (BOOL)dirExist:(NSString *)path;

/**
 *  创建目录
 *
 *  @param  path 指定目录路径
 *  @return BOOL 成功返回YES
 */
+ (BOOL)mkDir:(NSString *)path;

/**
 *  移动指定路径的文件到另一个路径
 *
 *  @param  from 移动源路径
 *  @param  to 移动目标路径
 *  @return BOOl 成功返回YES
 */
+ (BOOL)move:(NSString *)from to:(NSString *)to;

/**
 *  复制指定路径的文件到另一个路径
 *
 *  @param  from 复制源路径
 *  @param  to 复制目标路径
 *  @return BOOl 成功返回YES
 */
+ (BOOL)copy:(NSString *)from to:(NSString *)to;

/**
 *  删除指定文件
 *
 *  @param  path 指定待删除文件路径
 *  @return BOOL 成功返回YES
 */
+ (BOOL)deleteFile:(NSString*)path;

/**
 保存文件到制定目录

 @param data 文件二进制
 @param filePath 文件路径
 @return 是否保存成功
 */
+ (BOOL)hb_saveData:(NSData *)data filePath:(NSString *)filePath;

/**
 获取文件二进制

 @param filePath 文件路径
 @return 二进制
 */
+ (UIImage *)hb_getImageFileName:(NSString *)filePath;
@end
