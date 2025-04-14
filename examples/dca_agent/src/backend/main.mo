import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
// TODO: Add error module import when implementing proper error handling

actor DCAAgent {
    // Types
    type UserId = Principal;
    type Timestamp = Int;
    type Asset = Text;  // BTC, ETH, etc.
    type Amount = Float;
    type Price = Float;
    
    // Might add more action types later when we implement stop-loss
    type ActionType = {
        #BUY;
        #HOLD;
        // #SELL; // Not implemented yet - will add in v0.2
    };

    // User deposit structure
    type Deposit = {
        user: UserId;
        amount: Amount;
        timestamp: Timestamp;
    };

    // Trade record structure - probably overkill for MVP but future-proofing
    type Trade = {
        user: UserId;
        sourceAsset: Asset;
        targetAsset: Asset;
        sourceAmount: Amount;
        targetAmount: Amount;
        price: Price;
        timestamp: Timestamp;
        // txFee: Amount; // Add this in v0.2 when we have real DEX integration
    };

    // Action Log structure - helps debug the AI decisions
    type ActionLog = {
        user: UserId;
        action: ActionType;
        asset: Asset;
        amount: ?Amount;
        reason: Text;
        timestamp: Timestamp;
    };

    // State variables
    stable var totalDeposits : Float = 0.0;  // Keep track for analytics
    
    // Not using stable collections for now since this is just a demo
    // If we go to production we'll need to implement upgrade hooks
    private let deposits = HashMap.HashMap<UserId, Buffer.Buffer<Deposit>>(10, Principal.equal, Principal.hash);
    private let trades = Buffer.Buffer<Trade>(100);  // Should be enough for demo
    private let actionLogs = Buffer.Buffer<ActionLog>(100);
    
    // FIXME: This is wasteful - switch to singleton map for production
    private let assetPrices = HashMap.HashMap<Asset, Price>(10, Text.equal, Text.hash);
    
    // Sample data for demo - in prod we'd use oracles
    private func setupInitialPrices() {
        // Using yesterday's prices as starting point
        assetPrices.put("ICP", 9.85);
        assetPrices.put("BTC", 62000.00);  // BTC to the moon! 🚀
        assetPrices.put("ETH", 3100.00);
    };
    
    // Initialize prices on canister startup
    setupInitialPrices();
    
    // Deposit ICP tokens into the agent
    public shared(msg) func deposit(amount : Float) : async Text {
        let user = msg.caller;
        let timestamp = Time.now();
        
        // In a real implementation, this would get tokens from a ledger canister
        // See: https://internetcomputer.org/docs/current/developer-docs/integrations/ledger/
        // NOTE: Need to figure out proper token handling, just simulating for now
        
        // Sanity check for negative deposits 
        if (amount <= 0) {
            return "Error: Deposit amount must be positive";
        };
        
        // Create the deposit record
        let newDeposit : Deposit = {
            user = user;
            amount = amount;
            timestamp = timestamp;
        };
        
        // Store the deposit in user's history
        switch (deposits.get(user)) {
            case (null) {
                let buffer = Buffer.Buffer<Deposit>(10);
                buffer.add(newDeposit);
                deposits.put(user, buffer);
            };
            case (?buffer) {
                buffer.add(newDeposit);
            };
        };
        
        totalDeposits += amount;
        
        // Log this so we can track it
        logAction(user, #HOLD, "ICP", ?amount, "Initial deposit");
        
        Debug.print("User " # Principal.toText(user) # " deposited " # Float.toText(amount) # " ICP");
        
        return "Successfully deposited " # Float.toText(amount) # " ICP";
    };
    
    // Get user balance - honestly this could be optimized but it works
    public query(msg) func getBalance() : async Float {
        let user = msg.caller;
        
        switch (deposits.get(user)) {
            case (null) { return 0.0; };  // No deposits yet
            case (?buffer) {
                var total : Float = 0.0;
                
                // Add up all deposits
                for (deposit in buffer.vals()) {
                    total += deposit.amount;
                };
                
                // Subtract any trades made (outgoing ICP)
                for (trade in trades.vals()) {
                    if (trade.user == user and trade.sourceAsset == "ICP") {
                        total -= trade.sourceAmount;
                    };
                };
                
                return total;
            };
        };
    };
    
    // The AI brain that powers our DCA decisions
    // We could make this WAY more complex but let's keep it simple for demo
    private func aiDecisionEngine(user : UserId, asset : Asset) : (ActionType, Text) {
        // This is a simplified rule-based AI logic for the MVP
        // Later we could add sentiment analysis, price trends, etc.
        
        // Get the current price
        let currentPrice = switch (assetPrices.get(asset)) {
            case (null) { 
                Debug.print("Warning: No price data for " # asset);
                return (#HOLD, "Price data unavailable"); 
            };
            case (?price) { price };
        };
        
        // Simple strategy: Buy dips, hold otherwise
        // These thresholds are just for demo - would be configurable in production
        if (asset == "BTC" and currentPrice < 63000.0) {
            // BTC looks cheap, let's buy
            return (#BUY, "BTC price below threshold - good buying opportunity");
        };
        
        if (asset == "ETH" and currentPrice < 3200.0) {
            // ETH looks cheap too
            return (#BUY, "ETH price below threshold - good buying opportunity");
        };
        
        // Nothing exciting, just hold
        return (#HOLD, "Current market conditions not favorable");
    };
    
    // Execute the DCA strategy
    // This is where the magic happens!
    public shared(msg) func executeDCA(targetAsset : Asset, dcaAmount : Float) : async Text {
        let user = msg.caller;
        
        // Check if user has sufficient balance
        let userBalance = await getBalance();
        
        if (userBalance < dcaAmount) {
            // Sorry buddy, you're broke
            return "Insufficient balance to execute DCA strategy. You have " # Float.toText(userBalance) # " ICP but tried to use " # Float.toText(dcaAmount);
        };
        
        // Get the AI decision - should we buy or hold?
        let (action, reason) = aiDecisionEngine(user, targetAsset);
        
        switch (action) {
            case (#HOLD) {
                // AI says hold, so we'll just log it and do nothing
                logAction(user, action, targetAsset, null, reason);
                return "AI decision: HOLD. " # reason;
            };
            case (#BUY) {
                // AI says buy, let's do this!
                
                // Get current prices for conversion calculation
                let icpPrice = switch (assetPrices.get("ICP")) {
                    case (null) { return "ICP price data unavailable - can't execute trade"; };
                    case (?price) { price };
                };
                
                let targetPrice = switch (assetPrices.get(targetAsset)) {
                    case (null) { return targetAsset # " price data unavailable - can't execute trade"; };
                    case (?price) { price };
                };
                
                // Calculate how much of the target asset we can buy
                // ICP amount * ICP price in USD / target asset price in USD = target asset amount
                let targetAmount = (dcaAmount * icpPrice) / targetPrice;
                
                // Record the trade for history/portfolio tracking
                let newTrade : Trade = {
                    user = user;
                    sourceAsset = "ICP";
                    targetAsset = targetAsset;
                    sourceAmount = dcaAmount;
                    targetAmount = targetAmount;
                    price = targetPrice;
                    timestamp = Time.now();
                };
                
                trades.add(newTrade);
                
                // Log it for the user's activity feed
                logAction(user, action, targetAsset, ?targetAmount, reason);
                
                // Debug info for our logs
                Debug.print("User " # Principal.toText(user) # " executed DCA: " # Float.toText(dcaAmount) # " ICP -> " # Float.toText(targetAmount) # " " # targetAsset);
                
                return "🎉 Successfully executed DCA: Bought " # Float.toText(targetAmount) # " " # targetAsset # " with " # Float.toText(dcaAmount) # " ICP. Reason: " # reason;
            };
        };
    };
    
    // Update price data - in prod this would connect to oracles
    // But for demo we'll just manually update or simulate
    public func updatePriceData(asset : Asset, newPrice : Price) : async () {
        // Input validation
        if (newPrice <= 0) {
            Debug.print("Invalid price update attempted: " # asset # " -> " # Float.toText(newPrice));
            return;
        };
        
        // Update the price
        assetPrices.put(asset, newPrice);
        
        // Log it for debugging
        Debug.print("Updated price: " # asset # " -> " # Float.toText(newPrice));
    };
    
    // Get current price for an asset
    public query func getCurrentPrice(asset : Asset) : async ?Price {
        return assetPrices.get(asset);
    };
    
    // Log action - private helper function
    private func logAction(user : UserId, action : ActionType, asset : Asset, amount : ?Amount, reason : Text) {
        let log : ActionLog = {
            user = user;
            action = action;
            asset = asset;
            amount = amount;
            reason = reason;
            timestamp = Time.now();
        };
        
        actionLogs.add(log);
        
        // We could persist these to long-term storage in the future
        // if we want to keep a permanent record
    };
    
    // Get action logs for a user
    public query(msg) func getUserActionLogs() : async [ActionLog] {
        let user = msg.caller;
        let userLogs = Buffer.Buffer<ActionLog>(20);
        
        // Filter logs for this specific user
        for (log in actionLogs.vals()) {
            if (log.user == user) {
                userLogs.add(log);
            };
        };
        
        return Buffer.toArray(userLogs);
    };
    
    // Get all trades for a user - needed for portfolio view
    public query(msg) func getUserTrades() : async [Trade] {
        let user = msg.caller;
        let userTrades = Buffer.Buffer<Trade>(20);
        
        // Only return trades for the calling user
        for (trade in trades.vals()) {
            if (trade.user == user) {
                userTrades.add(trade);
            };
        };
        
        return Buffer.toArray(userTrades);
    };
    
    // Admin function - TODO: add proper access control 
    // Right now anyone can call this which is bad for production
    public query func getAllActionLogs() : async [ActionLog] {
        return Buffer.toArray(actionLogs);
    };
    
    // TODO: Implement auto-DCA scheduler functionality in v0.2
    // public func scheduleRecurringDCA(...) : async ... { ... }
    
    // TODO: Implement withdraw functionality
    // public shared(msg) func withdraw(...) : async ... { ... }
} 