//
//  WLRSATool.m
//  SecurityDemo
//
//  Created by 章子云 on 2021/10/19.
//

#import "WLRSATool.h"

static NSString * const kIdentifierPublic = @"kIdentifierPublic";
static NSString * const kIdentifierPrivate = @"kIdentifierPrivate";

@implementation WLRSATool {
    
    RSA *_publicKey;
    RSA *_privateKey;
    
    SecKeyRef _publicKeyRef;
    SecKeyRef _privateKeyRef;
    
    NSData *_modData;
    NSData *_expData;
}

+ (WLRSATool *)shareRSATool {
    static WLRSATool *rsaTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (rsaTool == nil) {
            rsaTool = [[WLRSATool alloc] init];
        }
    });
    
    return rsaTool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self generateKeyPair];
    }
    return self;
}

- (void)generateKeyPair {
    
    RSA *rsa = RSA_generate_key(1024,RSA_F4,NULL,NULL);
    
    if (rsa) {
        _privateKey = RSAPrivateKey_dup(rsa);
        _publicKey = RSAPublicKey_dup(rsa);
        if (_privateKey && _publicKey) {
            self.publicKeyBase64 = [self base64EncodedStringPublicKey:_publicKey];
            self.privateKeyBase64 = [self base64EncodedStringPrivateKey:_privateKey];
            
            // 生成公私钥
            [self SecKeyReadPublicKeyPEM];
            [self SecKeyReadPrivateKeyPEM];
        }
    }
}

#pragma mark ---读取密钥对
- (void)SecKeyReadPublicKeyPEM {
    if(!_publicKeyBase64) {
        return;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:_publicKeyBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    _publicKeyRef = [self publicSecKeyFromKeyBits:data];
    
    if (_publicKeyRef) {
        NSData *publicKeyData = [self publicKeyBitsFromSecKey:_publicKeyRef];
        _modData = [self getPublicKeyMod:publicKeyData];
        _expData = [self getPublicKeyExp:publicKeyData];
    }
    
}

- (void)SecKeyReadPrivateKeyPEM{
    if(!_privateKeyBase64) {
        return;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:_privateKeyBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    _privateKeyRef = [self privateSecKeyFromKeyBits:data];
    if (_privateKeyRef) {
//        NSString *logText = [NSString stringWithFormat:@"SecKey 读出私钥pem成功\n%@",_privateKeyRef];
//        NSLog(@"%@", logText);
    }
}
#pragma mark - 加密
// 公钥加密
- (NSString *)SecRefPubcliKeyEncrypt:(NSString *)plainText {
    if(!_publicKeyRef) {
        return @"";
    }
    if (!plainText) {
        return @"";
    }
    
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [self encryptWithKey:_publicKeyRef plainData:plainData padding:kSecPaddingPKCS1];
    // 加密后的串
    NSString *encryptString = [cipherData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encryptString;
}

// 私钥解密
- (NSString *)SecRefPrivateKeyDecrypt:(NSString *)encryptString {
    if(!_privateKeyRef) {
        return @"";
    }
    if (!encryptString) {
        return @"";
    }
    
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:encryptString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *plainData = [self decryptWithKey:_privateKeyRef cipherData:cipherData padding:kSecPaddingPKCS1];
    
    // 解密后数据
    NSString *plainText = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    return plainText;
}


#pragma mark ---加解密
- (NSData *)encryptWithKey:(SecKeyRef)key plainData:(NSData *)plainData padding:(SecPadding)padding {
    if (!key) {
        return nil;
    }
    if (!plainData) {
        return nil;
    }
    
    size_t paddingSize = 1; // 防止明文大于模数
    if (padding == kSecPaddingPKCS1) {
        paddingSize = 11;
    }
    size_t keySize = SecKeyGetBlockSize(key) * sizeof(uint8_t);
    double totalLength = [plainData length];
    size_t blockSize = keySize - paddingSize;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *encryptData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        unsigned char *cipherBuffer = malloc(keySize);
        memset(cipherBuffer, 0, keySize);
        
        OSStatus status = noErr;
        size_t cipherBufferSize = keySize;
        status = SecKeyEncrypt(key,
                               padding,
                               [dataSegment bytes],
                               dataSegmentRealSize,
                               cipherBuffer,
                               &cipherBufferSize
                               );
        
        if(status == noErr){
            NSData *resultData = [[NSData alloc] initWithBytes:cipherBuffer length:cipherBufferSize];
            [encryptData appendData:resultData];
        } else {
            free(cipherBuffer);
            return nil;
        }
        free(cipherBuffer);
    }
    return encryptData;
}
- (NSData *)decryptWithKey:(SecKeyRef)key cipherData:(NSData *)cipherData padding:(SecPadding)padding {
    if (!key) {
        return nil;
    }
    if (!cipherData) {
        return nil;
    }
    
    size_t keySize = SecKeyGetBlockSize(key) * sizeof(uint8_t);
    double totalLength = [cipherData length];
    size_t blockSize = keySize;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *decrypeData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        long dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        unsigned char *plainBuffer = malloc(keySize);
        memset(plainBuffer, 0, keySize);
        OSStatus status = noErr;
        size_t plainBufferSize = keySize ;
        status = SecKeyDecrypt(key,
                               padding,
                               [dataSegment bytes],
                               dataSegmentRealSize,
                               plainBuffer,
                               &plainBufferSize
                               );
        if(status == noErr){
            NSData *data = [[NSData alloc] initWithBytes:plainBuffer length:plainBufferSize];
            [decrypeData appendData:data];
        } else {
            free(plainBuffer);
            return nil;
        }
    }
    
    return decrypeData;
    
}

#pragma mark - 公私钥读取
- (SecKeyRef)publicSecKeyFromKeyBits:(NSData *)givenData {
    
    NSData *peerTag = [kIdentifierPublic dataUsingEncoding:NSUTF8StringEncoding];
    
    
    OSStatus sanityCheck = noErr;
    SecKeyRef secKey = nil;
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    [queryKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryKey setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryKey setObject:(id)kSecAttrKeyClassPublic forKey:(id)kSecAttrKeyClass];
    
    [queryKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    [queryKey setObject:givenData forKey:(__bridge id)kSecValueData];
    [queryKey setObject:@YES forKey:(__bridge id)kSecReturnRef];
    
    (void)SecItemDelete((__bridge CFDictionaryRef) queryKey);
    
    CFTypeRef result;
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) queryKey, &result);
    if (sanityCheck == errSecSuccess) {
        secKey = (SecKeyRef)result;
    }
    
    return secKey;
}

