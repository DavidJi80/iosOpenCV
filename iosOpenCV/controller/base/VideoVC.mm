//
//  VideoVC.m
//  iosOpenCV
//
//  Created by mac on 2019/7/22.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "VideoVC.h"
#import <opencv2/videoio/cap_ios.h>
#include <opencv2/core/types_c.h>

using namespace std;
using namespace cv;


@interface VideoVC () <CvVideoCameraDelegate>{
    UIImageView* imageView;
    UIButton* button;
//    cv::Ptr<DetectionBasedTracker::IDetector> MainDetector;
//    cv::Ptr<DetectionBasedTracker::IDetector> TrackingDetector;
}
//UI
//@property (nonatomic,strong) UIImageView * imageView;
//@property (nonatomic,strong) UIButton * button;
//
@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end

@implementation VideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    imageView=[UIImageView new];
    imageView.frame=CGRectMake(40, 100, 300, 400);
//    imageView.backgroundColor=UIColor.purpleColor;
    [self.view addSubview:imageView];
    
    button=[UIButton new];
    button.backgroundColor=[UIColor brownColor];
    button.frame=CGRectMake(150, 550, 100, 45);
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button.layer setCornerRadius:10.0];
    [button addTarget:self action:@selector(actionStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    //self.videoCamera.rotateVideo =YES; //设置是旋转
    self.videoCamera.defaultFPS = 30;
    
    [self performSelector:@selector(actionStart:) withObject:nil afterDelay:0.1];
    
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(cv::Mat&)image{
    Mat src=image;
    int thresh = 200;
    Mat src_gray;
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    
    Mat dst, dst_norm, dst_norm_scaled;
    dst = Mat::zeros( src.size(), CV_32FC1 );
    
    /// Detector parameters
    int blockSize = 2;
    int apertureSize = 3;
    double k = 0.04;
    /// Detecting corners
    cornerHarris( src_gray, dst, blockSize, apertureSize, k, BORDER_DEFAULT );
    
    /// Normalizing
    normalize( dst, dst_norm, 0, 255, NORM_MINMAX, CV_32FC1, Mat() );
    convertScaleAbs( dst_norm, dst_norm_scaled );
    
    /// Drawing a circle around corners
    for( int j = 0; j < dst_norm.rows ; j++ ){
        for( int i = 0; i < dst_norm.cols; i++ ){
            if( (int) dst_norm.at<float>(j,i) > thresh ){
                circle( dst_norm_scaled, cv::Point( i, j ), 5,  Scalar(0), 2, 8, 0 );
            }
        }
    }
    image=dst_norm_scaled;

}

#endif

- (void)actionStart:(id)sender{
    [self.videoCamera start];
}

@end
