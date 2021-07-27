//
//  PostCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/27/21.
//

#import "PostCell.h"

@implementation PostCell

- (void)updateAppearanceWithImage:(UIImage *)image {
    self.thumbnailView.image = image;
    [self fadeIn];
}

- (void)fadeIn {
    [self.thumbnailView setAlpha:0];
    [UIImageView animateWithDuration:1 animations:^{
            [self.thumbnailView setAlpha:1];
    }];
}

@end
