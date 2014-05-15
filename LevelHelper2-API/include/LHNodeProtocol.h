//
//  LHNodeProtocol.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Most of the LevelHelper-2 nodes conforms to this protocol.
 */
@class LHScene;
@protocol LHNodeAnimationProtocol;
@protocol LHUserPropertyProtocol;
@protocol LHNodeProtocol <NSObject>

@required
////////////////////////////////////////////////////////////////////////////////

/**
 Returns the unique identifier of the node.
 */
-(NSString*)uuid;

/**
 Returns all tag values of the node.
 */
-(NSArray*)tags;
/**
 Returns the user property object assigned to this object or nil.
 */
-(id<LHUserPropertyProtocol>)userProperty;

/**
 Returns the scene to which this node belongs to.
 */
-(LHScene*)scene;

- (void)update:(NSTimeInterval)currentTime delta:(float)dt;

@optional
////////////////////////////////////////////////////////////////////////////////

/**
 Returns a node with the specified unique identifier or nil if that node is not found in the children hierarchy.
 */
-(id <LHNodeProtocol, LHNodeAnimationProtocol>)childNodeWithUUID:(NSString*)uuid;

/**
 Returns all children nodes that have the specified tag values. 
 If containsAny is true a node needs to have at least one tag value in common with the one passed to this function.
 If containsAny is false a node needs to have all tags exactly the same as the ones passed to this function.
 */
-(NSMutableArray*)childrenWithTags:(NSArray*)tagValue containsAny:(BOOL)any;

/**
 Returns all children nodes that are of specified class type.
 */
-(NSMutableArray*)childrenOfType:(Class)type;



-(BOOL)lateLoading;

@end