- (NSData *)publicKeyBitsFromSecKey:(SecKeyRef)givenKey {
    
    NSData *peerTag = [kIdentifierPublic dataUsingEncoding:NSUTF8StringEncoding];
    
    OSStatus sanityCheck = noErr;
    NSData * keyBits = nil;
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    [queryKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryKey setObject:(id)kSecAttrKeyClassPublic forKey:(id)kSecAttrKeyClass];
    [queryKey setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [queryKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    [queryKey setObject:(__bridge id)givenKey forKey:(__bridge id)kSecValueRef];
    [queryKey setObject:@YES forKey:(__bridge id)kSecReturnData];
    
    
    
    CFTypeRef result;
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) queryKey, &result);
    if (sanityCheck == errSecSuccess) {
        keyBits = CFBridgingRelease(result);
        
        (void)SecItemDelete((__bridge CFDictionaryRef) queryKey);
    }
    
    return keyBits;
}

- (SecKeyRef)privateSecKeyFromKeyBits:(NSData *)givenData {
    
    NSData *peerTag = [kIdentifierPrivate dataUsingEncoding:NSUTF8StringEncoding];
    
    OSStatus sanityCheck = noErr;
    SecKeyRef secKey = nil;
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    [queryKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryKey setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryKey setObject:(id)kSecAttrKeyClassPrivate forKey:(id)kSecAttrKeyClass];
    [queryKey setObject:givenData forKey:(__bridge id)kSecValueData];
    [queryKey setObject:@YES forKey:(__bridge id)kSecReturnRef];
    
    CFTypeRef result;
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) queryKey, &result);
    if (sanityCheck == errSecSuccess) {
        secKey = (SecKeyRef)result;
        
        (void)SecItemDelete((__bridge CFDictionaryRef) queryKey);
    }
    
    return secKey;
}


