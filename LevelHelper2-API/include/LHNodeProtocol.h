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
 @param uuid The unique idenfier of the node.
 @return A node or or nil.
 */
-(id <LHNodeProtocol, LHNodeAnimationProtocol>)childNodeWithUUID:(NSString*)uuid;

/**
 Returns all children nodes that have the specified tag values.
 @param tagValues An array containing tag names. Array of NSString's.
 @param any Specify if all or just one tag value of the node needs to be in common with the passed ones.
 @return An array of nodes.
 */
-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any;

/**
 Returns all children nodes that are of specified class type.
 @param type A "Class" type.
 @return An array with all the found nodes of the specified class.
 */
-(NSMutableArray*)childrenOfType:(Class)type;



-(BOOL)lateLoading;

@end
