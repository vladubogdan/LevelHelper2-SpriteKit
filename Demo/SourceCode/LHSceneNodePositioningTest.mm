//
//  LHSceneNodePositioningTest
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneNodePositioningTest.h"

@implementation LHSceneNodePositioningTest

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/positioningTest.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        
        
    }
    
    return self;
}

@end
