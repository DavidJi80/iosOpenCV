//
//  VideoioVC.m
//  iosOpenCV
//
//  Created by mac on 2019/8/9.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "VideoioVC.h"
#import <opencv2/videoio/cap_ios.h>
#import "OpenCVUtility.h"
#import "PhotosUtility.h"

using namespace cv;
using namespace std;

@interface VideoioVC ()<CvVideoCameraDelegate>{
    int64_t cmTimeValue;
}

//UI
@property(nonatomic,strong) UIButton * backBtn;
@property(nonatomic,strong) UIButton * positionBtn;
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UIButton * button;
//OpenCV
@property (nonatomic, retain) CvVideoCamera* videoCamera;
//
@property (nonatomic,assign) bool isWriting;

@end

@implementation VideoioVC

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self initVideoCamera];
    [self initWriter];
    [self performSelector:@selector(actionStart) withObject:nil afterDelay:0.1];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.videoCamera stop];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - init
/**
 Date
 */
-(void)initData{
    cmTimeValue=0;
    self.isWriting=NO;
}


/**
 UI
 */
-(void)initView{
    _imageView=[UIImageView new];
    _imageView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:_imageView];
    
    _backBtn=[UIButton new];
    _backBtn.backgroundColor=[UIColor brownColor];
    _backBtn.frame=CGRectMake(10, 30, 60, 30);
    [_backBtn.layer setCornerRadius:10.0];
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    _positionBtn=[UIButton new];
    _positionBtn.backgroundColor=[UIColor brownColor];
    _positionBtn.frame=CGRectMake(SCREEN_WIDTH-70, 30, 60, 30);
    [_positionBtn.layer setCornerRadius:10.0];
    [_positionBtn setTitle:@"后置" forState:UIControlStateNormal];
    [_positionBtn addTarget:self action:@selector(changePosition:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_positionBtn];
    
    _button=[UIButton new];
    _button.backgroundColor=[UIColor brownColor];
    _button.frame=CGRectMake(SCREEN_WIDTH/2-50, SCREEN_HEIGHT-150, 100, 45);
    [_button setTitle:@"Start" forState:UIControlStateNormal];
    [_button.layer setCornerRadius:10.0];
    [_button addTarget:self action:@selector(startWrite:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

/**
 init OpenCV CvVideoCamera
 */
-(void)initVideoCamera{
    //self.cvEffect=SOURCE;
    //初始化相机并提供imageView作为渲染每个帧的目标
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    /**
     CvVideoCamera基本上是围绕AVFoundation的包装，
     所以我们将AVGoundation摄像机的一些选项作为属性。
     */
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;          //使用后置摄像头
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;         //设置视频大小
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;  //视频方向
    self.videoCamera.rotateVideo =YES;                                                      //设置是旋转
    self.videoCamera.defaultFPS = 25;                                                       //设置相机的FPS
}

/**
 初始化写入器
 */
-(void)initWriter{
    //1. 创建AVAssetWriter
    [PhotosUtility deleteFileAtUrl:self.videoCamera.videoFileURL];
    NSError *wError;
    self.videoCamera.recordAssetWriter = [[AVAssetWriter alloc] initWithURL:self.videoCamera.videoFileURL fileType:AVFileTypeQuickTimeMovie error:&wError];
    //2. 创建AVAssetWriterInput
    NSDictionary *videoSettings =
    @{
      AVVideoCodecKey:AVVideoCodecTypeH264,
      AVVideoWidthKey:@720,
      AVVideoHeightKey:@1280,
      AVVideoCompressionPropertiesKey:@{
              AVVideoMaxKeyFrameIntervalKey:@1,
              AVVideoAverageBitRateKey:@10500000,
              AVVideoProfileLevelKey:AVVideoProfileLevelH264Main31,
              }
      };
    self.videoCamera.recordAssetWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    self.videoCamera.recordAssetWriterInput.expectsMediaDataInRealTime = YES;    //设置YES指明这个输入针对实时性进行优化
    /*2.1. 创建AVAssetWriterInputPixelBufferAdaptor,
     提供了一个优化的CVPixelBufferPool，使用它可以创建CVPixelBuffer对象来渲染筛选视频帧。*/
    NSDictionary *attributes =
    @{
      (id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
      (id)kCVPixelBufferWidthKey:videoSettings[AVVideoWidthKey],
      (id)kCVPixelBufferHeightKey:videoSettings[AVVideoHeightKey],
      (id)kCVPixelFormatOpenGLESCompatibility:(id)kCFBooleanTrue,
      };
    self.videoCamera.recordPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.videoCamera.recordAssetWriterInput sourcePixelBufferAttributes:attributes];
    //2.2. 将AVAssetWriterInput添加到AVAssetWriter
    if ([self.videoCamera.recordAssetWriter canAddInput:self.videoCamera.recordAssetWriterInput]) {
        [self.videoCamera.recordAssetWriter addInput:self.videoCamera.recordAssetWriterInput];
    }
}

#pragma mark - Event
-(void)back:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changePosition:(UIButton*)sender{
    [self.videoCamera stop];
    if (self.videoCamera.defaultAVCaptureDevicePosition==AVCaptureDevicePositionBack){
        [self.videoCamera setDefaultAVCaptureDevicePosition:AVCaptureDevicePositionFront];
        [_positionBtn setTitle:@"前置" forState:UIControlStateNormal];
    }else{
        [self.videoCamera setDefaultAVCaptureDevicePosition:AVCaptureDevicePositionBack];
        [_positionBtn setTitle:@"后置" forState:UIControlStateNormal];
    }
    [self.videoCamera start];
}

- (void)actionStart{
    [self.videoCamera start];
}

- (void)startWrite:(UIButton*)sender{
    if (self.isWriting){
        self.isWriting=NO;
        [_button setTitle:@"Start" forState:UIControlStateNormal];
        [self.videoCamera.recordAssetWriterInput markAsFinished];
        [self.videoCamera.recordAssetWriter finishWritingWithCompletionHandler:^{
            AVAssetWriterStatus status = self.videoCamera.recordAssetWriter.status;
            if (status == AVAssetWriterStatusCompleted) {
                [PhotosUtility saveVideoAtUrl:self.videoCamera.videoFileURL];
            } else {
                
            }
        }];
    }else{
        self.isWriting=YES;
        [_button setTitle:@"Stop" forState:UIControlStateNormal];
    }
}


#pragma mark - Protocol CvVideoCameraDelegate
- (void)processImage:(Mat&)image{
    //边缘检测
    Mat edge,grayMat;
    cvtColor(image, grayMat, 6);
    blur(grayMat, edge, cv::Size(3,3));
    Canny(edge, image, 3, 9, 3, false);
    //把处理过的Mat写入文件
    if (self.isWriting){
        if (self.videoCamera.recordAssetWriter.status==AVAssetWriterStatusUnknown){
            // 开始写入数据
            [self.videoCamera.recordAssetWriter startWriting];
            // 创建一个新的写入会话，传递资源样本的开始时间
            [self.videoCamera.recordAssetWriter startSessionAtSourceTime:kCMTimeZero];
        }else if (self.videoCamera.recordAssetWriter.status==AVAssetWriterStatusWriting){
            CVPixelBufferRef pixelBuffer=[OpenCVUtility pixelBufferFromCVMat:image];
            if (self.videoCamera.recordPixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData && pixelBuffer) {
                //获取样本时间
                cmTimeValue++;
                CMTime currentSampleTime = CMTimeMake(cmTimeValue, 25);
                //NSLog(@"%@",[PhotosFrameworksUtility formatCMTime:currentSampleTime]);
                if(![self.videoCamera.recordPixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:currentSampleTime]){
                    NSLog(@"append pixel buffer failed");
                }
                CFRelease(pixelBuffer);
            }
        }
    }
}

#pragma mark - Function
// 设置存储路径
- (String)uniqueURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directionPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"camera_movie"];
    
    NSLog(@"unique url ：%@",directionPath);
    if (![fileManager fileExistsAtPath:directionPath]) {
        [fileManager createDirectoryAtPath:directionPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [directionPath stringByAppendingPathComponent:@"camera_movie.mov"];
    String filePathStr = filePath.UTF8String;
    return filePathStr;
}

@end
