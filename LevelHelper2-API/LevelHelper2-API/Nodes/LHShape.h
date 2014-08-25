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

 Note: LHShape cannot yet display textures but only colored shapes, As soon as Apple adds this functionality into SpriteKit, LevelHelper will support it also.
 */


@interface LHShape : SKShapeNode <LHNodeProtocol, LHNodeAnimationProtocol, LHNodePhysicsProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;



/**
 Returns the size of the shape node by computing the bounding box of the points.
 */
-(CGSize)size;

/**
 Returns the outline points of the shape. Array with NSValue with CGPoint.
 */
-(NSMutableArray*)outlinePoints;
@end
