//
//  LHUserPropertyProtocol.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 29/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 LevelHelper 2 nodes that can have user properties conform to this protocol.
 */
@protocol LHUserPropertyProtocol <NSObject>

@required

/**
 The designeted initialized for the user property declared class.
 @param node The node on which this class object is created.
 @return A valid class of the required type.
 */
+(id) customClassInstanceWithNode:(id)node;

/**
 The name of the user declared class.
 */
-(NSString*) className;

/**
 The node on which this user declared class was set.
 */
-(id) node;

/**
 This loads all the user properties member variables as they were set inside LevelHelper.
 @param dictionary The information that needs to be loaded.
 */
-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary;


@end
