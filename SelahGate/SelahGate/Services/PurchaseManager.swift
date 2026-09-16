import Combine
import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    static let monthlyID = "com.zzoutuo.SelahGate.pro.monthly"
    static let yearlyID = "com.zzoutuo.SelahGate.pro.yearly"
    static let lifetimeID = "com.zzoutuo.SelahGate.pro.lifetime"
    static let allIDs = [monthlyID, yearlyID, lifetimeID]

    @Published var isPro: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var loadError: String?

    private var transactionListener: Task<Void, Never>?

    private init() {
        isPro = AppGroupStore.isPro
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await checkPurchased() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: Self.allIDs).sorted { $0.price < $1.price }
            loadError = products.isEmpty ? "Purchase options are unavailable right now. Try again later." : nil
        } catch {
            loadError = "Unable to load purchase options."
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await checkPurchased()
                    await transaction.finish()
                    return true
                }
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            loadError = "Purchase failed: \(error.localizedDescription)"
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            loadError = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func checkPurchased() async {
        var entitled = false
        for id in Self.allIDs {
            if let result = await Transaction.currentEntitlement(for: id),
               case .verified(let transaction) = result,
               transaction.revocationDate == nil {
                entitled = true
                break
            }
        }
        isPro = entitled
        AppGroupStore.isPro = entitled
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    Task { @MainActor [weak self] in
                        await self?.checkPurchased()
                    }
                }
            }
        }
    }
}
