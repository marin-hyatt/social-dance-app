//
//  UIManager.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "UIManager.h"
#import "Parse/Parse.h"

@implementation UIManager

+ (void)updateProfilePicture:(UIImageView *)profilePictureView withPFFileObject:(PFFileObject *)file {
    profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2;
    profilePictureView.layer.masksToBounds = true;
    NSURL *imageURL = [NSURL URLWithString:file.url];
    [profilePictureView setImageWithURL:imageURL];
}

@end
