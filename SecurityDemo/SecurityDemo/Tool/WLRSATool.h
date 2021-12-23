//
//  WLRSATool.h
//  SecurityDemo
//
//  Created by 章子云 on 2021/10/19.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>
#import <openssl/pem.h>
#import <openssl/rsa.h>


NS_ASSUME_NONNULL_BEGIN

@interface WLRSATool : NSObject

@property (nonatomic, copy) NSString *publicKeyBase64;
@property (nonatomic, copy) NSString *privateKeyBase64;

+ (WLRSATool *)shareRSATool;

/// 后台公钥
@property (nonatomic, copy) NSString *severPublicKey;


/// 生成公私钥
- (void)generateKeyPair;

#pragma mark - 苹果api Security框架 加解密
/// 公钥加密
- (NSString *)SecRefPubcliKeyEncrypt:(NSString *)plainText;
/// 私钥解密
- (NSString *)SecRefPrivateKeyDecrypt:(NSString *)encryptString;

#pragma mark - 纯 openssl 加解密

/// 公钥加密
- (NSString *)openssl_RSAEncrypt:(NSString *)plainText;
/// 私钥解密
- (NSString *)openssl_RSADecrypt:(NSString *)encryptString;

- (RSA *)openssl_publicKeyFromBase64:(NSString *)publicKey;
- (RSA *)openssl_privateKeyFromBase64:(NSString *)privateKey;
- (RSA *)openssl_publicKeyFromPEM:(NSString *)publicKeyPEM;
- (RSA *)openssl_privateKeyFromPEM:(NSString *)privatePEM;

@end

NS_ASSUME_NONNULL_END
