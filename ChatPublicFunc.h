//
//  ChatPublicFunc.h
//  LoginAndRegister
//
//  Created by qian on 15/9/21.
//  Copyright (c) 2015年 topsci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSString+ext.h"

@interface ChatPublicFunc : NSObject

+ (NSString *)chatTime: (NSString *)strDateTime;

#pragma mark 返回当前日期时间字符串
+ (NSString*)currentDateTime;

#pragma MARK - 获取userID
+ (NSString *)userId;

#pragma mark - 判断图片格式
+ (NSString *)typeForImageData:(NSData *)data;

#pragma mark - 发送消息时播放声音
-(void)playSoundSendMessage;

#pragma mark - 图片本地缓存
+(NSString*)saveImg:(NSString *)imageName subPath:(NSString *)subPath imageObject:(UIImage *)imageObject;

#pragma mark - 获取图片的缩略图
+(UIImage *)generatePhotoThumbnail:(UIImage *)image;

#pragma mark - 在获取图片时，根据图片原有的角度来获取
+ (UIImage *)fixOrientation:(UIImage *)aImage;

#pragma mark - 根据通话时间duration获取格式化的通话时长
+(NSString *)getCallTimeWithSecond:(long)callTime;

#pragma mark - 清空所有聊天消息的本地缓存
+(void)deleteLocalChatMessageCache;

/**
 * 删除userId对应的聊天室的缓存消息缓存
 */
+(void)deleteChatRoomMessageCache:(NSString *)userId;

+(NSMutableDictionary *)getTextMessageWith:(NSString *)text;

@end
