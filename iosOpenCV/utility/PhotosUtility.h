//
//  PhotosUtility.h
//  iosOpenCV
//
//  Created by mac on 2019/8/16.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotosUtility : NSObject

+ (void)saveVideoAtUrl:(NSURL *)nsUrl;
+ (void)deleteFileAtUrl:(NSURL *)nsUrl;

@end

NS_ASSUME_NONNULL_END
