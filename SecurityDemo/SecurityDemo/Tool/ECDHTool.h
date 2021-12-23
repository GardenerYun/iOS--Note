//
//  ECDHTool.h
//  ECDHUtils
//
//  Created by 章子云 on 2018/8/7.
//  Copyright © 2018年 Four_w. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/ecdh.h>
#import <CommonCrypto/CommonCrypto.h>
#import <openssl/pem.h>
#import <openssl/obj_mac.h>

typedef NS_ENUM(NSUInteger, ECDHKeyPairType) {
    ECDHKeyPairTypePrivate = 0,
    ECDHKeyPairTypePublic
};

@interface ECDHTool : NSObject


/***  本地生成的公钥 私钥*/
@property (nonatomic, copy) NSString *publicKeyBase64;
@property (nonatomic, copy) NSString *privateKeyBase64;

/***  请求的服务器公钥*/
@property (nonatomic, copy) NSString *serverPublicKeyBase64;

/***  服务器密钥标识*/
@property (nonatomic, copy) NSString *skey;

/***  App.priKey + Server.pubKey、ECDH协商出来的AES.key*/
@property (nonatomic, copy) NSString *aesKey;

@property (nonatomic, assign) BOOL successUploadClientPublicKey;



+ (ECDHTool *)sharedInstance;

/**
 *  生成ECC(椭圆曲线加密算法)的私钥和公钥
 */
- (void)generatekeyPairs;
- (void)generatekeyPairsWithCurveName:(int)curveName;

+ (EC_KEY *)privateKeyFromPEM:(NSString *)privateKeyPEM;
+ (EC_KEY *)publicKeyFromPEM:(NSString *)publicKeyPEM;

- (NSString *)getPem:(EC_KEY *)ecKey
            voidType:(ECDHKeyPairType)keyPairType;

/**
 * 模仿server生成公钥
 */
- (void)mockGenerateServerPublickKeyBase64;

/**
 根据三方公钥和自持有的私钥经过DH(Diffie-Hellman)算法生成的协商密钥
 
 @param peerPublicKeyBase64 三方公钥
 @param privateKeyBase64 自持有私钥
 @param length 协商密钥长度
 @return 协商密钥
 */
+ (NSString *)getShareKeyFromPeerPublicKeyBase64:(NSString *)peerPublicKeyBase64
                                privateKeyBase64:(NSString *)privateKeyBase64
                                          length:(int)length;



/** 有服务器公钥*/
- (BOOL)hasServerPubKey;

- (NSData *)SHA256String:(NSString *)plaitString;

/*
 * 用ecPrivateKey对数据加签,先对原始数据进行hash
 */
- (NSData*)ECDSA_signHashData:(NSData*)hashData
                 ecPrivateKey:(EC_KEY*)ecPrivateKey;

/*
 * 用ecPublicKey对原数据和加签后的数据验签,先对原数据进行hash(过程与加签一致)
 */
- (BOOL)ECDSA_verifyHashData:(NSData*)hashData
               signatureData:(NSData*)signatureData
                 ecPublicKey:(EC_KEY*)ecPublicKey;


- (NSString*)ECDEncryptWithPlainText:(NSString*)plainText NS_UNAVAILABLE;

- (NSString*)ECDDecryptWithPlainText:(NSString*)cipherText NS_UNAVAILABLE;

+ (void)cleanKeyPairCache;



@end
