//
//  PhotosUtility.m
//  iosOpenCV
//
//  Created by mac on 2019/8/16.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "PhotosUtility.h"

@implementation PhotosUtility

/**
 存入相册
 */
+ (void)saveVideoAtUrl:(NSURL *)nsUrl {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:nsUrl];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //需要删除文件的物理地址
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:nsUrl.path];
        if (fileExists) {
            [fileManager removeItemAtPath:nsUrl.path error:nil];
        }
    }];
}

+ (void)deleteFileAtUrl:(NSURL *)nsUrl{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:nsUrl.path];
    if (fileExists) {
        [fileManager removeItemAtPath:nsUrl.path error:nil];
    }
}


@end
