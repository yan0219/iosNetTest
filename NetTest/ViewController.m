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

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDelegate>

//发送报文的全局session
@property (nonatomic,strong) NSURLSession* curSession;

//记录下载任务列表
@property (nonatomic,strong) NSMutableArray* downloadTaskArray;

//显示下载任务的tableView
@property (nonatomic,strong) UITableView *dTableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _downloadTaskArray = [[NSMutableArray alloc] init];
    
    [self initSession];
    [self initView];
    
    // Do any additional setup after loading the view, typically from a nib.
    
}

#pragma mark initData
//初始化一个NSUrlSession对象，之后的报文发送都使用该对象
- (void)initSession
{
    //初始化一个session的配置对象
    //NSURLSessionConfiguration* yConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSessionConfiguration* yConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.yan0219.download"];
    
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
    
    
    UIButton* downloadRestfulBut = [[UIButton alloc] initWithFrame:CGRectMake(curX, curY, self.view.frame.size.width - 2*curX, 30)];
    downloadRestfulBut.backgroundColor = [UIColor blueColor];
    [downloadRestfulBut setTitle:@"下载数据" forState:UIControlStateNormal];
    [downloadRestfulBut addTarget:self action:@selector(downLoadTask) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadRestfulBut];
    curY = curY + 50;
    
    self.dTableView = [[UITableView alloc] initWithFrame:CGRectMake(curX, curY, self.view.frame.size.width - 2*curX, self.view.frame.size.height - curY - 20)];
    self.dTableView.delegate = self;
    self.dTableView.dataSource = self;
    [self.view addSubview:self.dTableView];
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

- (void)downLoadTask
{
    NSURL* downloadURL = [NSURL URLWithString:@"https://nodejs.org/dist/v8.11.4/node-v8.11.4.pkg"];
    NSURLSessionDownloadTask* task = [self.curSession downloadTaskWithURL:downloadURL];
    
    NSMutableDictionary* taskDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:task,@"task",[NSNumber numberWithFloat:0.0],@"progress", nil];
    [self.downloadTaskArray addObject:taskDic];
    
    [self.dTableView reloadData];
    
    [task resume];
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
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_downloadTaskArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* taskDic = [_downloadTaskArray objectAtIndex:indexPath.row];
    NSURLSessionDownloadTask* task = [taskDic objectForKey:@"task"];
    float progress = [[taskDic objectForKey:@"progress"] floatValue];
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.numberOfLines = 0;
    if(progress == 2.0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"task:%@\n进度:完成",[task description]];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"task:%@\n进度:%.2f",[task description],progress];
    }
    return cell;
}

#pragma mark NSURLSessionDelegate

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    //当session被销毁退出时进入该代理消息
    NSLog(@"NSURLSessionDelegate-------------didBecomeInvalidWithError");
}

/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
//{
//    //暂时没搞明白,该方法一实现，创建现在任务直接就进到这里来，其他代理不进
//    NSLog(@"NSURLSessionDelegate-------------didReceiveChallenge");
//}

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session API_AVAILABLE(ios(7.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos)
{
    //有后台下载能力的session，在后台下载任务完成后，会先调用applicationDelegate的方法，然后再调用该方法
    NSLog(@"NSURLSessionDelegate-------------URLSessionDidFinishEventsForBackgroundURLSession");
}


#pragma mark NSURLSessionDownloadDelegate

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    //下载任务完成时会调用该代理方法，可以在该方法中将下载的临时文件移动到沙盒中保存，当该代理方法返回时，临时文件将被删除
    NSLog(@"NSURLSessionDownloadDelegate-------------didFinishDownloadingToURL");
    
    for (int i = 0; i<[self.downloadTaskArray count]; i++)
    {
        NSMutableDictionary* taskDic = [self.downloadTaskArray objectAtIndex:i];
        NSURLSessionDownloadTask* task = [taskDic objectForKey:@"task"];
        if([task isEqual:downloadTask])
        {
            [taskDic setObject:[NSNumber numberWithFloat:2.0] forKey:@"progress"];
            [self.dTableView reloadData];
            break;
        }
    }
    
    
    NSError *error;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cachePath stringByAppendingPathComponent:@"YDownload/node-v8.11.4.pkg"];
    NSURL *saveUrl = [NSURL fileURLWithPath:savePath];
    // 通过文件管理 复制文件
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&error];
    if (error) {
        NSLog(@"Error is %@", error.localizedDescription);
    }

    
}


/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //下载过程中，反馈下载进度
    NSLog(@"NSURLSessionDownloadDelegate-------------didWriteData");
    float progress = totalBytesWritten * 1.0 /totalBytesExpectedToWrite;
    
    for (int i = 0; i<[self.downloadTaskArray count]; i++)
    {
        NSMutableDictionary* taskDic = [self.downloadTaskArray objectAtIndex:i];
        NSURLSessionDownloadTask* task = [taskDic objectForKey:@"task"];
        if([task isEqual:downloadTask])
        {
            [taskDic setObject:[NSNumber numberWithFloat:progress] forKey:@"progress"];
            [self.dTableView reloadData];
            break;
        }
    }
    
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //未使用到
    NSLog(@"NSURLSessionDownloadDelegate-------------didResumeAtOffset");
}
@end