#pragma mark - 公私钥生成
/// 私钥
- (NSString *)base64EncodedStringPrivateKey:(RSA *)privateKey {
    
    if (!privateKey) {
        return nil;
    }
    
    BIO *bio = BIO_new(BIO_s_mem());
    PEM_write_bio_RSAPrivateKey(bio, privateKey, NULL, NULL, 0, NULL, NULL);
    
    BUF_MEM *bptr;
    BIO_get_mem_ptr(bio, &bptr);
    
    NSString *pemString = [NSString stringWithFormat:@"%s",bptr->data];
    
    BIO_set_close(bio, BIO_NOCLOSE); /* So BIO_free() leaves BUF_MEM alone */
    BIO_free(bio);
    
    return [self base64EncodedFromPEMFormat:pemString];
}

/// 公钥
- (NSString *)base64EncodedStringPublicKey:(RSA *)publicKey {
    if (!publicKey) {
        return nil;
    }
    
    BIO *bio = BIO_new(BIO_s_mem());
    PEM_write_bio_RSA_PUBKEY(bio, publicKey);
    
    BUF_MEM *bptr;
    BIO_get_mem_ptr(bio, &bptr);
    
    NSString *pemString = [NSString stringWithFormat:@"%s",bptr->data];
    BIO_set_close(bio, BIO_NOCLOSE); /* So BIO_free() leaves BUF_MEM alone */
    BIO_free(bio);
    
    return [self base64EncodedFromPEMFormat:pemString];
}

- (NSString *)base64EncodedFromPEMFormat:(NSString *)PEMFormat {
    return [[PEMFormat componentsSeparatedByString:@"-----"] objectAtIndex:2];
}


#pragma mark - 公钥与模数和指数转换
//公钥指数
- (NSData *)getPublicKeyExp:(NSData *)pk {

    if (pk == NULL) return NULL;
    
    int iterator = 0;
    
    iterator++; // TYPE - bit stream - mod + exp
    [self derEncodingGetSizeFrom:pk at:&iterator]; // Total size
    
    iterator++; // TYPE - bit stream mod
    int mod_size = [self derEncodingGetSizeFrom:pk at:&iterator];
    iterator += mod_size;
    
    iterator++; // TYPE - bit stream exp
    int exp_size = [self derEncodingGetSizeFrom:pk at:&iterator];
    
    return [pk subdataWithRange:NSMakeRange(iterator, exp_size)];
}
// 模数
- (NSData *)getPublicKeyMod:(NSData *)pk {
    if (pk == NULL) return NULL;
    
    int iterator = 0;
    
    iterator++; // TYPE - bit stream - mod + exp
    [self derEncodingGetSizeFrom:pk at:&iterator]; // Total size
    
    iterator++; // TYPE - bit stream mod
    int mod_size = [self derEncodingGetSizeFrom:pk at:&iterator];
    
    return [pk subdataWithRange:NSMakeRange(iterator, mod_size)];
}

- (int)derEncodingGetSizeFrom:(NSData*)buf at:(int*)iterator {
    const uint8_t* data = [buf bytes];
    int itr = *iterator;
    int num_bytes = 1;
    int ret = 0;
    
    if (data[itr] > 0x80) {
        num_bytes = data[itr] - 0x80;
        itr++;
    }
    
    for (int i = 0 ; i < num_bytes; i++) ret = (ret * 0x100) + data[itr + i];
    
    *iterator = itr + num_bytes;
    return ret;
}


#pragma mark - 纯 openssl 加解密

