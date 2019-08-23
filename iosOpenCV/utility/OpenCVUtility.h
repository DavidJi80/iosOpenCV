//
//  OpenCVUtility.h
//  iosOpenCV
//
//  Created by mac on 2019/8/16.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import <Foundation/Foundation.h>

using namespace cv;

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVUtility : NSObject
// UIImage <=> cv::Mat
+(UIImage *)uiImageFromCVMat:(Mat)cvMat;
+(Mat)cvMatFromUIImage:(UIImage *)image;
// CVPixelBufferRef <=> cv::Mat
+(cv::Mat)cvMatFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef;
+(cv::Mat)cvMatFromPixelBufferByCI:(CVPixelBufferRef)pixelBuffer ciContext:(CIContext *)ciContext;
+(CVPixelBufferRef)pixelBufferFromCVMat:(cv::Mat)cvMat;

@end

NS_ASSUME_NONNULL_END
