//
//  FileModule.swift
//  FileModule
//
//  Created by Tibor Bödecs on 2020. 06. 03..
//

import FeatherCore

final class FileModule: ViperModule {
    
    static var name: String = "file"
    
    var router: ViperRouter? { FileRouter() }

    static var bundleUrl: URL? {
        Bundle.module.resourceURL?.appendingPathComponent("Bundle")
    }

    func boot(_ app: Application) throws {
        app.hooks.register("admin-routes", use: (router as! FileRouter).adminRoutesHook)
        
        app.hooks.register("leaf-admin-menu", use: leafAdminMenuHook)
        app.hooks.register("user-permission-install", use: userPermissionInstallHook)
    }

    // MARK: - hooks
    func leafAdminMenuHook(args: HookArguments) -> LeafDataRepresentable {
        [
            "name": "File",
            "icon": "folder",
            "permission": "file.module.access",
            "items": LeafData.array([
                [
                    "url": "/admin/file/browser/",
                    "label": "Browser",
                    "permission": "file.browser.list",
                ],
            ])
        ]
    }
}
