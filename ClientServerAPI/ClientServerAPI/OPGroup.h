//
//  OPGroup.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 13.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPServerObject.h"

@interface OPGroup : OPServerObject

@property (assign, nonatomic) NSInteger ID;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *imageURL;

- (id)initGroupForPostProfileWithServerResponse:(NSDictionary *) responseObject;

@end
