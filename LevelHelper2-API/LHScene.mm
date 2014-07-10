//
//  LHScene.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHScene.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"
#import "LHSprite.h"
#import "LHBezier.h"
#import "LHShape.h"
#import "LHWater.h"
#import "LHNode.h"
#import "LHAsset.h"
#import "LHGravityArea.h"
#import "LHParallax.h"
#import "LHParallaxLayer.h"
#import "LHCamera.h"
#import "LHRopeJointNode.h"
#import "LHWeldJointNode.h"
#import "LHRevoluteJointNode.h"
#import "LHDistanceJointNode.h"
#import "LHPrismaticJointNode.h"
#import "LHGameWorldNode.h"
#import "LHUINode.h"
#import "LHBackUINode.h"
#import "LHBox2dCollisionHandling.h"

@implementation LHScene
{
    __unsafe_unretained LHGameWorldNode*    _gameWorldNode;
    __unsafe_unretained LHUINode*           _uiNode;
    __unsafe_unretained LHBackUINode*       _backUINode;
    
#if LH_USE_BOX2D
    LHBox2dCollisionHandling* _box2dCollision;
#endif
    
    NSMutableArray* lateLoadingNodes;//gets nullified after everything is loaded
    

    LHNodeProtocolImpl*         _nodeProtocolImp;
    
    
    
    NSMutableDictionary* loadedTextures;
    NSMutableDictionary* loadedTextureAtlases;
    NSDictionary* tracedFixtures;
    
    NSArray* supportedDevices;
    CGSize  designResolutionSize;
    CGPoint designOffset;
    
    NSString* relativePath;
    
    CGPoint ropeJointsCutStartPt;
    
    NSMutableDictionary* _loadedAssetsInformations;
    
    CGRect gameWorldRect;
    
    NSTimeInterval previousUpdateTime;
}


-(void)dealloc{

#if LH_USE_BOX2D
    LH_SAFE_RELEASE(_box2dCollision);
#endif
    
    [self removeAllActions];
    [self removeAllChildren];

    _gameWorldNode = nil;
    _uiNode = nil;
    _backUINode = nil;
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(lateLoadingNodes);
    LH_SAFE_RELEASE(relativePath);
    LH_SAFE_RELEASE(loadedTextures);
    LH_SAFE_RELEASE(loadedTextureAtlases);
    LH_SAFE_RELEASE(tracedFixtures);
    LH_SAFE_RELEASE(supportedDevices);
    LH_SAFE_RELEASE(_loadedAssetsInformations);
    
    LH_SUPER_DEALLOC();
}

#if TARGET_OS_IPHONE
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile{
    return LH_AUTORELEASED([[self alloc] initWithContentOfFile:levelPlistFile]);
}
#else
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size{
    return LH_AUTORELEASED([[self alloc] initWithContentOfFile:levelPlistFile size:size]);
}
#endif


