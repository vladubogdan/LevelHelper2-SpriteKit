//
//  LHParallax.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
/**
 LHParallax class is used to load a parallax object from a level file.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHParallax : SKNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;



/**
 Returns the followed node or nil if no node is being fallowed;
 */
-(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)followedNode;

/**
 Set a node that should be followed by this parallax.
 @param node The node that should be followed by the parallax. Usually a camera node.
 */
-(void)followNode:(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)node;

@end
