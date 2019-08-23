//
//  Features2dVC.m
//  iosOpenCV
//
//  Created by mac on 2019/8/19.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "Features2dVC.h"
#import "OpenCVUtility.h"
#include "opencv2/xfeatures2d.hpp"


using namespace cv;
using namespace std;
using namespace cv::xfeatures2d;

@interface Features2dVC ()
@property (nonatomic, strong) CIContext* context;

//UI
@property(nonatomic,strong) UIImageView * outputImageView;

@end

@implementation Features2dVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initFeatureView];
    
    Mat m;
    UIImage * img=[OpenCVUtility uiImageFromCVMat:featureMatchingWithFLANNDemo(m)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.outputImageView setImage:img];
    });
}

-(void)initFeatureView{
    CGFloat width=SCREEN_WIDTH/2-40;
    CGFloat height=width*SCREEN_HEIGHT/SCREEN_WIDTH;
    _outputImageView=[UIImageView new];
    _outputImageView.frame=CGRectMake(SCREEN_WIDTH-width-5, SCREEN_HEIGHT-height-10, width, height);
    _outputImageView.contentMode =  UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.outputImageView];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
    if (mediaType == kCMMediaType_Video) {
        //设置方向
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationPortrait) {
            [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }else if (orientation == UIDeviceOrientationLandscapeLeft) {
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        }else if (orientation == UIDeviceOrientationLandscapeRight) {
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        }else{
            [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }

        //获取基础CVPixelBuffer
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        Mat srcMat=[OpenCVUtility cvMatFromPixelBufferByCI:imageBuffer ciContext:self.context];
        Mat dstMat=featureDescriptionDemo(srcMat);
        //将图片在preview上展示，这个时候可以对图片做相关处理。加滤镜的内容后面再加。
        UIImage * img=[OpenCVUtility uiImageFromCVMat:dstMat];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.outputImageView setImage:img];
        });

    }else if(mediaType == kCMMediaType_Audio){

    }
}

#pragma mark - OpenCV Function
/**
 Harris 角点检测
 */
Mat cornerHarrisDemo(Mat src){
    Mat src_gray;
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    Mat dst, dst_norm, dst_norm_scaled;
    dst = Mat::zeros( src.size(), CV_32FC1 );
    int blockSize = 2;
    int apertureSize = 3;
    double k = 0.04;
    cornerHarris(src_gray,          //输入图像
                 dst,               //检测结果的图像
                 blockSize,         //邻域大小
                 apertureSize,      //Sobel算法的Aperture参数
                 k,                 //Harris检测的自由参数
                 BORDER_DEFAULT );  //像素外推法
    
    /// Normalizing
    normalize( dst, dst_norm, 0, 255, NORM_MINMAX, CV_32FC1, Mat() );
    convertScaleAbs( dst_norm, dst_norm_scaled );
    
    /// Drawing a circle around corners
    int thresh = 200;
    for( int j = 0; j < dst_norm.rows ; j++ ){
        for( int i = 0; i < dst_norm.cols; i++ ){
            if( (int) dst_norm.at<float>(j,i) > thresh ){
                circle( dst_norm_scaled, cv::Point( i, j ), 5,  Scalar(0), 2, 8, 0 );
            }
        }
    }
    return dst_norm_scaled;
}

/**
 Shi-Tomasi 角点检测
 */
Mat goodFeaturesToTrackDemo(Mat src){
    Mat src_gray;
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    vector<Point2f> corners;
    int maxCorners = 23;
    double qualityLevel = 0.01;
    Mat copy = src.clone();
    double minDistance = 10;
    int blockSize = 3, gradientSize = 3;
    bool useHarrisDetector = false;
    double k = 0.04;
    goodFeaturesToTrack(src_gray,           //输入图像
                        corners,            //输出向量
                        maxCorners,         //最大角点数
                        qualityLevel,       //最小可接受质量
                        minDistance,        //最小欧氏距离
                        Mat(),              //感兴趣的可选区域
                        blockSize,          //导数协变矩阵的平均块大小
                        gradientSize,       //梯度大小
                        useHarrisDetector,  //cornerMinEigenVal
                        k );                //Harris检测器的自由参数
    int radius = 4;
    RNG rng(12345);
    for( size_t i = 0; i < corners.size(); i++ ){
        circle( copy, corners[i], radius, Scalar(rng.uniform(0,255), rng.uniform(0, 256), rng.uniform(0, 256)), FILLED );
    }
    return copy;
}