#if TARGET_OS_IPHONE
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile
#else
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size
#endif
{
    
#if TARGET_OS_IPHONE
#else
    NSLog(@"Please note that support for Mac OS platform is partial. Some key elements are missing from SpriteKit on OS X SDK. When Apple updates the SDK i will be able to give full support.");
#endif
    
    
    NSString* path = [[NSBundle mainBundle] pathForResource:[levelPlistFile stringByDeletingPathExtension]
                                                     ofType:[levelPlistFile pathExtension]];
    if(!path)return nil;
    
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if(!dict)return nil;

    int aspect = [dict intForKey:@"aspect"];
    CGSize designResolution = [dict sizeForKey:@"designResolution"];

    NSArray* devsInfo = [dict objectForKey:@"devices"];
    NSMutableArray* devices = [NSMutableArray array];
    for(NSDictionary* devInf in devsInfo){
        LHDevice* dev = [LHDevice deviceWithDictionary:devInf];
        [devices addObject:dev];
    }

    #if TARGET_OS_IPHONE
    LHDevice* curDev = [LHUtils currentDeviceFromArray:devices];
    #else
    LHDevice* curDev = [LHUtils deviceFromArray:devices withSize:size];
    #endif

    CGPoint childrenOffset = CGPointZero;
    
    CGSize sceneSize = curDev.size;
    float ratio = curDev.ratio;
    sceneSize.width = sceneSize.width/ratio;
    sceneSize.height = sceneSize.height/ratio;
    
    SKSceneScaleMode scaleMode = SKSceneScaleModeFill;
    if(aspect == 0)//exact fit
    {
        sceneSize = designResolution;
    }
    else if(aspect == 1)//no borders
    {
        float scalex = sceneSize.width/designResolution.width;
        float scaley = sceneSize.height/designResolution.height;
        scalex = scaley = MAX(scalex, scaley);
        
        childrenOffset.x = (sceneSize.width/scalex - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height/scaley - designResolution.height)*0.5;
        sceneSize = CGSizeMake(sceneSize.width/scalex, sceneSize.height/scaley);
        
        scaleMode = SKSceneScaleModeAspectFill;
    }
    else if(aspect == 2)//show all
    {
        childrenOffset.x = (sceneSize.width - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height - designResolution.height)*0.5;
    }


    if (self = [super initWithSize:sceneSize])
    {
        relativePath = [[NSString alloc] initWithString:[levelPlistFile stringByDeletingLastPathComponent]];
        
        designResolutionSize = designResolution;
        designOffset         = childrenOffset;
        self.scaleMode       = scaleMode;
        
        NSDictionary* tracedFixInfo = [dict objectForKey:@"tracedFixtures"];
        if(tracedFixInfo){
            tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFixInfo];
        }
        supportedDevices = [[NSArray alloc] initWithArray:devices];
        
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];

        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        if([dict boolForKey:@"useGlobalGravity"])
        {
            //more or less the same as box2d
            CGPoint gravityVector = [dict pointForKey:@"globalGravityDirection"];
            float gravityForce    = [dict floatForKey:@"globalGravityForce"];
            
            CGPoint gravity = CGPointMake(gravityVector.x*gravityForce,
                                          gravityVector.y*gravityForce);
            [self setGlobalGravity:gravity];
        }
        
        
        [self setBackgroundColor:[dict colorForKey:@"backgroundColor"]];
        
        
        [self createPhysicsBoundaries:dict];
        
        
        [self createGameWorld:dict];

        
        [self performLateLoading];

#if LH_USE_BOX2D
        _box2dCollision = [[LHBox2dCollisionHandling alloc] initWithScene:self];
#else//spritekit
        [[self physicsWorld] setContactDelegate:(id<SKPhysicsContactDelegate>)self];
#endif
        
    }
    return self;
}

-(void)performLateLoading{
    if(!lateLoadingNodes)return;
    
    NSMutableArray* lateLoadingToRemove = [NSMutableArray array];
    for(SKNode* node in lateLoadingNodes){
        if([node respondsToSelector:@selector(lateLoading)]){
            if([(id<LHNodeProtocol>)node lateLoading]){
                [lateLoadingToRemove addObject:node];
            }
        }
    }
    [lateLoadingNodes removeObjectsInArray:lateLoadingToRemove];
    if([lateLoadingNodes count] == 0){
        LH_SAFE_RELEASE(lateLoadingNodes);
    }
}

