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

@property (nonatomic,strong) NSURLSession* curSession;

@property (nonatomic,strong) NSString* accessToken;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSession];
    [self initView];
    
    // Do any additional setup after loading the view, typically from a nib.
    
}

#pragma mark initData
//初始化一个NSUrlSession对象，之后的报文发送都使用该对象
- (void)initSession
{
    //初始化一个session的配置对象
    NSURLSessionConfiguration* yConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    /*初始化一个session对象，其中三个参数分别是
     *configuration:配置对象
     *delegate:session处理代理的对象
     *delegateQueue：代理的消息处理的线程，这里传mainQueue，代理的消息都会在主线程中收到
    */
    self.curSession = [NSURLSession sessionWithConfiguration:yConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

//初始化界面按钮显示
- (void)initView
{
    int curY = 50;
    int curX = 30;
    
    UIButton* customRestfulBut = [[UIButton alloc] initWithFrame:CGRectMake(curX, curY, self.view.frame.size.width - 2*curX, 30)];
    customRestfulBut.backgroundColor = [UIColor blueColor];
    [customRestfulBut setTitle:@"普通报文发送" forState:UIControlStateNormal];
    [customRestfulBut addTarget:self action:@selector(customRestfulTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customRestfulBut];
    curY = curY + 50;
    
}

-(void)customRestfulTest
{
    
//    //初始化一个session对象
//    NSURLSession* testSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //初始化一个request对象
    NSURL* curUrl = [NSURL URLWithString:@"https://open.beva.com/v1/auth/get-salt-code"];
    NSMutableURLRequest* curRequest = [[NSMutableURLRequest alloc] initWithURL:curUrl];
    
    //生成一个task对象
    NSURLSessionDataTask* curTask = [self.curSession dataTaskWithRequest:curRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* saltString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary* dataDic = [self dictionaryWithJsonString:saltString];
        NSLog(@"receive data : %@,in %@",[dataDic description],[NSThread currentThread]);
        
//        //返回主线程刷新界面
//        [self performSelectorOnMainThread:@selector(refreshView) withObject:nil waitUntilDone:NO];
//        
//        //返回主线程刷新界面
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //刷新页面
//        });
        
    }];
    
    //启动task任务
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NSURLSessionDelegate

@end
