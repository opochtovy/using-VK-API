//
//  OPServerManager.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPUser;
@class OPPost;

@protocol OPServerManagerDelegate;

@interface OPServerManager : NSObject

@property (strong, nonatomic, readonly) OPUser *currentUser;
@property (strong, nonatomic) NSString *currentUserID;

@property (weak, nonatomic) id <OPServerManagerDelegate> delegate;

// singleton
+ (OPServerManager *)sharedManager;

// authorization method to VK API
- (void)authorizeUser:(void(^)(OPUser *user)) completion;

- (void)getUser:(NSString *)userID
      onSuccess:(void(^)(OPUser *user))success
      onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getUsersWithUidsArray:(NSString *)userUidsString
                    onSuccess:(void(^)(NSArray *users)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getUserWall:(NSString *) userID
         withOffset:(NSInteger) offset
              count:(NSInteger) count
           onSuccess:(void(^)(NSArray *posts)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void) postText:(NSString *) text
      onUserWall:(NSString *)userID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getGroupsWithUidsArray:(NSString *)groupUidsString
                    onSuccess:(void(^)(NSArray *groups)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getPostById:(NSString *)postId
          onSuccess:(void(^)(OPPost *profile)) success
          onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getLikesForOwnerID:(NSInteger) ownerID
          itemID:(NSInteger) itemID
          withOffset:(NSInteger) offset
              count:(NSInteger) count
          onSuccess:(void(^)(NSArray *users)) success
          onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void) getIsLikedInfoForUser:(NSInteger) userID
                         owner:(NSInteger) ownerID
                          item:(NSInteger) itemID
                     onSuccess:(void(^)(BOOL liked)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// addLikeForPost
- (void) addLikeForItem:(NSInteger) itemID
                  owner:(NSInteger) ownerID
              onSuccess:(void(^)(NSInteger count)) success
              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// deleteLikeForPost
- (void) deleteLikeForItem:(NSInteger) itemID
                  owner:(NSInteger) ownerID
              onSuccess:(void(^)(NSInteger count)) success
              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void) getCommentsForOwner:(NSInteger) ownerID
                        post:(NSInteger) postID
                  withOffset:(NSInteger) offset
                       count:(NSInteger) count
                     onSuccess:(void(^)(NSArray *comments)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void) postComment:(NSString *) text
             forPost:(NSInteger) postID
              onOwnerWall:(NSInteger) ownerID
           onSuccess:(void(^)(id result)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

@end

// OPServerManagerDelegate is a delegate protocol to transmit currentUserID from OPServerManager to OPWallViewController after successful login to VK API
@protocol OPServerManagerDelegate //<NSObject>

@required
- (void)ownerIDForWallIsFound:(OPServerManager *) manager;

@end
