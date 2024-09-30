//
//  JMFamilyControlsInvidualPermissionManager.swift
//
//
//  Created by Hoa Pham on 14/9/24.
//

import Foundation
import CorePermissionsSwiftUI
import FamilyControls
import Combine

@available(iOS 16.0, tvOS 16.0, *)
public extension PermissionManager {
    ///The `familyControls` permission allows the device's activity usage to be tracked
    static func familyControls(member: FamilyControlsMember) -> JMFamilyControlsPermissionManager {
        return JMFamilyControlsPermissionManager(role: member)
    }
}

@available(iOS 16.0, tvOS 16.0, *)
public final class JMFamilyControlsPermissionManager: PermissionManager {
    typealias authorizationStatus = FamilyControls.AuthorizationStatus
    typealias permissionManagerInstance = JMFamilyControlsPermissionManager
    
    private let role: FamilyControls.FamilyControlsMember
    private var bag = Set<AnyCancellable>()
    
    private var currentStatus: FamilyControls.AuthorizationStatus = .notDetermined
    
    init(role: FamilyControls.FamilyControlsMember) {
        self.role = role
        super.init()
        
        AuthorizationCenter.shared.$authorizationStatus
            .sink { status in
                self.currentStatus = status
            }
            .store(in: &bag)
    }
    
    public override var permissionType: PermissionType {
        .familyControl
    }
    
    public override var authorizationStatus: CorePermissionsSwiftUI.AuthorizationStatus {
        switch AuthorizationCenter.shared.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .approved:
            return .authorized
        }
    }

    var completionHandler: ((Bool, Error?) -> Void)?
    
    override public func requestPermission(completion: @escaping (Bool, Error?) -> Void) {
        switch currentStatus {
        case .notDetermined:
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: role)
                    completion(currentStatus == .approved, nil)
                } catch let error {
                    completion(false, error)
                }
            }
        default:
            completion(currentStatus == .approved, nil)
        }
    }
    
    deinit {
        
    }
}
