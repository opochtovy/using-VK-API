//
//  OPUser.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPServerObject.h"

@interface OPUser : OPServerObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSURL *imageURL;

@property (assign, nonatomic) NSInteger ID;
@property (assign, nonatomic) NSInteger userID;

@end
