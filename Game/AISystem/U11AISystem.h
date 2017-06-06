//
//  AISystem.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 5/21/17.
//  Copyright © 2017 Untold Game Studio. All rights reserved.
//

#ifndef AISystem_hpp
#define AISystem_hpp

#include <stdio.h>
#include "U11AttackSystemInterface.h"
#include "U11DefenseSystemInterface.h"
#include "U11RecoverSystemInterface.h"
#include "U11AIAnalyzer.h"

class U11Team;
class U11AIStateManager;
class U11AIStateInterface;

class U11AISystem {
    
private:
    
    U11AttackSystemInterface *attackSystem;
    U11DefenseSystemInterface *defenseSystem;
    U11RecoverSystemInterface *recoverSystem;
    U11AIStateManager *stateManager;
    U11Team *team;
    
public:
    
    U11AISystem(U11Team *uTeam, U11DefenseSystemInterface *uDefenseSystem, U11AttackSystemInterface *uAttackSystem, U11RecoverSystemInterface *uRecoverSystem);
    
    ~U11AISystem();
    
    void setAttackAISystem(U11AttackSystemInterface *uAttackSystem);
    
    void setDefendAISystem(U11DefenseSystemInterface *uDefenseSystem);
    
    U11Team *getTeam();
    
    U11AIStateManager *getStateManager();
    
    void changeState(U11AIStateInterface* uState);
    
    U11AttackSystemInterface *getAttackAISystem();
    
    U11DefenseSystemInterface *getDefenseAISystem();
    
    U11RecoverSystemInterface *getRecoverAISystem();
    
};

#endif /* AISystem_hpp */
