//
//  OPComment.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 21.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPServerObject.h"

@class OPUser;
@class OPGroup;

@interface OPComment : OPServerObject

@property (assign, nonatomic) NSInteger ID;
@property (assign, nonatomic) NSInteger date;
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) NSInteger ownerID;

@property (strong, nonatomic) OPUser *userAsOwner;
@property (strong, nonatomic) OPGroup *groupAsOwner;

@end
