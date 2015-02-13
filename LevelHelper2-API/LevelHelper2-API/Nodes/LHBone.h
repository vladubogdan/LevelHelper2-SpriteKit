//
//  LHBone.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
/**
 LHBone class is used to load a bone object from a level file.
 */

@class LHBoneNodes;

@interface LHBone : SKNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(SKNode*)prnt;


-(float)maxAngle;
-(float)minAngle;
-(BOOL)rigid;

-(BOOL)isRoot;
-(LHBone*)rootBone;
-(LHBoneNodes*)rootBoneNodes;

@end
