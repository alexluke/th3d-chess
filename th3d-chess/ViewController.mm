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
    
    GaussianBlur(outer_box, outer_box, cv::Size(11, 11), 0);
    adaptiveThreshold(outer_box, outer_box, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY, 5, 2.0);
    bitwise_not(outer_box, outer_box);
    
    Mat kernel = (Mat_<uchar>(3, 3) << 0,1,0,1,1,1,0,1,0);
    dilate(outer_box, outer_box, kernel);
    
    int max = -1;
    cv::Point maxPt;
    
    for (int y = 0; y < outer_box.size().height; y++) {
        uchar *row = outer_box.ptr(y);
        for (int x = 0; x < outer_box.size().width; x++) {
            if (row[x] >= 128) {
                int area = floodFill(outer_box, cv::Point(x, y), CV_RGB(0, 0, 64));
                
                if (area > max) {
                    maxPt = cv::Point(x, y);
                    max = area;
                }
            }
        }
    }
    
    floodFill(outer_box, maxPt, CV_RGB(255, 255, 255));
    
    for (int y = 0; y < outer_box.size().height; y++) {
        uchar *row = outer_box.ptr(y);
        for (int x = 0; x < outer_box.size().width; x++) {
            if (row[x] == 64 && x != maxPt.x && y != maxPt.y) {
                floodFill(outer_box, cv::Point(x, y), CV_RGB(0, 0, 0));
            }
        }
    }
    
    erode(outer_box, outer_box, kernel);
    
    vector<Vec2f> lines;
    HoughLines(outer_box, lines, 1, CV_PI/180, 200);
    NSLog(@"%ld", lines.size());
    
    for (int i = 0; i < lines.size(); i++) {
        [self drawLineOn:outer_box withLine:lines[i] color:CV_RGB(0, 0, 128)];
    }

    cvtColor(outer_box, image, CV_GRAY2BGRA);
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
