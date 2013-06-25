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
    Mat thresh;
	cvtColor(image, thresh, CV_BGRA2GRAY);
    
    //equalizeHist(thresh, thresh);
    
    int k = stepperValue1;
    int dilations = stepperValue2;
    int block_size = cvRound(MIN(thresh.cols, thresh.rows) * (k%2 == 0 ? 0.2 : 0.1))|1;
    adaptiveThreshold(thresh, thresh, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, block_size, (k/2)*5);
    if (dilations > 0)
        dilate(thresh, thresh, 0, cv::Point(-1, -1), dilations - 1);
    
    rectangle(thresh, cv::Point(0, 0), cv::Point(thresh.cols - 1, thresh.rows -1), CV_RGB(255, 255, 255), 3, 8);
    
    if (stepperValue4 == 1)
        cvtColor(thresh, image, CV_GRAY2BGRA);
    
    int board_index = -1;
    vector<cv::Point> board;
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    findContours(thresh, contours, hierarchy,  CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE);
    vector<int> counters(contours.size());
    for (int i = 0; i < contours.size(); i++) {
        cv::Rect rect = boundingRect(contours[i]);
        if (hierarchy[i][3] > -1 && rect.width * rect.height >= 25) {
            if (stepperValue3 == 1)
                drawContours(image, contours, i, CV_RGB(0, 0, 255));
            vector<cv::Point> dst;
            for (int l = 1; l <= 7; l++) {
                approxPolyDP(contours[i], dst, (double)l, TRUE);
                if (dst.size() == 4)
                    break;
            }
            
            //if (dst.size() == 4)
            //    [self drawPoly:dst withColor:CV_RGB(0, 0, 255) toImage:image];
            
            if (dst.size() == 4 && isContourConvex(dst)) {
                
                double d1, d2, p = arcLength(dst, TRUE);
                double area = fabs(contourArea(dst));
                double dx, dy;
                
                dx = dst[0].x - dst[2].x;
                dy = dst[0].y - dst[2].y;
                d1 = sqrt(dx*dx + dy*dy);
                
                dx = dst[1].x - dst[3].x;
                dy = dst[1].y - dst[3].y;
                d2 = sqrt(dx*dx + dy*dy);
                
                double d3, d4;
                dx = dst[0].x - dst[1].x;
                dy = dst[0].y - dst[1].y;
                d3 = sqrt(dx*dx + dy*dy);
                dx = dst[1].x - dst[2].x;
                dy = dst[1].y - dst[2].y;
                d4 = sqrt(dx*dx + dy*dy);
                
                if (d3*4 > d4 &&
                    d4*4 > d3 &&
                    d3*d4 < area*1.5 &&
                    area > 25 &&
                    d1 >= 0.15 * p &&
                    d2 >= 0.15 *p) {
                    counters[hierarchy[i][1]]++;
                    if (board_index == -1 || counters[board_index] < counters[hierarchy[i][1]]) {
                        board_index = i;
                        board = dst;
                    }
                }
            }
        }
    }
    
    if (board_index != -1) {
        [self drawPoly:board withColor:CV_RGB(255, 0, 0) toImage:image];
    }
    
    
    //cvtColor(thresh, image, CV_GRAY2BGRA);
}

- (void)drawPoly:(vector<cv::Point>)poly withColor:(Scalar)color toImage:(Mat)image {
    for (int i = 0; i < poly.size() - 1; i++)
        line(image, poly[i], poly[i+1], color);
    line(image, poly[poly.size() - 1], poly[0], color);
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

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    switch (sender.tag) {
        case 1:
            stepperValue1 = (int)sender.value;
            [self.stepperLabel1 setText:[NSString stringWithFormat:@"%d", stepperValue1]];
            break;
        case 2:
            stepperValue2 = (int)sender.value;
            [self.stepperLabel2 setText:[NSString stringWithFormat:@"%d", stepperValue2]];
            break;
        case 3:
            stepperValue3 = (int)sender.value;
            [self.stepperLabel3 setText:[NSString stringWithFormat:@"%d", stepperValue3]];
            break;
        case 4:
            stepperValue4 = (int)sender.value;
            [self.stepperLabel4 setText:[NSString stringWithFormat:@"%d", stepperValue4]];
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
