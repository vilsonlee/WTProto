//
//  WTProtoLogging.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoLogging.h"

static void (*loggingFunction)(NSString *, va_list args) = NULL;
static bool WTLogEnabledValue = true;

bool WTLogEnabled() {
    return loggingFunction != NULL && WTLogEnabledValue;
}

void WTLog(NSString *format, ...) {
    va_list L;
    va_start(L, format);
    if (loggingFunction != NULL) {
        loggingFunction(format, L);
    }
    va_end(L);
}

void WTLogSetLoggingFunction(void (*function)(NSString *, va_list args)) {
    loggingFunction = function;
}

void WTLogSetEnabled(bool enabled) {
    WTLogEnabledValue = enabled;
}

