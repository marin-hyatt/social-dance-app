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
@dynamic videoWidth;
@dynamic videoHeight;
@dynamic thumbnailImage;
@dynamic smallThumbnailImage;
@dynamic tags;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void)postUserVideo:(PFFileObject *)videoFile withCaption:(NSString *)caption withSong:(Song *)song withHeight:(NSNumber *)height withWidth:(NSNumber *)width withLowQualityThumbnail:( PFFileObject * _Nullable )lowQualityThumbnailImage withThumbnail:(PFFileObject * _Nullable)thumbnailImage withTags:(NSArray *)tags withCompletion:(PFBooleanResultBlock _Nullable)completion {
    Post *newPost = [Post new];

    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.videoFile = videoFile;
    newPost.song = song;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.videoWidth = width;
    newPost.videoHeight = height;
    newPost.smallThumbnailImage = lowQualityThumbnailImage;
    newPost.thumbnailImage = thumbnailImage;
    newPost.tags = tags;
    
    [newPost saveInBackgroundWithBlock: completion];
}

+ (void)likePost:(Post *)post withUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion {
    PFRelation *likeRelation = [post relationForKey:@"likeRelation"];
    [likeRelation addObject:user];
    float likeCount = [post.likeCount doubleValue];
    post.likeCount = [NSNumber numberWithFloat:likeCount + 1];
    [post saveInBackgroundWithBlock: completion];
    
}

+ (void)unlikePost:(Post *)post withUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion {
    PFRelation *likeRelation = [post relationForKey:@"likeRelation"];
    [likeRelation removeObject:user];
    float likeCount = [post.likeCount doubleValue];
    post.likeCount = [NSNumber numberWithFloat:likeCount - 1];
    [post saveInBackgroundWithBlock: completion];
}

+ (void)bookmarkPost:(Post *)post withUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion {
    PFRelation *relation = [post relationForKey:@"bookmarkRelation"];
    [relation addObject:user];
    [post saveInBackgroundWithBlock:completion];
}

+ (void)unbookmarkPost:(Post *)post withUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion {
    PFRelation *relation = [post relationForKey:@"bookmarkRelation"];
    [relation removeObject:user];
    [post saveInBackgroundWithBlock:completion];
}
 
- (NSComparisonResult)comparewithPost:(Post *)post {
    NSDate *firstDate = self.createdAt;
    NSDate *secondDate = post.createdAt;

    NSTimeInterval timeSinceFirstPosted = [firstDate timeIntervalSinceNow];
    NSTimeInterval timeSinceSecondPosted = [secondDate timeIntervalSinceNow];
    
    if ([self.likeCount doubleValue] / timeSinceFirstPosted > [post.likeCount doubleValue] / timeSinceSecondPosted) {
        return NSOrderedDescending;
    } else if ([self.likeCount doubleValue] / timeSinceFirstPosted == [post.likeCount doubleValue] / timeSinceSecondPosted) {
        return NSOrderedSame;
    } else {
        return NSOrderedAscending;
    }
}

@end
