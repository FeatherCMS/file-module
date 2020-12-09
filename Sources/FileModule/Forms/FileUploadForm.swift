//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 06. 03..
//

import FeatherCore

extension File: LeafDataRepresentable {

    public var leafData: LeafData {
        .dictionary([
            "name": filename
        ])
    }
}

final class FileUploadForm: Form {

    var key = FormField<String>(key: "key")
    var files = ArraySelectionFormField<File>(key: "files") //required
    var notification: String?

    var fields: [FormFieldRepresentable] {
        [key, files]
    }
    
    init() {}
}