/**
 特征点检测
 */
Mat featureDetectionDemo(Mat src){
    //将RGBA转换为RGB，Mat类型由CV_8UC4转换为CV_8UC3
    cvtColor(src,src, COLOR_RGBA2RGB);
    //-- Step 1: Detect the keypoints using SURF Detector
    int minHessian = 400;
    Ptr<SURF> detector = SURF::create( minHessian );
    std::vector<KeyPoint> keypoints;
    detector->detect( src, keypoints );
    //-- Draw keypoints
    Mat img_keypoints;
    drawKeypoints( src, keypoints, img_keypoints );
    //-- Show detected (drawn) keypoints
    return img_keypoints;
}

/**
 特征点检测
 */
Mat featureDescriptionDemo(Mat src){
    Mat img1,img2;
    cvtColor(src,img1, COLOR_RGBA2RGB);
    UIImage *image = [UIImage imageNamed:@"2.jpg"];
    img2=[OpenCVUtility cvMatFromUIImage:image];
    cvtColor(img2,img2, COLOR_RGBA2RGB);
    int minHessian = 400;
    Ptr<SURF> detector = SURF::create( minHessian );
    std::vector<KeyPoint> keypoints1, keypoints2;
    Mat descriptors1, descriptors2;
    detector->detectAndCompute( img1, noArray(), keypoints1, descriptors1 );
    detector->detectAndCompute( img2, noArray(), keypoints2, descriptors2 );
    //-- Step 2: Matching descriptor vectors with a brute force matcher
    // Since SURF is a floating-point descriptor NORM_L2 is used
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::BRUTEFORCE);
    std::vector< DMatch > matches;
    matcher->match( descriptors1, descriptors2, matches );
    //-- Draw matches
    Mat img_matches;
    drawMatches( img1, keypoints1, img2, keypoints2, matches, img_matches );
    //-- Show detected matches
    return img_matches;
}

/**
 使用FLANN进行特征点匹配
 */
Mat featureMatchingWithFLANNDemo(Mat src){
//    UIImage *image1 = [UIImage imageNamed:@"1.jpg"];
//    Mat img1=[OpenCVUtility cvMatFromUIImage:image1];
//    cvtColor(img1,img1, COLOR_RGBA2GRAY);
//    UIImage *image2 = [UIImage imageNamed:@"2.jpg"];
//    Mat img2=[OpenCVUtility cvMatFromUIImage:image2];
//    cvtColor(img2,img2, COLOR_RGBA2GRAY);
//
    NSString *imagePath1 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
    String imgPathStr1 = imagePath1.UTF8String;

    NSString *imagePath2 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"jpg"];
    String imgPathStr2 = imagePath2.UTF8String;
    
    
    Mat img1 = imread( imgPathStr1, IMREAD_GRAYSCALE );
    Mat img2 = imread( imgPathStr2, IMREAD_GRAYSCALE );
    //-- Step 1: Detect the keypoints using SURF Detector, compute the descriptors
    int minHessian = 400;
    Ptr<SURF> detector = SURF::create( minHessian );
    std::vector<KeyPoint> keypoints1, keypoints2;
    Mat descriptors1, descriptors2;
    detector->detectAndCompute( img1, noArray(), keypoints1, descriptors1 );
    detector->detectAndCompute( img2, noArray(), keypoints2, descriptors2 );
    //-- Step 2: Matching descriptor vectors with a FLANN based matcher
    // Since SURF is a floating-point descriptor NORM_L2 is used
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::FLANNBASED);
    std::vector< std::vector<DMatch> > knn_matches;
    matcher->knnMatch( descriptors1, descriptors2, knn_matches, 2 );
    //-- Filter matches using the Lowe's ratio test
    const float ratio_thresh = 0.7f;
    std::vector<DMatch> good_matches;
    for (size_t i = 0; i < knn_matches.size(); i++)
    {
        if (knn_matches[i][0].distance < ratio_thresh * knn_matches[i][1].distance)
        {
            good_matches.push_back(knn_matches[i][0]);
        }
    }
    //-- Draw matches
    Mat img_matches;
    drawMatches( img1, keypoints1, img2, keypoints2, good_matches, img_matches, Scalar::all(-1),
                Scalar::all(-1), std::vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    return img_matches;
}

#pragma mark - lazy load
-(CIContext *)context{
    // default creates a context based on GPU
    if (_context == nil) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}




@end
