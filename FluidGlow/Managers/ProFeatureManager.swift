import Foundation
import StoreKit

@MainActor
public final class ProFeatureManager: ObservableObject {
    public static let shared = ProFeatureManager()
    
    public static let lifetimeVIPProductID = "com.saadapps.fluidglow.vip"
    
    @Published public private(set) var isVIP: Bool = false
    @Published public var tempUnlockedPresets: Set<String> = []
    @Published public private(set) var isPurchasing: Bool = false
    @Published public private(set) var vipProduct: Product?
    @Published public var errorMessage: String?
    
    private var transactionTask: Task<Void, Never>?
    
    public init() {
        self.isVIP = UserDefaults.standard.bool(forKey: "fluidglow_vip_active")
        startTransactionListener()
        Task {
            await loadProducts()
            await checkCurrentEntitlements()
        }
    }
    
    deinit {
        transactionTask?.cancel()
    }
    
    public func isPresetUnlocked(_ preset: FluidShaderPreset) -> Bool {
        if !preset.isVIPOnly { return true }
        if isVIP { return true }
        return tempUnlockedPresets.contains(preset.rawValue)
    }
    
    public func grantTemporaryPresetUnlock(_ preset: FluidShaderPreset) {
        tempUnlockedPresets.insert(preset.rawValue)
        FluidHapticsManager.success()
    }
    
    public func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.lifetimeVIPProductID])
            self.vipProduct = products.first
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    public func purchaseVIP() async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        
        #if DEBUG
        // Immediate simulator test unlock
        self.isVIP = true
        UserDefaults.standard.set(true, forKey: "fluidglow_vip_active")
        FluidHapticsManager.success()
        return true
        #else
        guard let product = vipProduct else {
            errorMessage = "VIP Pass product unavailable in App Store."
            return false
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    self.isVIP = true
                    UserDefaults.standard.set(true, forKey: "fluidglow_vip_active")
                    FluidHapticsManager.success()
                    return true
                case .unverified(_, let error):
                    errorMessage = "Purchase could not be verified: \(error.localizedDescription)"
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                errorMessage = "Purchase is pending approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        #endif
    }
    
    public func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        #if DEBUG
        self.isVIP = true
        UserDefaults.standard.set(true, forKey: "fluidglow_vip_active")
        FluidHapticsManager.success()
        #else
        do {
            try await AppStore.sync()
            await checkCurrentEntitlements()
            if isVIP {
                FluidHapticsManager.success()
            } else {
                errorMessage = "No previous VIP purchases found."
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
        #endif
    }

    public func checkCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.lifetimeVIPProductID {
                    if transaction.revocationDate == nil {
                        self.isVIP = true
                        UserDefaults.standard.set(true, forKey: "fluidglow_vip_active")
                        return
                    }
                }
            }
        }
    }
    
    private func startTransactionListener() {
        transactionTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.updateEntitlement(for: transaction)
                }
            }
        }
    }
    
    private func updateEntitlement(for transaction: Transaction) {
        if transaction.productID == Self.lifetimeVIPProductID {
            self.isVIP = transaction.revocationDate == nil
            UserDefaults.standard.set(self.isVIP, forKey: "fluidglow_vip_active")
        }
    }
}
