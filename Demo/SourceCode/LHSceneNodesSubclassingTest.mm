//
//  LHSceneNodesSubclassingTest.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneNodesSubclassingTest.h"

#import "BlueRobotSprite.h"

@implementation LHSceneNodesSubclassingTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/subclassingDemo.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"NODES SUBLCASSING DEMO\nAll node types available in LevelHelper can be subclassed in order to add your own game logic.\nCheck LHSceneNodesSubclassingTest for how to do it.\nBlue robot is of class \"BlueRobotSprite\" while the pink robot is a generic \"LHSprite\" class.\nThe node is of class \"MyCustomNode\" and the blue outline is draw by the custom class."];
    }
    
    // done
	return self;
}

-(Class)createNodeObjectForSubclassWithName:(NSString *)subclassTypeName superTypeName:(NSString *)superTypeName
{
    //you may ask why doesn't LevelHelper2-API do this - thats because the API does not have access to your own classes. NSClassFromString will return nil if the class in question is not imported in the file where it's executed.
    
    //DO NOT FORGET TO #import your class header.
    return NSClassFromString(subclassTypeName);
}

@end
