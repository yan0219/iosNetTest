//
//  ViewController.m
//  NetTest
//
//  Created by yjl on 2018/9/3.
//  Copyright © 2018年 yjl. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>

#define beva_appKey @"APP-52"
#define bava_appSecret @"jHO2hCc7MhOIBvml-vS8"

@interface ViewController ()

@property (nonatomic,strong) NSString* accessToken;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL* curUrl = [NSURL URLWithString:@"https://open.beva.com/v1/auth/get-salt-code"];
    NSMutableURLRequest* curRequest = [[NSMutableURLRequest alloc] initWithURL:curUrl];
    
    NSURLSessionConfiguration* curConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* curSession = [NSURLSession sessionWithConfiguration:curConfiguration];
    
    NSURLSessionDataTask* curTask = [curSession dataTaskWithRequest:curRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* saltString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary* saltDic = [self dictionaryWithJsonString:saltString];
        NSString* curSalt = [saltDic objectForKey:@"data"];
        NSLog(@"%@",[NSThread currentThread]);
        [self performSelectorOnMainThread:@selector(showBackView) withObject:nil waitUntilDone:NO];
        
        
        
        NSString* curSecret = [NSString stringWithFormat:@"%@%@",bava_appSecret,curSalt];
        
        
        
        NSString* atUrlString = [[NSString alloc] initWithFormat:@"https://open.beva.com/v1/auth/get-access-token1?appkey=%@&salt=%@&secret=%@&devId=123&lang=cn&device=iphone8",beva_appKey,curSalt,[self getmd5WithString:curSecret]];
        
        NSURL* curUrl = [NSURL URLWithString:atUrlString];
        NSMutableURLRequest* curRequest = [[NSMutableURLRequest alloc] initWithURL:curUrl];
        
        NSURLSessionConfiguration* curConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* curSession = [NSURLSession sessionWithConfiguration:curConfiguration];
        
        NSURLSessionDataTask* atTask = [curSession dataTaskWithRequest:curRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSString* atDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
            NSLog(@"%@",[NSThread currentThread]);
            [self performSelectorOnMainThread:@selector(showBackView) withObject:nil waitUntilDone:NO];
            
        }];
        [atTask resume];
        
    }];
    
    [curTask resume];
}

- (NSString*)getmd5WithString:(NSString *)string

{
    
    const char* original_str=[string UTF8String];
    
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    
    CC_MD5(original_str, strlen(original_str), digist);
    
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        
        [outPutStr appendFormat:@"%02x", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
        
    }
    
    return [outPutStr lowercaseString];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)showBackView
{
    NSLog(@"%@",[NSThread currentThread]);
    self.view.backgroundColor = [UIColor redColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
