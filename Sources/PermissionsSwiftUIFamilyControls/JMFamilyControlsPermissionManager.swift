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

@available(iOS 15.0, tvOS 15.0, *)
public extension PermissionManager {
    ///The `familyControls` permission allows the device's activity usage to be tracked
    @available(iOS 16.0, *)
    static func familyControls(member: FamilyControlsMember) -> JMFamilyControlsPermissionManager {
        return JMFamilyControlsPermissionManager(role: member)
    }
    
    static var familyControls: JMFamilyControlsPermissionManager {
        return JMFamilyControlsPermissionManager()
    }
}

@available(iOS 15.0, tvOS 15.0, *)
public final class JMFamilyControlsPermissionManager: PermissionManager {
    typealias authorizationStatus = FamilyControls.AuthorizationStatus
    typealias permissionManagerInstance = JMFamilyControlsPermissionManager
    
    @available(iOS 16.0, *)
    private var _role: FamilyControls.FamilyControlsMember! {
        return role as? FamilyControls.FamilyControlsMember
    }
    
    private var role: Any? = nil
    
    private var bag = Set<AnyCancellable>()
    
    private var currentStatus: FamilyControls.AuthorizationStatus = .notDetermined
    
    @available(iOS 16.0, *)
    init(role: FamilyControls.FamilyControlsMember) {
        self.role = role
        super.init()
        
        AuthorizationCenter.shared.$authorizationStatus
            .sink { status in
                self.currentStatus = status
            }
            .store(in: &bag)
    }
    
    public override init() {
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
                    if #available(iOS 16.0, *) {
                        try await AuthorizationCenter.shared.requestAuthorization(for: _role)
                        completion(currentStatus == .approved, nil)
                    } else {
                        AuthorizationCenter.shared.requestAuthorization { result in
                            switch result {
                            case .success(let success):
                                completion(true, nil)
                            case .failure(let failure):
                                completion(false, failure)
                            }
                        }
                    }
                    
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
