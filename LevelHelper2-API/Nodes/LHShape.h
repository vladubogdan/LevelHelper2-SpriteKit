//
//  LHShape.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodePhysicsProtocol.h"

/**
 LHShape class is used to load and display a shape from a level file.
 Users can retrieve a shape objects by calling the scene (LHScene) childNodeWithName: method.
 Note: While the class cannot yet display textures but only colored shape, I hope that in the future Apple will add this functionality into SpriteKit.
 */


@interface LHShape : SKShapeNode <LHNodeProtocol, LHNodeAnimationProtocol, LHNodePhysicsProtocol>

+ (instancetype)shapeNodeWithDictionary:(NSDictionary*)dict
                                 parent:(SKNode*)prnt;


/**
 Returns the size of the shape node by computing the bounding box of the points.
 */
-(CGSize)size;

@end
