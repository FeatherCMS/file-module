//
//  FileRouter.swift
//  FileModule
//
//  Created by Tibor Bödecs on 2020. 06. 03..
//

import FeatherCore

struct FileRouter: ViperRouter {

    let fileAdmin = FileAdminController()
    
    func adminRoutesHook(args: HookArguments) {
        let routes = args["routes"] as! RoutesBuilder
        
        let modulePath = routes.grouped(FileModule.pathComponent)
        modulePath
            .grouped(UserAccessMiddleware(name: "file.browser.list"))
            .get("browser", use: fileAdmin.browserView)
        
        let directoryPath = modulePath.grouped("directory")
            .grouped(UserAccessMiddleware(name: "file.browser.create"))
        directoryPath.get(use: fileAdmin.directoryView)
        directoryPath.post(use: fileAdmin.directory)
        
        let uploadPath = modulePath.grouped("upload")
            .grouped(UserAccessMiddleware(name: "file.browser.create"))
        uploadPath.get(use: fileAdmin.uploadView)
        uploadPath.post(use: fileAdmin.upload)
        
        let deletePath = modulePath.grouped("delete")
            .grouped(UserAccessMiddleware(name: "file.browser.delete"))
        deletePath.get(use: fileAdmin.deleteView)
        deletePath.post(use: fileAdmin.delete)
    }
    
}