-(void)createPhysicsBoundaries:(NSDictionary*)dict
{
    NSDictionary* phyBoundInfo = [dict objectForKey:@"physicsBoundaries"];
    if(phyBoundInfo)
    {
#if TARGET_OS_IPHONE
        CGSize scr = LH_SCREEN_RESOLUTION;
#else
        CGSize scr = self.size;
#endif
        NSString* rectInf = [phyBoundInfo objectForKey:[NSString stringWithFormat:@"%dx%d", (int)scr.width, (int)scr.height]];
        if(!rectInf){
            rectInf = [phyBoundInfo objectForKey:@"general"];
        }
        
        if(rectInf){
            CGRect bRect = LHRectFromString(rectInf);
            CGSize designSize = [self designResolutionSize];
            CGPoint offset = [self designOffset];
            CGRect skBRect = CGRectMake(bRect.origin.x*designSize.width + offset.x,
                                        self.size.height - bRect.origin.y*designSize.height + offset.y,
                                        bRect.size.width*designSize.width ,
                                        -bRect.size.height*designSize.height);
            
            {
                [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMinY(skBRect))
                                                    to:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMinY(skBRect))
                                              withName:@"LHPhysicsBottomBoundary"];
            }
            
            {
                [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMinY(skBRect))
                                                    to:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMaxY(skBRect))
                                              withName:@"LHPhysicsRightBoundary"];
                
            }
            
            {
                [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMaxY(skBRect))
                                                    to:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMaxY(skBRect))
                                              withName:@"LHPhysicsTopBoundary"];
            }
            
            {
                [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMaxY(skBRect))
                                                    to:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMinY(skBRect))
                                              withName:@"LHPhysicsLeftBoundary"];
            }
            
            
#if LH_DEBUG
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            CGPathRef pathRef = CGPathCreateWithRect(skBRect, nil);
            debugShapeNode.path = pathRef;
            CGPathRelease(pathRef);
            debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:1];
            [[self gameWorldNode] addChild:debugShapeNode];
#endif
        }
    }
}

-(void)createPhysicsBoundarySectionFrom:(CGPoint)from
                                     to:(CGPoint)to
                               withName:(NSString*)sectionName
{
#if LH_USE_BOX2D
    
    float PTM_RATIO = [self ptm];
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    b2Body* physicsBoundariesBody = [self box2dWorld]->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2EdgeShape groundBox;
    
    // top
    groundBox.Set(b2Vec2(from.x/PTM_RATIO,
                         from.y/PTM_RATIO),
                  b2Vec2(to.x/PTM_RATIO,
                         to.y/PTM_RATIO));
    physicsBoundariesBody->CreateFixture(&groundBox,0);
    
    
#else //spritekit
    
    SKNode* pNode = [SKNode node];
    pNode.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:from toPoint:to];
    pNode.physicsBody.dynamic = NO;
    [pNode setName:sectionName];
    [[self gameWorldNode] addChild:pNode];
    
#endif
    
}

-(void)createGameWorld:(NSDictionary*)dict
{
    NSDictionary* gameWorldInfo = [dict objectForKey:@"gameWorld"];
    if(gameWorldInfo)
    {
#if TARGET_OS_IPHONE
        CGSize scr = LH_SCREEN_RESOLUTION;
#else
        CGSize scr = self.size;
#endif
        
        NSString* rectInf = [gameWorldInfo objectForKey:[NSString stringWithFormat:@"%dx%d", (int)scr.width, (int)scr.height]];
        if(!rectInf){
            rectInf = [gameWorldInfo objectForKey:@"general"];
        }
        
        if(rectInf){
            CGRect bRect = LHRectFromString(rectInf);
            CGSize designSize = [self designResolutionSize];
            CGPoint offset = [self designOffset];
            
            gameWorldRect = CGRectMake(bRect.origin.x*designSize.width+ offset.x,
                                       (1.0f - bRect.origin.y)*designSize.height + offset.y,
                                       bRect.size.width*designSize.width ,
                                       -(bRect.size.height)*designSize.height);
//            gameWorldRect.origin.y -= sceneSize.height;
            
#if LH_DEBUG
            CGRect gameWorldRectT = gameWorldRect;
            gameWorldRectT.origin.x += 2;
            gameWorldRectT.size.width -= 4;
            gameWorldRectT.origin.y -= 2;
            gameWorldRectT.size.height += 4;
            
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            CGPathRef pathRef = CGPathCreateWithRect(gameWorldRectT,nil);
            debugShapeNode.path = pathRef;
            CGPathRelease(pathRef);
            
            debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:0 blue:1 alpha:1];
            [[self gameWorldNode] addChild:debugShapeNode];
#endif
        }
    }
}



