//
//  ALDRootViewController.m
//  ALDSightFilters
//
//  Created by Andy Drizen on 12/07/2014.
//  Copyright (c) 2014 Andy Drizen. All rights reserved.
//

#import "ALDRootViewController.h"
#import "ALDColorBlindEffect.h"

@interface ALDRootViewController ()
@property (weak, nonatomic) IBOutlet UISlider *blurSlider;
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *colourWheel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@end

@implementation ALDRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        self.colourWheel.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];

    [ALDColorBlindEffect sharedInstance].view = [UIApplication sharedApplication].delegate.window;
}

- (IBAction)blurValueChanged:(UISlider *)sender {
    [ALDColorBlindEffect sharedInstance].blurAmount = sender.value;
}

- (IBAction)filterButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    sender.backgroundColor = [UIColor colorWithWhite:0.10 alpha:1.0];
    
    if ([ALDColorBlindEffect sharedInstance].type == sender.tag) {
        [ALDColorBlindEffect sharedInstance].type = ALDColorBlindEffectTypeNone;
        sender.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
        return;
    }
    
    for (UIButton *button in self.buttons) {
        if (button != sender) {
            button.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
            button.selected = NO;
        }
    }

    [ALDColorBlindEffect sharedInstance].type = [sender tag];
}

@end
