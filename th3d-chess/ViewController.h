//
//  ViewController.h
//  th3d-chess
//
//  Created by Alex Luke on 6/12/13.
//  Copyright (c) 2013 Alex Luke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate> {
    int stepperValue1;
    int stepperValue2;
    int stepperValue3;
    int stepperValue4;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, retain) CvVideoCamera *videoCamera;

@property (nonatomic, strong) IBOutlet UILabel *stepperLabel1;
@property (nonatomic, strong) IBOutlet UILabel *stepperLabel2;
@property (nonatomic, strong) IBOutlet UILabel *stepperLabel3;
@property (nonatomic, strong) IBOutlet UILabel *stepperLabel4;

- (IBAction)actionStart:(id)sender;
- (IBAction)stepperValueChanged:(UIStepper*)sender;

@end
