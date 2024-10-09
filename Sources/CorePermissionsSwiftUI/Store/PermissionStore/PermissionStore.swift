//
//  PermissionModelSet.swift
//
//
//  Created by Jevon Mao on 2/6/21.
//

import Foundation
import SwiftUI
import FamilyControls
import Combine

//MARK: - Storage
/**
 The data storage class that contains reference to all the custom configurations
 
 - SeeAlso: PermissionSchemaStore
 */
@available(iOS 13.0, tvOS 13.0, *)
public class PermissionStore: ObservableObject {
    
    //MARK: Creating a new store
    /**
     Initalizes and returns a new instance of `PermissionStore`
     
     - Returns: A configuration and customizable data store
     
     The `PermissionStore` initliazer accepts no parameters, instead, set properties after intialization:
     ```
     let store = PermissionStore()
     store.mainTexts.headerText = "PermissionsSwiftUI is the best library"
     */
    public init(){}
    
    ///An  array of permissions that configures the permissions to request
    public var permissions: [PermissionManager] = [] {
        didSet {
            bag = []
            if #available(iOS 15.0, *), permissions.contains(where: { $0.permissionType == .familyControl }) {
                AuthorizationCenter.shared.$authorizationStatus
                    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                    .sink(receiveValue: { status in
                        self.shouldNeedRequestFamilyControls = status != .approved
                    })
                    .store(in: &bag)
            } else {
                shouldNeedRequestFamilyControls = true
            }
        }
    }
    
    //MARK: Configuration store
    ///Custom configurations that alters PermissionsSwiftUI view's behaviors
    public var configStore = ConfigStore()
    
    //MARK: Permission components store
    /**
     Customizable displayed component for each PermissionType (types of permission)
     */
    public var permissionComponentsStore = PermissionComponentsStore()
    
    @Published var shouldNeedRequestFamilyControls: Bool = false
    
    private var bag: Set<AnyCancellable> = []
}

