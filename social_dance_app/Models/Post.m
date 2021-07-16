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

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void)postUserVideo:(PFFileObject *)videoFile withCaption:(NSString *)caption withSong:(Song *)song withCompletion:(PFBooleanResultBlock)completion {
    Post *newPost = [Post new];

    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.videoFile = videoFile;
    newPost.song = song;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    
    NSLog(@"Post song: %@", newPost.song);
    
    [newPost saveInBackgroundWithBlock: completion];
}

@end
