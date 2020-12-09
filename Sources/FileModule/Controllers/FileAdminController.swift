//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 06. 03..
//

import FeatherCore

fileprivate extension String {
    
    /// the file has an extension if the name contains a dot (also we can think of if it')
    var fileExt: String? {
        guard contains(".") else {
            return nil
        }
        return split(separator: ".").last.map(String.init)
    }
}

struct FileAdminController {
    
    struct File: LeafDataRepresentable {
        let name: String
        let key: String
        let ext: String?
        
        var leafData: LeafData {
            .dictionary([
                "name": name,
                "key": key,
                "ext": ext,
            ])
        }
    }
    
    // MARK: - browser
    
    func browserView(req: Request) -> EventLoopFuture<Response> {
        var key: String? = nil
        /// if there is a key, check if it exists
        var future: EventLoopFuture<Bool> = req.eventLoop.future(true)
        if let keyValue = try? req.query.get(String.self, at: "key"), !keyValue.isEmpty {
            future = req.fs.exists(key: keyValue)
            key = keyValue
        }
        
        /// check if directory exists, then make some assumption about the list items...
        return future.flatMap { exists -> EventLoopFuture<Response> in
            guard exists else {
                return req.eventLoop.future(error: Abort(.notFound))
            }
            return req.fs.list(key: key).mapEach { name -> File in
                var fileKey = name
                /// we append the parent location key to the file key if needed
                if let currentKey = key, !currentKey.isEmpty {
                    fileKey = currentKey + "/" + fileKey
                }
                return File(name: name, key: fileKey, ext: name.fileExt)
            }
            .flatMap { children -> EventLoopFuture<View> in
                var current: File?
                var parent: File?
                if let currentKey = key, !currentKey.isEmpty {
                    let currentName = String(currentKey.split(separator: "/").last!)
                    current = File(name: currentName, key: currentKey, ext: currentKey.fileExt)
                    
                    let parentKey = currentKey.split(separator: "/").dropLast().joined(separator: "/")
                    parent = File(name: parentKey, key: parentKey, ext: parentKey.fileExt)
                }
                
                let sortedChildren = children.sorted { lhs, rhs -> Bool in
                    if lhs.ext != nil {
                        return false
                    }
                    if rhs.ext != nil {
                        return true
                    }
                    return lhs.key < rhs.key
                }
                
                return req.leaf.render(template: "File/Admin/Browser", context: [
                    "current": current?.leafData ?? .trueNil,
                    "parent": parent?.leafData ?? .trueNil,
                    "children": .array(sortedChildren),
                ])
            }
            .encodeResponse(for: req)
        }
    }
    
    // MARK: - directory
    
    private func renderDirectoryView(req: Request, form: FileDirectoryForm) -> EventLoopFuture<View> {
        let formId = UUID().uuidString
        let nonce = req.generateNonce(for: "file-directory-form", id: formId)
        
        var leafData = form.leafData.dictionary!
        leafData["formId"] = .string(formId)
        leafData["formToken"] = .string(nonce)
        
        return req.leaf.render(template: "File/Admin/Directory", context: .init(leafData))
    }
    
    func directoryView(req: Request) -> EventLoopFuture<View> {
        renderDirectoryView(req: req, form: .init())
    }
    
    func directory(req: Request) throws -> EventLoopFuture<Response> {
        try req.validateFormToken(for: "file-directory-form")
        
        let form = FileDirectoryForm()
        return form.initialize(req: req)
            .flatMap { form.process(req: req) }
            .flatMap { form.validate(req: req) }
            .flatMap { [self] isValid in
                guard isValid else {
                    return renderDirectoryView(req: req, form: form).encodeResponse(for: req)
                }
                return form.save(req: req).map {
                    req.redirect(to: "/admin/file/browser/?key=\(form.key.value!)")
                }
            }
    }
    
    // MARK: - upload
    
    private func renderUploadView(req: Request, form: FileUploadForm) -> EventLoopFuture<View> {
        let formId = UUID().uuidString
        let nonce = req.generateNonce(for: "file-upload-form", id: formId)
        
        var leafData = form.leafData.dictionary!
        leafData["formId"] = .string(formId)
        leafData["formToken"] = .string(nonce)
        
        return req.leaf.render(template: "File/Admin/Upload", context: .init(leafData))
    }
    
    func uploadView(req: Request) -> EventLoopFuture<View> {
        renderUploadView(req: req, form: .init())
    }
    
    func upload(req: Request) throws -> EventLoopFuture<Response> {
        try req.validateFormToken(for: "file-upload-form")
        
        let form = FileUploadForm()
        return form.initialize(req: req)
            .flatMap { form.process(req: req) }
            .flatMap { form.validate(req: req) }
            .flatMap { [self] isValid in
                guard isValid else {
                    return renderUploadView(req: req, form: form).encodeResponse(for: req)
                }
                
                let futures = form.files.values.map { file -> EventLoopFuture<String> in
                    /// NOTE: better key validation on long term...
                    let fileKey = String((form.key.value! + "/" + file.filename).safePath().dropFirst())
                    return req.fs.upload(key: fileKey, data: file.dataValue!)
                }
                return req.eventLoop.flatten(futures).flatMap { _ in
                    req.redirect(to: "/admin/file/browser/?key=\(form.key.value!)").encodeResponse(for: req)
                }
            }
    }
    
    // MARK: - delete
    
    func deleteView(req: Request) throws -> EventLoopFuture<Response>  {
        let formId = UUID().uuidString
        let nonce = req.generateNonce(for: "file-delete-form", id: formId)
        
        var key: String? = nil
        /// if there is a key, check if it exists
        var future: EventLoopFuture<Bool> = req.eventLoop.future(true)
        if let keyValue = try? req.query.get(String.self, at: "key"), !keyValue.isEmpty {
            future = req.fs.exists(key: keyValue)
            key = keyValue
        }
        
        /// check if directory exists, then make some assumption about the list items...
        return future.flatMap { exists -> EventLoopFuture<Response> in
            guard exists else {
                return req.eventLoop.future(error: Abort(.notFound))
            }
            return req.leaf.render(template: "File/Admin/Delete", context: [
                "formId": .string(formId),
                "formToken": .string(nonce),
                "name": .string(key),
            ]).encodeResponse(for: req)
        }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<Response> {
        try req.validateFormToken(for: "file-delete-form")
        
        struct Context: Decodable {
            let key: String
            let redirect: String
        }
        let context = try req.content.decode(Context.self)
        return req.fs.delete(key: context.key).flatMap {
            req.redirect(to: context.redirect).encodeResponse(for: req)
        }
    }
    
}
