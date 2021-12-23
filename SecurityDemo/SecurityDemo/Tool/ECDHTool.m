//
//  ECDHTool.m
//  ECDHUtils
//
//  Created by 章子云 on 2018/8/7.
//  Copyright © 2018年 Four_w. All rights reserved.
//

#import "ECDHTool.h"

static int KCurveName = NID_secp256k1; //曲线参数,需多端一致

@interface ECDHTool()

@end

@implementation ECDHTool

//@synthesize privateKeyRef,publicKeyRef;

+ (ECDHTool *)sharedInstance {
    static ECDHTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ECDHTool alloc] init];
    });
    return sharedInstance;
}

- (void)generatekeyPairsWithCurveName:(int)curveName {
    EC_KEY *eckey;
    eckey = [self createNewKeyWithCurve:curveName];
    NSString  *privateKeyBase64 = [self getPem:eckey voidType:ECDHKeyPairTypePrivate];
    NSString  *publicKeyBase64 = [self getPem:eckey voidType:ECDHKeyPairTypePublic];
    self.privateKeyBase64 = privateKeyBase64;
    self.publicKeyBase64 = publicKeyBase64;
//    self.aesKey = [ECDHTool getShareKeyFromPeerPublicKeyBase64:self.serverPublicKeyBase64 privateKeyBase64:self.privateKeyBase64 length:32];
//    NSLog(@"public key = %@",self.publicKeyBase64);
//    NSLog(@"private key = %@",self.privateKeyBase64);
//    NSLog(@"aesKey = %@",self.aesKey);

    EC_KEY_free(eckey);
}

- (void)generatekeyPairs {
    [self generatekeyPairsWithCurveName:KCurveName];
}

- (void)mockGenerateServerPublickKeyBase64 {
    // 生成公钥私钥
    EC_KEY *eckey;
    eckey = [self createNewKeyWithCurve:KCurveName];
//    NSString  *privateKeyBase64 = [self getPem:eckey voidType:ECDHKeyPairTypePrivate];
    NSString  *publicKeyBase64 = [self getPem:eckey voidType:ECDHKeyPairTypePublic];
    self.serverPublicKeyBase64 = publicKeyBase64;
    EC_KEY_free(eckey);
}

/** 有服务器公钥*/
- (BOOL)hasServerPubKey {
    if (self.serverPublicKeyBase64.length>0&&self.skey.length>0) {
        return YES;
    }
    return NO;
}

