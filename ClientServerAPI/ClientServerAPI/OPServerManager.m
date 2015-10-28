//
//  OPServerManager.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPServerManager.h"

#import "OPAccessToken.h"

#import "OPUser.h"
#import "OPGroup.h"
#import "OPPost.h"
#import "OPComment.h"

#import "AFNetworking.h"

#import "OPLoginViewController.h"

@interface OPServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;

// that property will store accessToken for future requests to the server
@property (strong, nonatomic) OPAccessToken *accessToken;

@end

@implementation OPServerManager

+ (OPServerManager *)sharedManager {
    
    static OPServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[OPServerManager alloc] init];
        
        [manager authorizeUser:^(OPUser *user) {
            
        }];
        
    });
    
    return manager;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        NSURL *url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    
    return self;
}

- (void)authorizeUser:(void(^)(OPUser *user)) completion {
    
    OPLoginViewController *vc = [[OPLoginViewController alloc] initWithCompletionBlock:^(OPAccessToken *token)
    {
        self.accessToken = token; // accessToken for the present = 0
        
        self.currentUserID = token.userID;
        
        [self.delegate ownerIDForWallIsFound:self];
        
        if (token) {
            
            [self getUser:token.userID
                onSuccess:^(OPUser *user) {
                    
                    if (completion) {
                        
                        completion(user);
                    }
                    
                    self.currentUserID = [NSString stringWithFormat:@"%i", user.userID];
                    
                }
                onFailure:^(NSError *error, NSInteger statusCode)
             {
                 
                 if (completion) {
                     
                     completion(nil);
                 }
                 
             }];
            
        } else if (completion) {
            
            completion(nil);
        }
        
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController *mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nav animated:YES completion:nil];
    
}

- (void)getUser:(NSString *)userID
      onSuccess:(void(^)(OPUser *user))success
      onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID, @"user_ids",
                            @"photo_50", @"fields", nil];
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"JSON : %@", responseObject);
         
         NSArray *dictsArray = [responseObject objectForKey:@"response"];
         
         if ([dictsArray count] > 0) {
             
             OPUser *user = [[OPUser alloc] initWithServerResponse:[dictsArray firstObject]];
             
             if (success) {
                 success(user);
             }
         } else {
             if (failure) {
                 failure(nil, operation.response.statusCode);
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void)getUsersWithUidsArray:(NSString *)userUidsString
                    onSuccess:(void(^)(NSArray *users)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userUidsString, @"user_ids",
                            @"photo_50", @"fields", nil];
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"JSON : %@", responseObject);
         
         NSArray *dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray *usersArray = [NSMutableArray array];
         
         for (NSDictionary *dict in dictsArray) {
             
             OPUser *user = [[OPUser alloc] initWithServerResponse:dict];
             
             [usersArray addObject:user];
         }
         
         if (success) {
             success([usersArray copy]);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void)getGroupsWithUidsArray:(NSString *)groupUidsString
                     onSuccess:(void(^)(NSArray *groups)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *groupParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 groupUidsString, @"group_ids", nil];
    
    [self.requestOperationManager
     GET:@"groups.getById"
     parameters:groupParams
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"JSON : %@", responseObject);
         
         NSArray *dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray *groupsArray = [NSMutableArray array];
         
         for (NSDictionary *dict in dictsArray) {
             
             OPGroup *group = [[OPGroup alloc] initWithServerResponse:dict];
             
             [groupsArray addObject:group];
         }
         
         if (success) {
             success([groupsArray copy]);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
}

- (void)getUserWall:(NSString *) userID
         withOffset:(NSInteger) offset
              count:(NSInteger) count
      onSuccess:(void(^)(NSArray *posts)) success
      onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID, @"owner_id",
                            @(offset), @"offset",
                            @(count), @"count",
                            @"all", @"filter", nil];
    
    [self.requestOperationManager
     GET:@"wall.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"wall.get = JSON : %@", responseObject);
         
         NSArray *dictsArray = [responseObject objectForKey:@"response"];
         
         id countOfPosts;
         
         if ([dictsArray count] > 1) {
             countOfPosts = [dictsArray firstObject];
             dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, (int)[dictsArray count] - 1)];
         } else {
             dictsArray = nil;
         }
         
         NSMutableArray *objectsArray = [NSMutableArray array];
         
         for (NSDictionary *dict in dictsArray) {
             
             OPPost *post = [[OPPost alloc] initWithServerResponse:dict];
             
             [objectsArray addObject:post];
         }
         
         if ([objectsArray count]) {
             [objectsArray insertObject:countOfPosts atIndex:0];
         }
         
         if (success) {
             success([objectsArray copy]);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void)getPostById:(NSString *)postId
          onSuccess:(void(^)(OPPost *profile)) success
          onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            postId, @"posts",
                            @"1", @"extended",
                            @"city, country, place, description", @"fields",
                            @(5.37), @"v", nil];
    
    [self.requestOperationManager
     GET:@"wall.getById"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"wall.getById : %@", responseObject);
         
         NSDictionary *dict = [responseObject objectForKey:@"response"];
         
         OPPost *postProfile = [[OPPost alloc] initPostProfileWithServerResponse:dict];
         
         if (success) {
             success(postProfile);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void)getLikesForOwnerID:(NSInteger) ownerID
              itemID:(NSInteger) itemID
          withOffset:(NSInteger) offset
               count:(NSInteger) count
           onSuccess:(void(^)(NSArray *users)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"post", @"type",
                            @(ownerID), @"owner_id",
                            @(itemID), @"item_id",
                            @(offset), @"offset",
                            @(count), @"count",
                            @"1", @"extended",
                            @"photo_50", @"fields",
                            @(5.37), @"v", nil];
    
    [self.requestOperationManager
     GET:@"likes.getList"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"Array of likes : %@", responseObject);
         
         NSArray *dictsArray = [ [responseObject objectForKey:@"response"] objectForKey:@"items"];
         
         NSMutableArray *usersArray = [NSMutableArray array];
         
         for (NSDictionary *dict in dictsArray) {
             
             OPUser *user = [[OPUser alloc] initWithServerResponse:dict];
             
             [usersArray addObject:user];
         }
         
         if (success) {
             
             success([usersArray copy]);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
}

