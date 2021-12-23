//
//  NSString+WLHashEncryption.h
//  Demo
//
//  Created by 章子云 on 2021/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (WLHashEncryption)

#pragma mark - SHA256
- (NSString *)sha256Hash;

#pragma mark - MD5
- (NSString *)md5Hash;

#pragma mark - 转data
- (NSData *)dataFromHexString;


#pragma mark - AES加解密
- (NSString *)AES256EncryptWithKey:(NSString*)key;
- (NSString *)AES256DecryptWithKey:(NSString*)key;
- (NSString *)AESEncryptWithKey:(NSString*)key keyLength:(size_t)keyLength iv:(nullable const void *)iv;
- (NSString *)AESDecryptWithKey:(NSString*)key keyLength:(size_t)keyLength iv:(nullable const void *)iv;


#pragma mark - 获取二进制
+ (NSString *)getBinaryByHex:(NSString *)hex;

@end


@interface NSData (NSStringExtensionMethods)

/// 16进制data转成string. iOS13前使用data.description
- (NSString *)hexValueString;


@end


NS_ASSUME_NONNULL_END
