//
//  NSString+ext.h
//  LoginAndRegister
//
//  Created by qian on 15/10/13.
//  Copyright © 2015年 topsci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ext)

#pragma mark - MD5
- (NSString *)md5;

#pragma mark - 判断是不是手机号
- (BOOL)isPhoneNumber;

@end
