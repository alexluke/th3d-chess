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
	//IBOutlet UIImageView *_imageView;
	//IBOutlet UIButton *_button;
    //CvVideoCamera *_videoCamera;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, retain) CvVideoCamera *videoCamera;

- (IBAction)actionStart:(id)sender;
- (void)drawLineOn:(Mat&)image withLine:(Vec2f)line color:(Scalar)color;

@end
