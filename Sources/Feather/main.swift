//
//  main.swift
//  Feather
//
//  Created by Tibor Bodecs on 2019. 12. 17..
//

import FeatherCore

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
feather.setMaxUploadSize("10mb")

try feather.configure([
    /// core
    SystemBuilder(),
    UserBuilder(),
    ApiBuilder(),
    AdminBuilder(),
    FrontendBuilder(),
    
    FileBuilder()
])

/// reset resources folder if we're in debug mode
if feather.app.isDebug {
    try feather.reset(resourcesOnly: true)
}

try feather.start()
