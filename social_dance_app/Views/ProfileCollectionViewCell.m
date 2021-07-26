//
//  ProfileCollectionViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "ProfileCollectionViewCell.h"

@implementation ProfileCollectionViewCell

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
