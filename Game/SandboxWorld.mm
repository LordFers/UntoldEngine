//
//  SandboxWorld.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/13/20.
//  Copyright © 2020 Untold Engine Studios. All rights reserved.
//

#include "SandboxWorld.h"
#include "CommonProtocols.h"
#include "Constants.h"
#include "U4DDirector.h"
#include "U4DCamera.h"
#include "U4DDirectionalLight.h"
#include "U4DCameraInterface.h"
#include "U4DCameraBasicFollow.h"
#include "U4DDebugger.h"
#include "U4DSkybox.h"
#include "U4DModelPipeline.h"

#include "Player.h"
#include "Field.h"
#include "Ball.h"
#include "PlayerStateIdle.h"
#include "U4DGameConfigs.h"

using namespace U4DEngine;

SandboxWorld::SandboxWorld(){
    
}

SandboxWorld::~SandboxWorld(){
    
}

void SandboxWorld::init(){
    
    /*----DO NOT REMOVE. THIS IS REQUIRED-----*/
    //Configures the perspective view, shadows, lights and camera.
    setupConfiguration();
    /*----END DO NOT REMOVE.-----*/
    
    //The following code snippets loads scene data, renders the characters and skybox.
    setEnableGrid(true);
    
    //load the config values
    U4DEngine::U4DGameConfigs *gameConfigs=U4DEngine::U4DGameConfigs::sharedInstance();
    
    gameConfigs->initConfigsMapKeys("dribblingBallSpeed","biasMoveMotion","arriveMaxSpeed","arriveStopRadius","arriveSlowRadius","dribblingDirectionSlerpValue",nullptr);
    
    gameConfigs->loadConfigsMapValues("gameConfigs.gravity");
    
    Player *player=new Player();
    if (player->init("player0")) {
        addChild(player);
        
        //render the right foot
        Foot *rightFoot=new Foot();

        std::string footName="rightfoot";
        footName+=std::to_string(0);

        if(rightFoot->init(footName.c_str())){

            player->setFoot(rightFoot);

        }
        
        player->changeState(PlayerStateIdle::sharedInstance());
    }
    
    
    
    Player *oppositePlayers[5];

    for(int i=0;i<5;i++){
        std::string name="oppositeplayer";
        name+=std::to_string(i);

        oppositePlayers[i]=new Player();

        if(oppositePlayers[i]->init(name.c_str())){
            addChild(oppositePlayers[i]);
            
            //render the right foot
            Foot *rightFoot=new Foot();

            std::string footName="rightfoot";
            footName+=std::to_string(i+1);

            if(rightFoot->init(footName.c_str())){

                oppositePlayers[i]->setFoot(rightFoot);

            }
        }

        oppositePlayers[i]->changeState(PlayerStateIdle::sharedInstance());
    }
    
    Field *field=new Field();
    if(field->init("field")){
        addChild(field);
    }
    
    Ball *ball=Ball::sharedInstance();
    if (ball->init("ball")) {
        addChild(ball);
    }
    
    U4DEngine::U4DModel *fieldGoals[2];

    for(int i=0;i<sizeof(fieldGoals)/sizeof(fieldGoals[0]);i++){

        std::string name="fieldgoal";

        name+=std::to_string(i);

        fieldGoals[i]=new U4DEngine::U4DModel();

        if(fieldGoals[i]->loadModel(name.c_str())){


            fieldGoals[i]->loadRenderingInformation();

            addChild(fieldGoals[i]);
        }

    }
    
    U4DEngine::U4DModel *bleachers[4];

    for(int i=0;i<sizeof(bleachers)/sizeof(bleachers[0]);i++){

        std::string name="bleacher";

        name+=std::to_string(i);

        bleachers[i]=new U4DEngine::U4DModel();

        if(bleachers[i]->loadModel(name.c_str())){


            bleachers[i]->loadRenderingInformation();

            addChild(bleachers[i]);
        }

    }
    
    
    //Instantiate the camera
    U4DEngine::U4DCamera *camera=U4DEngine::U4DCamera::sharedInstance();

    //Instantiate the camera interface and the type of camera you desire
    U4DEngine::U4DCameraInterface *cameraBasicFollow=U4DEngine::U4DCameraBasicFollow::sharedInstance();
    
    cameraBasicFollow->setParametersWithBoxTracking(ball,0.0,20.0,-25.0,U4DEngine::U4DPoint3n(-3.0,-3.0,-3.0),U4DEngine::U4DPoint3n(3.0,3.0,3.0));
    
    //set the camera behavior
    camera->setCameraBehavior(cameraBasicFollow);
    
}


void SandboxWorld::update(double dt){
    
    
}

//Sets the configuration for the engine: Perspective view, shadows, light
void SandboxWorld::setupConfiguration(){
    
    //Get director object
    U4DDirector *director=U4DDirector::sharedInstance();
    
    //Compute the perspective space matrix
    U4DEngine::U4DMatrix4n perspectiveSpace=director->computePerspectiveSpace(65.0f, director->getAspect(), 0.001f, 400.0f);
    director->setPerspectiveSpace(perspectiveSpace);
    
    //Compute the orthographic shadow space
    U4DEngine::U4DMatrix4n orthographicShadowSpace=director->computeOrthographicShadowSpace(-30.0f, 30.0f, -30.0f, 30.0f, -30.0f, 30.0f);
    director->setOrthographicShadowSpace(orthographicShadowSpace);
    
    //Get camera object and translate it to position
    U4DEngine::U4DCamera *camera=U4DEngine::U4DCamera::sharedInstance();

    U4DEngine::U4DVector3n cameraPosition(0.0,5.0,-17.0);

    
    //translate camera
    camera->translateTo(cameraPosition);
    
    //set origin point
    U4DVector3n origin(0,0,0);
    
    //Create light object, translate it and set diffuse and specular color
    U4DDirectionalLight *light=U4DDirectionalLight::sharedInstance();
    light->translateTo(10.0,10.0,-10.0);
    U4DEngine::U4DVector3n diffuse(0.5,0.5,0.5);
    U4DEngine::U4DVector3n specular(0.2,0.2,0.2);
    light->setDiffuseColor(diffuse);
    light->setSpecularColor(specular);
    
    addChild(light);
    
    //Set the view direction of the camera and light
    camera->viewInDirection(origin);
    
    light->viewInDirection(origin);
    
    //set the poly count to 5000. Default is 3000
    director->setPolycount(5000);
}
