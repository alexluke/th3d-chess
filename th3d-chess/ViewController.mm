//
//  ViewController.m
//  th3d-chess
//
//  Created by Alex Luke on 6/12/13.
//  Copyright (c) 2013 Alex Luke. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
	self.videoCamera.delegate = self;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	self.videoCamera.defaultFPS = 30;
	self.videoCamera.grayscaleMode = NO;
}

#ifdef __cplusplus
- (void)processImage:(Mat&)image {
	Mat image_copy;
	cvtColor(image, image_copy, CV_BGRA2BGR);

	bitwise_not(image_copy, image_copy);
	cvtColor(image_copy, image, CV_BGR2BGRA);
}
#endif

- (IBAction)actionStart:(UIButton*)sender {
    if (self.videoCamera.running) {
        [self.videoCamera stop];
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    } else {
        [self.videoCamera start];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
