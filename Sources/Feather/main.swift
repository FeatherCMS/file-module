//
//  main.swift
//  Feather
//
//  Created by Tibor Bodecs on 2019. 12. 17..
//

import FeatherCore

import CommonModule
import SystemModule
import UserModule
import ApiModule
import AdminModule
import FrontendModule

import FileModule

/// setup metadata delegate object
Feather.metadataDelegate = FrontendMetadataDelegate()

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let feather = try Feather(env: env)
defer { feather.stop() }

feather.useSQLiteDatabase()
feather.useLocalFileStorage()
feather.usePublicFileMiddleware()

try feather.configure([
    /// core
    CommonBuilder(),
    SystemBuilder(),
    UserBuilder(),
    ApiBuilder(),
    AdminBuilder(),
    FrontendBuilder(),
    
    FileBuilder()
])

/// reset resources folder if we're in debug mode
if feather.app.isDebug {
    try feather.resetPublicFiles()
//    try feather.copyTemplatesIfNeeded()
}

try feather.start()