- (NSString *)getPem:(EC_KEY *)ecKey
            voidType:(ECDHKeyPairType)keyPairType{
    BIO *out = NULL;
    BUF_MEM *buf;
    buf = BUF_MEM_new();
    out = BIO_new(BIO_s_mem());
    switch (keyPairType) {
        case ECDHKeyPairTypePrivate:
            PEM_write_bio_ECPrivateKey(out, ecKey, NULL, NULL, 0, NULL, NULL);
            break;
        case ECDHKeyPairTypePublic:
            PEM_write_bio_EC_PUBKEY(out, ecKey);
            break;
        default:
            break;
    }
    BIO_get_mem_ptr(out, &buf);
    NSString  *pem = [[NSString alloc] initWithBytes:buf->data
                                              length:(NSUInteger)buf->length
                                            encoding:NSASCIIStringEncoding];
    
    
    if (keyPairType == ECDHKeyPairTypePublic) {
        pem = [pem stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@""];
        pem = [pem stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        pem = [pem stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        pem = [pem stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@""];
    }
    
    BIO_free(out);
    
    return pem;
}

- (EC_KEY *)createNewKeyWithCurve:(int)curve {
    // 生成EC_KEY对象
    int asn1Flag = OPENSSL_EC_NAMED_CURVE;
    int form = POINT_CONVERSION_UNCOMPRESSED;
    EC_KEY *eckey = NULL;
    EC_GROUP *group = NULL;
    eckey = EC_KEY_new();
    group = EC_GROUP_new_by_curve_name(curve);
    EC_GROUP_set_asn1_flag(group, asn1Flag);
    EC_GROUP_set_point_conversion_form(group, form);
    EC_KEY_set_group(eckey, group);
    
    int resultFromKeyGen = EC_KEY_generate_key(eckey);
    if (resultFromKeyGen != 1){
        raise(-1);
    }
    return eckey;
}


+ (EC_KEY *)publicKeyFromPEM:(NSString *)publicKeyPEM {
    
    const char *pstr = [publicKeyPEM UTF8String];
    int len = (int)[publicKeyPEM length];
    NSMutableString *publicKeyResult = [NSMutableString string];
    [publicKeyResult appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    int index = 0;
    int count = 0;
    while (index < len) {
        char ch = pstr[index];
        if (ch == '\r' || ch == '\n') {
            ++index;
            continue;
        }
        [publicKeyResult appendFormat:@"%c", ch];
        if (++count == 64) {
            
            [publicKeyResult appendString:@"\n"];
            count = 0;
        }
        index++;
    }
    [publicKeyResult appendString:@"\n-----END PUBLIC KEY-----"];
    
    // 将PEM格式的公钥字符串转化成EC_KEY
    const char *buffer = [publicKeyResult UTF8String];
    BIO *bpubkey = BIO_new_mem_buf(buffer, (int)strlen(buffer));
    EVP_PKEY *public = PEM_read_bio_PUBKEY(bpubkey, NULL, NULL, NULL);
    EC_KEY *ec_cdata = EVP_PKEY_get1_EC_KEY(public);
    BIO_free_all(bpubkey);
    return ec_cdata;
}

+ (EC_KEY *)privateKeyFromPEM:(NSString *)privateKeyPEM {

    // 将PEM格式的私钥字符串转化成EC_KEY
    const char *buffer = [privateKeyPEM UTF8String];
    BIO *r = BIO_new_mem_buf(buffer, (int)strlen(buffer));
    EC_KEY *privateKey = PEM_read_bio_ECPrivateKey(r, NULL, NULL, NULL);
    BIO_free_all(r);
    return privateKey;
}

+ (EC_KEY *)testPrivateKeyFromPEM:(NSString *)privateKeyPEM {
    const char *pstr = [privateKeyPEM UTF8String];
    int len = (int)[privateKeyPEM length];
    NSMutableString *privateKeyResult = [NSMutableString string];
    [privateKeyResult appendString:@"-----BEGIN EC PRIVATE KEY-----\n"];
    int index = 0;
    int count = 0;
    while (index < len) {
        char ch = pstr[index];
        if (ch == '\r' || ch == '\n') {
            ++index;
            continue;
        }
        [privateKeyResult appendFormat:@"%c", ch];
        if (++count == 64) {
            
            [privateKeyResult appendString:@"\n"];
            count = 0;
        }
        index++;
    }
    [privateKeyResult appendString:@"\n-----END EC PRIVATE KEY-----"];
    
    const char *buffer = [privateKeyResult UTF8String];
    BIO *out = BIO_new_mem_buf(buffer, (int)strlen(buffer));
    EC_KEY *pricateKey = PEM_read_bio_ECPrivateKey(out, NULL, NULL, NULL);
    BIO_free_all(out);
    return pricateKey;
}

+ (NSString *)getShareKeyFromPeerPublicKeyBase64:(NSString *)peerPublicKeyBase64
                                privateKeyBase64:(NSString *)privateKeyBase64
                                          length:(int)length {
    
    // 根据私钥PEM字符串,生成私钥
    EC_KEY *clientEcKey = [ECDHTool privateKeyFromPEM:privateKeyBase64];
//    EC_KEY *clientEcKey = [ECDHTool testPrivateKeyFromPEM:privateKeyBase64];
    if (!length) {
        //获取私钥长度
        const EC_GROUP *group = EC_KEY_get0_group(clientEcKey);
        length = (EC_GROUP_get_degree(group) + 7)/8;
    }
    // 根据peerPubPem生成新的公钥EC_KEY
    EC_KEY *serverEcKey = [ECDHTool publicKeyFromPEM:peerPublicKeyBase64];
    const EC_POINT *serverEcKeyPoint = EC_KEY_get0_public_key(serverEcKey);
    char shareKey[length];
    ECDH_compute_key(shareKey, length, serverEcKeyPoint, clientEcKey,  NULL);
    // 释放公钥,释放私钥
    EC_KEY_free(clientEcKey);
    EC_KEY_free(serverEcKey);
    
    NSData *shareKeyData = [NSData dataWithBytes:shareKey length:length];
    NSString *shareKeyStr = [shareKeyData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return shareKeyStr;
}

- (NSData*)ECDSA_signHashData:(NSData*)hashData ecPrivateKey:(EC_KEY*)ecPrivateKey {
    
    ecPrivateKey = ecPrivateKey ?:[ECDHTool privateKeyFromPEM:self.privateKeyBase64];
    if (hashData == nil || ecPrivateKey == nil) return nil;
    
    Byte *digest = malloc(hashData.length);
    [hashData getBytes:digest length:hashData.length];

    unsigned int sig_len;
    int size = ECDSA_size(ecPrivateKey);
    unsigned char *signature = (unsigned char*)malloc(size);

    int ret;
    int digestLen = (int)hashData.length;

    /* 签名数据，本例未做摘要，可将 digest 中的数据看作是 sha1 摘要结果 */
    ret = ECDSA_sign(0,digest,digestLen,signature,&sig_len,ecPrivateKey);
    if(ret!=1) {
        free(digest);
        free(signature);
        NSLog(@"==================ECDSA 签名失败====================");
        return nil;
    }
    
    NSLog(@"==================ECDSA 签名成功=====================");
    
    if (signature == NULL || sig_len == 0) return nil;
    NSData *data = [NSData dataWithBytes:signature length:sig_len];
    free(digest);
    free(signature);
    return data;
}

- (BOOL)ECDSA_verifyHashData:(NSData*)hashData signatureData:(NSData*)signatureData ecPublicKey:(EC_KEY*)ecPublicKey {
    
    ecPublicKey = ecPublicKey ?:[ECDHTool publicKeyFromPEM:self.publicKeyBase64];
    if (hashData == nil || signatureData == nil || ecPublicKey == nil) return nil;

    void *digest = malloc(hashData.length);
    [hashData getBytes:digest length:hashData.length];
    
    unsigned int sig_len = (unsigned)signatureData.length;
    unsigned int digest_len = (unsigned)hashData.length;
    
    void *signature = malloc(signatureData.length);
    [signatureData getBytes:signature length:signatureData.length];
    
    int ret;
    ret = ECDSA_verify(0,digest,digest_len,signature,sig_len,ecPublicKey);
    if (ret != 1) {
//        free(signature);
        NSLog(@"======================ECDSA 验签失败===================");
    }
    NSLog(@"==================ECDSA 验签成功=====================");
//    free(signature);
    return ret == 1;
}

- (NSData *)SHA256String:(NSString *)plaitString {
    NSData *keyData = [plaitString dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *shaData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    return shaData;
}


- (NSString*)ECDEncryptWithPlainText:(NSString*)plainText {
    int len = 0;
    unsigned char cipherText[MAXBSIZE];
    unsigned char *encryptStr = encrypt_text(NULL, NULL, (unsigned char*)[plainText UTF8String], &len, cipherText);
    return [NSString stringWithUTF8String:(const char*)encryptStr];
}

- (NSString*)ECDDecryptWithPlainText:(NSString*)cipherText {
    int len = 0;
    unsigned char plainText[MAXBSIZE];
    unsigned char *decryptStr = decrypt_text(NULL, NULL, (unsigned char*)[cipherText UTF8String], &len, plainText);
    return [NSString stringWithUTF8String:(const char*)decryptStr];
}


#define EVP_DES_CBC EVP_des_cbc()
//#define EVP_DES_CBC EVP_aes_128_cbc();
#define MAX_CHAR_SIZE 512

unsigned char *decrypt_text(unsigned char *iv, unsigned char *key, unsigned char *ciphertext,int *ciphertext_len,unsigned char* plaintext) {
    
    EVP_CIPHER_CTX de;
    EVP_CIPHER_CTX_init(&de);
    const EVP_CIPHER *cipher_type;
    
    int bytes_written = 0;
    int update_len = 0;
    cipher_type = EVP_DES_CBC;
    
    //  rc = EVP_CIPHER_CTX_set_key_length(&de, strlen(pstRedirectConf->key));
    EVP_DecryptInit_ex(&de, cipher_type, NULL, key, iv);
    
    if(!EVP_DecryptInit_ex(&de, NULL, NULL, NULL, NULL)){
        printf("ERROR in EVP_DecryptInit_ex \n");
        return NULL;
    }
    
    
    int plaintext_len = 0;
    if(!EVP_DecryptUpdate(&de,
                          plaintext, &update_len,
                          ciphertext, *ciphertext_len)){
        printf("ERROR in EVP_DecryptUpdate\n");
        return NULL;
    }
    
    if(!EVP_DecryptFinal_ex(&de,
                            plaintext + update_len, &bytes_written)){
        printf("ERROR in EVP_DecryptFinal_ex\n");
        return NULL;
    }
    bytes_written += update_len;
    *(plaintext+bytes_written) = '\0';
    
    printf("out_buf(%d->%d) : %s\n", *ciphertext_len,bytes_written, plaintext);
    
    EVP_CIPHER_CTX_cleanup(&de);
    
    return plaintext;
}


unsigned char *encrypt_text(unsigned char *iv, unsigned char *key, unsigned char *plaintext,int *ciphertext_len,unsigned char *ciphertext ) {
    
    EVP_CIPHER_CTX en;
    EVP_CIPHER_CTX_init(&en);
    const EVP_CIPHER *cipher_type;
    int input_len = 0;
    
    
    //  cipher_type = EVP_aes_128_cbc();
    cipher_type = EVP_DES_CBC;
    
    //init cipher
    EVP_EncryptInit_ex(&en, cipher_type, NULL, key, iv);
    
    // We add 1 because we're encrypting a string, which has a NULL terminator
    // and want that NULL terminator to be present when we decrypt.
    //  input_len = strlen(plaintext) + 1;
    input_len = strlen(plaintext);
    /* allows reusing of 'e' for multiple encryption cycles */
    
    if(!EVP_EncryptInit_ex(&en, NULL, NULL, NULL, NULL)){
        printf("ERROR in EVP_EncryptInit_ex \n");
        return NULL;
    }
    
    // This function works on binary data, not strings.  So we cast our
    // string to an unsigned char * and tell it that the length is the string
    // length + 1 byte for the null terminator.
    int bytes_written = 0;
    //encrypt
    if(!EVP_EncryptUpdate(&en,
                          ciphertext, &bytes_written,
                          (unsigned char *) plaintext, input_len ) ) {
        return NULL;
    }
    *ciphertext_len += bytes_written;
    
    //do padding
    if(!EVP_EncryptFinal_ex(&en,
                            ciphertext + bytes_written,
                            &bytes_written)){
        printf("ERROR in EVP_EncryptFinal_ex \n");
        return NULL;
    }
    *ciphertext_len += bytes_written;
    
    int i = 0;
    printf("encrypt string: ");
    for( i =0;i < *ciphertext_len; i++)
        printf("%.02x", ciphertext[i]);
    
    printf("\n");
    //cleanup
    EVP_CIPHER_CTX_cleanup(&en);
    
    return ciphertext;
}


@end
