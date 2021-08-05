//
//  PostUtility.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/30/21.
//

#import "PostUtility.h"

@implementation PostUtility

+ (void)updateTimestampForLabel:(UILabel *)label usingPost:(Post *)post {
    label.text = [NSString stringWithFormat:@"%@", post.createdAt];
    
    double timeInterval = post.createdAt.timeIntervalSinceNow;
    
    NSDate *timeAgoDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;

    int oneWeek = 604800;
    if (fabs(timeInterval) > oneWeek) {
        label.text = [formatter stringFromDate:post.createdAt];
    } else {
        label.text = timeAgoDate.shortTimeAgoSinceNow;
    }
}

+ (void)updateBookmarkButton:(UIButton *)button usingPost:(Post *)post {
    button.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *likeRelation = [post relationForKey:@"bookmarkRelation"];
    PFQuery *query = [likeRelation query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            button.selected = YES;
        }
    }];
}

+ (void)updateCommentButton:(UIButton *)button withPost:(Post *)post {
    button.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [Comment query];
    [query whereKey:@"author" equalTo:currentUser];
    [query whereKey:@"post" equalTo:post];
    
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            button.selected = YES;
        }
    }];
}

+ (void)updateCommentLabel:(UILabel *)label withPost:(Post *)post {
    label.text = [NSString stringWithFormat:@"%@", post.commentCount];
}

+ (void)updateUsernameLabel:(UILabel *)label andProfilePicture:(UIImageView *)imageView WithUser:(PFUser *)user {
    label.text = user[@"username"];
    PFFileObject *postImage = user[@"profilePicture"];
    
    [UIManager updateProfilePicture:imageView withPFFileObject:postImage];
}

+ (void)updateLikeButton:(UIButton *)button withPost:(Post *)post {
    button.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *likeRelation = [post relationForKey:@"likeRelation"];
    PFQuery *query = [likeRelation query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            button.selected = YES;
        }
    }];
}

+ (void)updateLikeLabel:(UILabel *)label withPost:(Post *)post {
    label.text = [NSString stringWithFormat:@"%@", post.likeCount];
}

+ (void)updateThumbnailView:(__weak UIImageView *)imageView withPost:(Post *)post {
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:[NSURL URLWithString:post.smallThumbnailImage.url]];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:[NSURL URLWithString:post.thumbnailImage.url]];
    
    [imageView setImageWithURLRequest:requestSmall
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
        
        imageView.alpha = 0.0;
        imageView.image = smallImage;
        
        [UIView animateWithDuration:0.3
                         animations:^{
            imageView.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            [imageView setImageWithURLRequest:requestLarge
                                          placeholderImage:smallImage
                                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                imageView.image = largeImage;
            }
                                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
        }];
    }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
}

+ (void)displayVideoThumbnailOverView:(PlayerView *)view withPost:(Post *)post withPlayButtonIncluded:(BOOL)isPlayButtonIncluded {
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:view.frame];

    NSURL *thumbnailURL = [NSURL URLWithString:post.thumbnailImage.url];
    
    [self updateThumbnailView:thumbnailView withPost:post];
//    [thumbnailView setImageWithURL:thumbnailURL];
    
    [thumbnailView setContentMode:UIViewContentModeScaleAspectFit];
    [view addSubview:thumbnailView];
    [thumbnailView setBounds:view.bounds];
    [thumbnailView setClipsToBounds:YES];
    thumbnailView.center = CGPointMake(view.bounds.size.width  / 2,
                                     view.bounds.size.height / 2);
    
    if (isPlayButtonIncluded) {
        [self addPlayButtonOverView:view];
    }
    
    [view layoutIfNeeded];
}

+ (void)addPlayButtonOverView:(UIView *)view {
    UIImageView *playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button"]];
    [playButton setFrame:CGRectMake(0, 0, 50, 50)];
    [view addSubview:playButton];
    playButton.center = CGPointMake(view.bounds.size.width  / 2,
                                     view.bounds.size.height / 2);
}

@end
