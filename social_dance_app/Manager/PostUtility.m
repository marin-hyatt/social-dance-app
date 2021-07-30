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

@end
