//
//  PlayerView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import "PlayerView.h"

@implementation PlayerView



+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}



- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
    
    [(AVPlayerLayer *)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    if ([(AVPlayerLayer *)[self layer] videoRect].size.width != 0 && [(AVPlayerLayer *)[self layer] videoRect].size.height != 0) {
        NSLog(@"Adding constraints");
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:self
                             attribute:NSLayoutAttributeHeight
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeWidth
                             multiplier:([(AVPlayerLayer *)[self layer] videoRect].size.height / [(AVPlayerLayer *)[self layer] videoRect].size.width)
                             constant:0]];
    }
    [self printDimensions];
}

-(void)printDimensions {
    NSLog(@"Width: %f, Height: %f", self.frame.size.width, self.frame.size.height);
    NSLog(@"Video width: %f, Video height: %f", [(AVPlayerLayer *)[self layer] videoRect].size.width, [(AVPlayerLayer *)[self layer] videoRect].size.height);
    NSLog(@"Player layer width: %f, Player layer height: %f", self.layer.frame.size.width, self.layer.frame.size.height);
}

@end