-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath
{
    if(!loadedTextureAtlases){
        loadedTextureAtlases = [[NSMutableDictionary alloc] init];
    }
 
    SKTextureAtlas* textureAtlas = nil;
    if(atlasPath){
        textureAtlas = [loadedTextureAtlases objectForKey:atlasPath];
        if(!textureAtlas){
            textureAtlas = [SKTextureAtlas atlasNamed:atlasPath];
            if(textureAtlas){
                [loadedTextureAtlases setObject:textureAtlas forKey:atlasPath];
            }
        }
    }
    
    return textureAtlas;
}

-(SKTexture*)textureWithImagePath:(NSString*)imagePath
{
    if(!loadedTextures){
        loadedTextures = [[NSMutableDictionary alloc] init];
    }
    
    SKTexture* texture = nil;
    if(imagePath){
        texture = [loadedTextures objectForKey:imagePath];
        if(!texture){
            texture = [SKTexture textureWithImageNamed:imagePath];
            if(texture){
                [loadedTextures setObject:texture forKey:imagePath];
            }
        }
    }
    
    return texture;
}

-(CGRect)gameWorldRect{
    return gameWorldRect;
}

#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:[self gameWorldNode]];
        ropeJointsCutStartPt = location;
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:[self gameWorldNode]];
        
        for(LHRopeJointNode* rope in [self childrenOfType:[LHRopeJointNode class]]){
            if([rope canBeCut]){
                [rope cutWithLineFromPointA:ropeJointsCutStartPt
                                   toPointB:location];
            }
        }
    }
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}

#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    
    ropeJointsCutStartPt = location;
    NSArray* foundNodes = [self nodesAtPoint:location];
    for(SKNode* foundNode in foundNodes)
    {
        if(foundNode.physicsBody){
            touchedNode = foundNode;
            touchedNodeWasDynamic = touchedNode.physicsBody.affectedByGravity;
            [touchedNode.physicsBody setAffectedByGravity:NO];
            break;
        }
    }
    
    BOOL                dragActive = YES;
    NSEvent*            event = NULL;
    NSWindow            *targetWindow = [[NSApplication sharedApplication] mainWindow];
    
    while (dragActive) {
        event = [targetWindow nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
                                          untilDate:[NSDate distantFuture]
                                             inMode:NSEventTrackingRunLoopMode
                                            dequeue:YES];
        if(!event){
            continue;
        }
        switch ([event type])
        {
            case NSLeftMouseDragged:
            {
                CGPoint curLocation = [event locationInNode:self];
                
                if(touchedNode && touchedNode.physicsBody){
                    [touchedNode setPosition:curLocation];
                }
            }
                break;
                
                
            case NSLeftMouseUp:
                dragActive = NO;
                
                CGPoint curLocation = [event locationInNode:self];
                for(LHRopeJointNode* rope in ropeJoints){
                    if([rope canBeCut]){
                        [rope cutWithLineFromPointA:ropeJointsCutStartPt
                                           toPointB:curLocation];
                    }
                }
                
                if(touchedNode){
                    [touchedNode.physicsBody setAffectedByGravity:touchedNodeWasDynamic];
                    touchedNode = nil;
                }
                
                break;
                
            default:
                break;
        }
    }
}
#endif

-(LHGameWorldNode*)gameWorldNode
{
    if(!_gameWorldNode){
        for(SKNode* n in [self children]){
            if([n isKindOfClass:[LHGameWorldNode class]]){
                _gameWorldNode = (LHGameWorldNode*)n;
                break;
            }
        }
    }
    return _gameWorldNode;
}
-(LHUINode*)uiNode{
    if(!_uiNode){
        for(SKNode* n in [self children]){
            if([n isKindOfClass:[LHUINode class]]){
                _uiNode = (LHUINode*)n;
                break;
            }
        }
    }
    return _uiNode;
}

-(LHBackUINode*)backUINode{
    if(!_backUINode){
        for(SKNode* n in [self children]){
            if([n isKindOfClass:[LHBackUINode class]]){
                _backUINode = (LHBackUINode*)n;
                break;
            }
        }
    }
    return _backUINode;
}

-(NSString*)relativePath{
    return relativePath;
}

-(LHScene*)scene{
    return self;
}

