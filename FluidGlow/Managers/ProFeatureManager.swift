import Foundation
import StoreKit
import Combine
import SwiftUI
import HSCore

// MARK: - Rewarded & In-App Purchase VIP Feature Manager (Powered by HSKit HSStoreManager)
@MainActor
public final class ProFeatureManager: ObservableObject {
    public static let shared = ProFeatureManager()
    
    public static let lifetimeVIPProductID = "com.saadapps.fluidglow.vip"
    
    private let storeManager = HSStoreManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    #if DEBUG
    @AppStorage("fluidglow_vip_active") private var debugVIPOverride: Bool = false
    #endif
    
    @Published public var tempUnlockedPresets: Set<String> = []
    @Published public var localErrorMessage: String?
    
    public var isVIP: Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-vip_active") {
            return true
        }
        return storeManager.isProductUnlocked(Self.lifetimeVIPProductID) || debugVIPOverride
        #else
        return storeManager.isProductUnlocked(Self.lifetimeVIPProductID)
        #endif
    }
    
    public var isPurchasing: Bool {
        storeManager.isPurchasing
    }
    
    public var vipProduct: Product? {
        storeManager.products.first(where: { $0.id == Self.lifetimeVIPProductID })
    }
    
    public var errorMessage: String? {
        get { localErrorMessage ?? storeManager.purchaseErrorMessage }
        set {
            localErrorMessage = newValue
            storeManager.purchaseErrorMessage = newValue
        }
    }
    
    public init() {
        storeManager.configure(productIDs: [Self.lifetimeVIPProductID])
        
        // Synchronize state dynamically when StoreKit updates entitlements
        storeManager.$unlockedProductIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
        storeManager.$isPurchasing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    public func isPresetUnlocked(_ preset: FluidShaderPreset) -> Bool {
        if !preset.isVIPOnly { return true }
        if isVIP { return true }
        return tempUnlockedPresets.contains(preset.rawValue)
    }
    
    public func grantTemporaryPresetUnlock(_ preset: FluidShaderPreset) {
        tempUnlockedPresets.insert(preset.rawValue)
        FluidHapticsManager.success()
        objectWillChange.send()
    }
    
    public func loadProducts() async {
        await storeManager.requestProducts()
    }
    
    public func purchaseVIP() async -> Bool {
        localErrorMessage = nil
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-vip_active") {
            self.debugVIPOverride = true
            FluidHapticsManager.success()
            objectWillChange.send()
            return true
        }
        #endif
        
        let success = await storeManager.purchase(productID: Self.lifetimeVIPProductID)
        if success {
            FluidHapticsManager.success()
        } else if let error = storeManager.purchaseErrorMessage {
            localErrorMessage = error
        }
        objectWillChange.send()
        return success
    }
    
    public func restorePurchases() async {
        localErrorMessage = nil
        await storeManager.restorePurchases()
        if isVIP {
            FluidHapticsManager.success()
        } else {
            localErrorMessage = storeManager.purchaseErrorMessage ?? "No previous VIP purchases found."
        }
        objectWillChange.send()
    }

    public func checkCurrentEntitlements() async {
        await storeManager.updatePurchasedStatus()
        objectWillChange.send()
    }
}
