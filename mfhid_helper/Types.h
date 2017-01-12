//
//  Types.h.h
//  MFHID
//
//  Created by Terry Lewis on 12/1/17.
//  Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#ifndef Types_h_h
#define Types_h_h

typedef NS_ENUM(int, MFHIDHelperExitCode){
    MFHIDHelperExitCodeErrorUnknown = -1,
    MFHIDHelperExitCodeSuccess = 0,
    MFHIDHelperExitCodeErrorArgs = 1,
    MFHIDHelperExitCodeErrorSeteuid = 2,
    MFHIDHelperExitCodeErrorDriverNotFound = 3,
    MFHIDHelperExitCodeErrorFixingPermissions = 4,
    MFHIDHelperExitCodeErrorLoadingDriver = 5,
    MFHIDHelperExitCodeErrorUnloadingDriver = 6,
    MFHIDHelperExitCodeFailure = 100,
};

#endif /* Types_h_h */