#pragma mark- COLLISION HANDLING
#if LH_USE_BOX2D

-(BOOL)shouldDisableContactBetweenNodeA:(SKNode*)a
                               andNodeB:(SKNode*)b{
    return NO;
}

-(void)didBeginContactBetweenNodeA:(SKNode*)a
                          andNodeB:(SKNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse
{
    //nothing to do - users should overwrite this method
}

-(void)didEndContactBetweenNodeA:(SKNode*)a
                        andNodeB:(SKNode*)b
{
    //nothing to do - users should overwrite this method
}

#else

- (void)didBeginContact:(SKPhysicsContact *)contact{
    //nothing to do - users should overwrite this method
}
- (void)didEndContact:(SKPhysicsContact *)contact{
    //nothing to do - users should overwrite this method
}

#endif


- (void)update:(NSTimeInterval)currentTime{
   
    [self performLateLoading];
    
    if(previousUpdateTime == 0){
        previousUpdateTime = currentTime;
    }

    [self update:currentTime
           delta:currentTime - previousUpdateTime];
    
    [super update:currentTime];
    
    previousUpdateTime = currentTime;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

-(void)update:(NSTimeInterval)currentTime delta:(float)dt{
    [_nodeProtocolImp update:currentTime delta:dt];
}


#pragma mark - BOX2D INTEGRATION

#if LH_USE_BOX2D
-(b2World*)box2dWorld{
    return [[self gameWorldNode] box2dWorld];
}
-(float)ptm{
    return 32.0f;
}
-(b2Vec2)metersFromPoint:(CGPoint)point{
    return b2Vec2(point.x/[self ptm], point.y/[self ptm]);
}
-(CGPoint)pointFromMeters:(b2Vec2)vec{
    return CGPointMake(vec.x*[self ptm], vec.y*[self ptm]);
}
-(float)metersFromValue:(float)val{
    return val/[self ptm];
}
-(float)valueFromMeters:(float)meter{
    return meter*[self ptm];
}
#endif //LH_USE_BOX2D

-(CGPoint)globalGravity{
    return [[self gameWorldNode] gravity];
}
-(void)setGlobalGravity:(CGPoint)gravity{
    [[self gameWorldNode] setGravity:gravity];
}




#pragma mark - PRIVATES

-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName{
    if(!_loadedAssetsInformations){
        _loadedAssetsInformations = [[NSMutableDictionary alloc] init];
    }
    NSDictionary* info = [_loadedAssetsInformations objectForKey:assetFileName];
    if(!info){
        NSString* path = [[NSBundle mainBundle] pathForResource:assetFileName
                                                         ofType:@"plist"
                                                    inDirectory:[self relativePath]];
        if(path){
            info = [NSDictionary dictionaryWithContentsOfFile:path];
            if(info){
                [_loadedAssetsInformations setObject:info forKey:assetFileName];
            }
        }
    }
    return info;
}





-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [tracedFixtures objectForKey:uuid];
}

-(void)addLateLoadingNode:(SKNode*)node{
    if(!lateLoadingNodes) {
        lateLoadingNodes = [[NSMutableArray alloc] init];
    }
    [lateLoadingNodes addObject:node];
}

-(float)currentDeviceRatio{
    
#if TARGET_OS_IPHONE
    CGSize scrSize = LH_SCREEN_RESOLUTION;
#else
    CGSize scrSize = self.size;
#endif
    
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            return [dev ratio];
        }
    }
    return 1.0f;
}

-(CGSize)designResolutionSize{
    return designResolutionSize;
}
-(CGPoint)designOffset{
    return designOffset;
}

-(NSString*)currentDeviceSuffix{
    
#if TARGET_OS_IPHONE
    CGSize scrSize = LH_SCREEN_RESOLUTION;
#else
    CGSize scrSize = self.size;
#endif
    
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            NSString* suffix = [dev suffix];
            suffix = [suffix stringByReplacingOccurrencesOfString:@"@2x"
                                                       withString:@""];
            return suffix;
        }
    }
    return @"";
}
@end

