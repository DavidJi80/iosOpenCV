//
//  CascadeVC.m
//  iosOpenCV
//
//  Created by mac on 2019/8/7.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "CascadeVC.h"
#import <opencv2/videoio/cap_ios.h>

using namespace cv;
using namespace std;

@interface CascadeVC ()<CvVideoCameraDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    CascadeClassifier cascade;
}
//UI
@property(nonatomic,strong) UIButton * backBtn;
@property(nonatomic,strong) UIButton * positionBtn;
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UIButton * button;
@property (strong, nonatomic) UIPickerView *pickerView;
//OpenCV
@property (nonatomic, retain) CvVideoCamera* videoCamera;
//Data
@property (nonatomic,strong) NSDictionary * cascadeSource;
@property (nonatomic,strong) NSArray * cascadeType;
@property (nonatomic,strong) NSString * selectedCascadeType;
@property (nonatomic,assign) NSInteger rowType;
@property (nonatomic,assign) NSInteger rowSource;

@end

@implementation CascadeVC

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self initCascade];
    [self initVideoCamera];
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
 UI
 */
-(void)initData{
    _cascadeSource=@{
             @"hogcascade":@[@"pedestrians"],
             @"haarcascade":@[@"upperbody",
                              @"frontalcatface_extended",
                              @"profileface",
                              @"frontalcatface",
                              @"frontalface_alt2"
                              ,@"eye"],
             @"lbpcascade":@[@"frontalface",
                             @"silverware",
                             @"frontalcatface",
                             @"profileface",
                             @"frontalface_improved"],
             };
    _cascadeType=[_cascadeSource allKeys];
    _selectedCascadeType=_cascadeType[0];
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
    _button.frame=CGRectMake(SCREEN_WIDTH/2-100, SCREEN_HEIGHT-150, 200, 45);
    [_button setTitle:@"Cascades" forState:UIControlStateNormal];
    [_button.layer setCornerRadius:10.0];
    [_button addTarget:self action:@selector(openPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _pickerView=[UIPickerView new];
    _pickerView.frame=CGRectMake(0, SCREEN_HEIGHT-100, SCREEN_WIDTH, 100);
    _pickerView.backgroundColor=UIColor.whiteColor;
    self.pickerView.dataSource=self;
    self.pickerView.delegate=self;
    [self.view addSubview:_pickerView];
    
    [self.pickerView setHidden:YES];
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
    self.videoCamera.defaultFPS = 30;                                                       //设置相机的FPS
}

/**
 CascadeClassifier 级联分类器
 */
-(void)initCascade{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_eye" ofType:@"xml"];
    String pathStr = path.UTF8String;
    if (!cascade.load(pathStr)){
        cout << "Load haarcascade_frontalface_alt failed!" << endl;
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

-(void)openPickerView:(UIButton*)sender{
    if (self.pickerView.hidden){
        [self.pickerView setHidden:NO];
        [self.videoCamera stop];
    }else{
        [self.pickerView setHidden:YES];
        NSString * typeName=_cascadeType[_rowType];
        NSString * selectedCascade=[_cascadeSource[typeName] objectAtIndex:_rowSource];
        NSString * resource=[NSString stringWithFormat:@"%@_%@",typeName,selectedCascade];
        [self changeCascades:resource];
    }
}

#pragma mark - Protocol CvVideoCameraDelegate
- (void)processImage:(Mat&)image{
    Mat GrayFrame;
    
    cvtColor(image, GrayFrame, COLOR_BGR2GRAY);
    
    vector<Rect2i> faceRect;
    cascade.detectMultiScale(GrayFrame, faceRect, 1.1, 3, 0, Size2i(30, 30),cv::Size(200,200));
    for (size_t i = 0; i < faceRect.size(); i++){
        rectangle(image, faceRect[i], Scalar(255, 255, 0), 3);      //用矩形画出检测到的位置
    }
}

#pragma mark - UIPickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component==0) { //如果是第一列
        return _cascadeType.count;
    }else{ //如果是其他列，当然这里只有第二列
        return [_cascadeSource[_selectedCascadeType] count];
    }
    
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component==0) {
        return _cascadeType[row]; //思路:按自然顺序0,1,2排下来的
    }else{
        return [_cascadeSource[_selectedCascadeType] objectAtIndex:row];
    }
}

//UIPickerViewDelegate中定义的方法,该方法返回的CGFloat将作为UIPickerView中指定的宽度
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component==0) {
        return 120;
    }else{
        return SCREEN_WIDTH-120;
    }
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component==0) {
        _selectedCascadeType=_cascadeType[row];  //只要第一列不变，第二列也不会变
        [self.pickerView reloadComponent:1]; //控制重写第二个列表,根据选中的作者来加载第二个列表
        [self.pickerView selectRow:0 inComponent:1 animated:YES]; //每当选择作者列的时候，让书名列默认选中的都是第一行(Row为0的那一行)
        _rowType=row;
        _rowSource=0;
    }else if (component==1) {
        _rowSource=row;
    }
    NSString * typeName=_cascadeType[_rowType];
    NSString * selectedCascade=[_cascadeSource[typeName] objectAtIndex:_rowSource];
    [_button setTitle:selectedCascade forState:UIControlStateNormal];
}

#pragma mark - Function
-(void)changeCascades:(NSString *)resource{
    [self.videoCamera stop];
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:@"xml"];
    String pathStr = path.UTF8String;
    if (!cascade.load(pathStr)){
        cout << "Load haarcascade_frontalface_alt failed!" << endl;
    }
    [self.videoCamera start];
}

@end
