//
//  U4DKeyPressedState.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 3/3/18.
//  Copyright © 2018 Untold Engine Studios. All rights reserved.
//

#include "U4DMacKeyPressedState.h"
#include "U4DControllerInterface.h"
#include "U4DMacKeyActiveState.h"

namespace U4DEngine {
    
    U4DMacKeyPressedState* U4DMacKeyPressedState::instance=0;
    
    U4DMacKeyPressedState::U4DMacKeyPressedState(){
        
    }
    
    U4DMacKeyPressedState::~U4DMacKeyPressedState(){
        
    }
    
    U4DMacKeyPressedState* U4DMacKeyPressedState::sharedInstance(){
        
        if (instance==0) {
            instance=new U4DMacKeyPressedState();
        }
        
        return instance;
        
    }
    
    void U4DMacKeyPressedState::enter(U4DMacKey *uMacKey){
        
        uMacKey->action();
        
        if (uMacKey->controllerInterface !=NULL) {
            uMacKey->controllerInterface->setReceivedAction(true);
        }
        
    }
    
    void U4DMacKeyPressedState::execute(U4DMacKey *uMacKey, double dt){
        
        
    }
    
    void U4DMacKeyPressedState::exit(U4DMacKey *uMacKey){
        
    }
    
}