/// 公钥加密
- (NSString *)openssl_RSAEncrypt:(NSString *)plainText {
    if(!_publicKeyRef) {
        return @"";
    }
    if (!plainText) {
        return @"";
    }
    
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [self openssl_encryptWithPublicKey:_publicKey plainData:plainData padding:kSecPaddingPKCS1];
    // 加密后的串
    NSString *encryptString = [cipherData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encryptString;
}
/// 私钥解密
- (NSString *)openssl_RSADecrypt:(NSString *)encryptString {
    
    if(!_privateKeyRef) {
        return @"";
    }
    if (!encryptString) {
        return @"";
    }
    
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:encryptString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *plainData = [self openssl_decryptWithPrivateKey:_privateKey cipherData:cipherData padding:kSecPaddingPKCS1];
    // 解密后数据
    NSString *plainText = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    return plainText;
}

- (RSA *)openssl_publicKeyFromBase64:(NSString *)publicKey {
    //格式化公钥
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    int count = 0;
    for (int i = 0; i < [publicKey length]; ++i) {
        
        unichar c = [publicKey characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == 64) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    [result appendString:@"\n-----END PUBLIC KEY-----"];
    
    return [self openssl_publicKeyFromPEM:result];
}
- (RSA *)openssl_privateKeyFromBase64:(NSString *)privateKey {
    //格式化私钥
    const char *pstr = [privateKey UTF8String];
    int len = (int)[privateKey length];
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"-----BEGIN RSA PRIVATE KEY-----\n"];
    int index = 0;
    int count = 0;
    while (index < len) {
        char ch = pstr[index];
        if (ch == '\r' || ch == '\n') {
            ++index;
            continue;
        }
        [result appendFormat:@"%c", ch];
        if (++count == 64) {
            
            [result appendString:@"\n"];
            count = 0;
        }
        index++;
    }
    [result appendString:@"\n-----END RSA PRIVATE KEY-----"];
    return [self openssl_privateKeyFromPEM:result];
}

- (RSA *)openssl_publicKeyFromPEM:(NSString *)publicKeyPEM {
    
    const char *buffer = [publicKeyPEM UTF8String];
    
    BIO *bpubkey = BIO_new_mem_buf(buffer, (int)strlen(buffer));
    
    RSA *rsaPublic = PEM_read_bio_RSA_PUBKEY(bpubkey, NULL, NULL, NULL);
    
    BIO_free_all(bpubkey);
    return rsaPublic;
}

- (RSA *)openssl_privateKeyFromPEM:(NSString *)privatePEM {
    const char *buffer = [privatePEM UTF8String];
    
    BIO *bpubkey = BIO_new_mem_buf(buffer, (int)strlen(buffer));
    
    RSA *rsaPrivate = PEM_read_bio_RSAPrivateKey(bpubkey, NULL, NULL, NULL);
    BIO_free_all(bpubkey);
    return rsaPrivate;
}

- (NSData *)openssl_encryptWithPublicKey:(RSA *)publicKey plainData:(NSData *)plainData padding:(int)padding {
    int paddingSize = 0;
    if (padding == RSA_PKCS1_PADDING) {
        paddingSize = RSA_PKCS1_PADDING_SIZE;
    }
    
    int publicRSALength = RSA_size(publicKey);
    double totalLength = [plainData length];
    int blockSize = publicRSALength - paddingSize;
    int blockCount = ceil(totalLength / blockSize);
    size_t publicEncryptSize = publicRSALength;
    NSMutableData *encryptDate = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        char *publicEncrypt = malloc(publicRSALength);
        memset(publicEncrypt, 0, publicRSALength);
        const unsigned char *str = [dataSegment bytes];
        int r = RSA_public_encrypt(dataSegmentRealSize,str,(unsigned char*)publicEncrypt,publicKey,padding);
        if (r < 0) {
            free(publicEncrypt);
            return nil;
        }
        NSData *encryptData = [[NSData alloc] initWithBytes:publicEncrypt length:publicEncryptSize];
        [encryptDate appendData:encryptData];
        
        free(publicEncrypt);
    }
    
    return encryptDate;
    

}
- (NSData *)openssl_decryptWithPrivateKey:(RSA *)privateKey cipherData:(NSData *)cipherData padding:(int)padding {
    if (!privateKey) {
        return nil;
    }
    if (!cipherData) {
        return nil;
    }
    int privateRSALenght = RSA_size(privateKey);
    double totalLength = [cipherData length];
    int blockSize = privateRSALenght;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *decrypeData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        long dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        const unsigned char *str = [dataSegment bytes];
        unsigned char *privateDecrypt = malloc(privateRSALenght);
        memset(privateDecrypt, 0, privateRSALenght);
        int ret = RSA_private_decrypt(privateRSALenght,str,privateDecrypt,privateKey,padding);
        if(ret >=0){
            NSData *data = [[NSData alloc] initWithBytes:privateDecrypt length:ret];
            [decrypeData appendData:data];
        }
        free(privateDecrypt);
    }
    
    return decrypeData;
}

@end
