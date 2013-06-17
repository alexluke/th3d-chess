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
	Mat outer_box;
	cvtColor(image, outer_box, CV_BGRA2GRAY);
    //equalizeHist(outer_box, outer_box);

    Mat white, black, thresh;
    
    erode(outer_box, white, NULL);
    dilate(outer_box, black, NULL);
    
    threshold(white, thresh, 20.0f + 70.0f, 255, CV_THRESH_BINARY);
    
    vector<vector<cv::Point>> contours;
    findContours(thresh, contours, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE);
    drawContours(image, contours, -1, CV_RGB(255, 0, 0));
    
    vector<std::pair<float, int>> quads;
    [self saveQuadrangleHypothesesTo:quads fromContours:contours];
    
    threshold(black, thresh, 20.0f + 70.0f, 255, CV_THRESH_BINARY_INV);
    findContours(thresh, contours, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE);
    drawContours(image, contours, -1, CV_RGB(255, 0, 0));
    //cvtColor(thresh, image, CV_GRAY2BGRA);
}

- (void)saveQuadrangleHypothesesTo:(vector<std::pair<float, int>>&)quads fromContours:(vector<vector<cv::Point>>)contours {
    
    for (int i = 0; i < contours.size(); i++) {
        RotatedRect box = minAreaRect(contours[i]);
        float box_size = MAX(box.size.width, box.size.height);
        if (box_size < 10.0f)
            continue;
        float aspect_ratio = box.size.width / MAX(box.size.height, 1);
        if (aspect_ratio < 0.3f || aspect_ratio > 3.0f)
            continue;
        quads.push_back(std::pair<float, int>(box_size, 1));
    }
}

- (void)drawLineOn:(Mat&)image withLine:(Vec2f)line color:(Scalar)color {
    if (line[1] != 0) {
        float m = -1/tan(line[1]);
        float c = line[0]/sin(line[1]);
        
        cv::line(image, cv::Point(0, c), cv::Point(image.size().width, m * image.size().width + c), color);
    } else {
        cv::line(image, cv::Point(line[0], 0), cv::Point(line[0], image.size().height), color);
    }
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
