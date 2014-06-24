//
//  LHGameWorldNode.mm
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHGameWorldNode.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

@implementation LHGameWorldNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SUPER_DEALLOC();
}

+ (instancetype)gameWorldNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initGameWorldNodeWithDictionary:dict
                                                                  parent:prnt]);
}

- (instancetype)initGameWorldNodeWithDictionary:(NSDictionary*)dict
                                         parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
    
        SKScene* scene = [prnt scene];
        self.position = CGPointMake(0, scene.size.height);
    }
    
    return self;
}


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    [_nodeProtocolImp update:currentTime delta:dt];
}

@end