- (void) getCommentsForOwner:(NSInteger) ownerID
                        post:(NSInteger) postID
                  withOffset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray *comments)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(ownerID), @"owner_id",
                            @(postID), @"post_id",
                            @(offset), @"offset",
                            @(count), @"count",
                            @"1", @"extended",
                            @"photo_50", @"fields",
                            @(5.37), @"v", nil];
    
    [self.requestOperationManager
     GET:@"wall.getComments"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"Array of comments : %@", responseObject);

         NSArray *dictsArray = [ [responseObject objectForKey:@"response"] objectForKey:@"items"];
         
         NSMutableArray *commentsArray = [NSMutableArray array];
         
         for (NSDictionary *dict in dictsArray) {
             
             OPComment *comment = [[OPComment alloc] initWithServerResponse:dict];
             
             if (comment.ownerID > 0) {
                 
                 NSArray *profilesArray = [ [responseObject objectForKey:@"response"] objectForKey:@"profiles"];
                 
                 for (NSDictionary *profileDict in profilesArray) {
                     
                     if ( comment.ownerID == [[profileDict objectForKey:@"id"] integerValue] ) {
                         
                         OPUser *user = [[OPUser alloc] initWithServerResponse:profileDict];
                         
                         comment.userAsOwner = user;
                         
                         break;
                     }
                 }
                 
             } else if (comment.ownerID < 0) {
                 
                 NSArray *groupsArray = [ [responseObject objectForKey:@"response"] objectForKey:@"groups"];
                 
                 for (NSDictionary *groupDict in groupsArray) {
                     
                     if ( comment.ownerID == [[groupDict objectForKey:@"id"] integerValue] ) {
                         
                         OPUser *user = [[OPUser alloc] initWithServerResponse:groupDict];
                         
                         comment.userAsOwner = user;
                         
                         break;
                     }
                 }

             }
             
             [commentsArray addObject:comment];
         }
         
         if (success) {
             
             success([commentsArray copy]);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
    
}

- (void) getIsLikedInfoForUser:(NSInteger) userID
                          owner:(NSInteger) ownerID
                           item:(NSInteger) itemID
                      onSuccess:(void(^)(BOOL liked)) success
                      onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(userID), @"user_id",
                            @"post", @"type",
                            @(ownerID), @"owner_id",
                            @(itemID), @"item_id",
                            self.accessToken.token, @"access_token",
                            @(5.37), @"v", nil];
    
    [self.requestOperationManager
     GET:@"likes.isLiked"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         BOOL isLiked = [ [ [responseObject objectForKey:@"response"] objectForKey:@"liked"] boolValue];
         
         if (success) {
             success(isLiked);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void) addLikeForItem:(NSInteger) itemID
                  owner:(NSInteger) ownerID
              onSuccess:(void(^)(NSInteger count)) success
              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"post", @"type",
                            @(ownerID), @"owner_id",
                            @(itemID), @"item_id",
                            self.accessToken.token, @"access_token",
                            @(5.37), @"v", nil];
    
    [self.requestOperationManager
     GET:@"likes.add"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"count of likes : %@", responseObject);
         
         NSInteger likesCount = [ [ [responseObject objectForKey:@"response"] objectForKey:@"likes"] integerValue];
         
         if (success) {
             success(likesCount);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void) deleteLikeForItem:(NSInteger) itemID
                  owner:(NSInteger) ownerID
              onSuccess:(void(^)(NSInteger count)) success
              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"post", @"type",
                            @(ownerID), @"owner_id",
                            @(itemID), @"item_id",
                            self.accessToken.token, @"access_token",
                            @(5.37), @"v", nil];
    
    [self.requestOperationManager
     GET:@"likes.delete"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"count of likes : %@", responseObject);
         
         NSInteger likesCount = [ [ [responseObject objectForKey:@"response"] objectForKey:@"likes"] integerValue];
         
         if (success) {
             success(likesCount);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void) postText:(NSString *) text
       onUserWall:(NSString *)userID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     userID, @"owner_id",
     self.accessToken.token, @"access_token",
     text, @"message", nil];
    
    [self.requestOperationManager
     POST:@"wall.post"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"wall.post = JSON : %@", responseObject);
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void) postComment:(NSString *) text
             forPost:(NSInteger) postID
         onOwnerWall:(NSInteger) ownerID
           onSuccess:(void(^)(id result)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @(ownerID), @"owner_id",
     @(postID), @"post_id",
     self.accessToken.token, @"access_token", // 4.14
     text, @"text", nil];
    
    [self.requestOperationManager
     POST:@"wall.addComment"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSLog(@"wall.addComment = JSON : %@", responseObject);
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
   
}

@end
