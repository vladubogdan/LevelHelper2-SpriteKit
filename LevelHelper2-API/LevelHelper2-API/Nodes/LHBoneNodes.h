//
//  LHBoneNodes.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHBoneNodes class serves as a container for all the nodes connected to a bone structure.
 */


@interface LHBoneNodes : SKNode <LHNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(SKNode*)prnt;


@end
