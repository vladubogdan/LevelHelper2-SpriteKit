//
//  LHSceneLoadMultipleLevels.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneLoadMultipleLevels.h"

@implementation LHSceneLoadMultipleLevels

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/multiLevelsPinkRobots.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"Loading Multiple Levels\nPink Robots are in the initial level\nBlue robots are in another level loaded and added as child"];
     
        
        LHScene* blueRobotsScene = [LHScene sceneWithContentOfFile:@"PUBLISH_FOLDER/multiLevelsBlueRobots.lhplist"];
        
        //first method
        //when you search for children you should use the scene object for each level to retrieve the children.
        {
            [self addChild:blueRobotsScene];
            
            //you can also offset the second level
            //[[blueRobotsScene gameWorldNode] setPosition:CGPointMake(0, 200)];
        }
        
        
        //second method - were you add the children so you dont have to deal with a LHScene but directly with the children
        //CAREFULL - if second scene has object with same unique names as first scene you may have problems retrieving children by name
        
        //comment first method and uncomment second method
        {
//            for(SKNode* node in [[blueRobotsScene uiNode] children]){
//                [node removeFromParent];
//                [[self uiNode] addChild:node];
//            }
//
//            for(SKNode* node in [[blueRobotsScene gameWorldNode] children]){
//                [node removeFromParent];
//                [[self gameWorldNode] addChild:node];
//            }
//
//            for(SKNode* node in [[blueRobotsScene backUINode] children]){
//                [node removeFromParent];
//                [[self backUINode] addChild:node];
//            }
        }
        
    }
    
    return self;
}



@end
