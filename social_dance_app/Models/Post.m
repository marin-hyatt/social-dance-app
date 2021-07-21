//
//  Post.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "Post.h"
#import "Parse/Parse.h"

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic likeCount;
@dynamic commentCount;
@dynamic createdAt;
@dynamic videoFile;
@dynamic song;
@dynamic likedByUsers;
@dynamic videoWidth;
@dynamic videoHeight;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void)postUserVideo:(PFFileObject *)videoFile withCaption:(NSString *)caption withSong:(Song *)song withHeight:(NSNumber *)height withWidth:(NSNumber *)width withCompletion:(PFBooleanResultBlock)completion {
    Post *newPost = [Post new];

    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.videoFile = videoFile;
    newPost.song = song;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.likedByUsers = @[];
    newPost.videoWidth = width;
    newPost.videoHeight = height;
    
    [newPost saveInBackgroundWithBlock: completion];
}

- (void)likePostWithUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion {
    self.likedByUsers = [self.likedByUsers arrayByAddingObject:user];
    [self saveInBackgroundWithBlock: completion];
}

@end
