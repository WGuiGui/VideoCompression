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

#pragma mark - 图片本地缓存
+(NSString*)saveImg:(NSString *)imageName subPath:(NSString *)subPath imageObject:(UIImage *)imageObject;

#pragma mark - 获取图片的缩略图
+(UIImage *)generatePhotoThumbnail:(UIImage *)image;

#pragma mark - 在获取图片时，根据图片原有的角度来获取
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
