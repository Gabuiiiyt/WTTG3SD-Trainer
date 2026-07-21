-- ============================================
-- ForceCheats - Fly / Ghost / Walk toggle
-- ============================================

local excludedKeywords = { "DeadPawn", "MainTitlePawn", "MenuPawn", "TitlePawn" }

local function isExcluded(className)
    for _, kw in ipairs(excludedKeywords) do
        if string.find(className, kw) then return true end
    end
    return false
end

local function GetLivePawnAndMC()
    local PC = FindFirstOf("PlayerController")
    if not PC:IsValid() then return nil, nil end

    local Pawn = PC.Pawn
    if not Pawn:IsValid() then return nil, nil end

    local className = Pawn:GetClass():GetFullName()
    if isExcluded(className) then
        print("[ForceCheats] Pawn attuale escluso (menu/morto), comando ignorato\n")
        return nil, nil
    end

    local MC = Pawn:GetMovementComponent()
    if not MC or not MC:IsValid() then return nil, nil end

    return Pawn, MC
end

-- ==================== FLY: Ctrl+Alt+F ====================
RegisterKeyBind(Key.F, {ModifierKey.CONTROL, ModifierKey.ALT}, function()
    local Pawn, MC = GetLivePawnAndMC()
    if MC then
        MC:SetMovementMode(5, 0)
        MC.BrakingDecelerationFlying = 2048.0
        MC.MaxFlySpeed = 600.0
        Pawn:SetActorEnableCollision(true)
        print("[ForceCheats] FLY attivato\n")
    end
end)

-- ==================== GHOST: Ctrl+Alt+G ====================
RegisterKeyBind(Key.G, {ModifierKey.CONTROL, ModifierKey.ALT}, function()
    local Pawn, MC = GetLivePawnAndMC()
    if MC then
        MC:SetMovementMode(5, 0)  -- MOVE_Flying
        MC.BrakingDecelerationFlying = 2048.0
        MC.MaxFlySpeed = 600.0
        Pawn:SetActorEnableCollision(false)
        print("[ForceCheats] GHOST attivato (volo + no collisione)\n")
    end
end)

-- ==================== WALK: Ctrl+Alt+H ====================
RegisterKeyBind(Key.H, {ModifierKey.CONTROL, ModifierKey.ALT}, function()
    local Pawn, MC = GetLivePawnAndMC()
    if MC then
        MC:SetMovementMode(1, 0)  -- MOVE_Walking
        Pawn:SetActorEnableCollision(true)
        print("[ForceCheats] WALK ripristinato\n")
    end
end)

-- ==================== QUOTA: Ctrl+Alt+PageUp / Ctrl+Alt+PageDown ====================
RegisterKeyBind(Key.PAGE_UP, {ModifierKey.CONTROL, ModifierKey.ALT}, function()
    local _, MC = GetLivePawnAndMC()
    if MC then
        MC.Velocity.Z = 400
        print("[ForceCheats] Salita\n")
    end
end)

RegisterKeyBind(Key.PAGE_DOWN, {ModifierKey.CONTROL, ModifierKey.ALT}, function()
    local _, MC = GetLivePawnAndMC()
    if MC then
        MC.Velocity.Z = -400
        print("[ForceCheats] Discesa\n")
    end
end)

print("[ForceCheats] Mod Caricata - Comandi - Ctrl+Alt+F=Fly | Ctrl+Alt+G=Ghost | Ctrl+Alt+H=Walk | Ctrl+Alt+PageUp/PageDown=Quota\n")

local function GetPlayerData()
    local PlayerData = FindFirstOf("PlayerData")

    if not PlayerData or not PlayerData:IsValid() then
        return nil
    end

    return PlayerData
end


local function GetAmount(Parameters)
    if not Parameters or #Parameters < 1 then
        return nil
    end

    local Amount = tonumber(Parameters[1])

    if not Amount then
        return nil
    end

    return Amount
end


-- addcoin <valore>
RegisterConsoleCommandHandler("addcoin", function(FullCommand, Parameters, OutputDevice)

    local Amount = GetAmount(Parameters)

    if not Amount then
        OutputDevice:Log("Usage: addcoin <amount>")
        return true
    end

    if Amount < 0 then
        OutputDevice:Log("Amount must be positive.")
        return true
    end

    local PlayerData = GetPlayerData()

    if not PlayerData then
        OutputDevice:Log("PlayerData not found.")
        return true
    end

    local OldBalance = PlayerData.DOSCoinBalance
    local NewBalance = OldBalance + Amount

    PlayerData.DOSCoinBalance = NewBalance

    OutputDevice:Log(
        string.format(
            "Added %.2f DoS Coins. Balance: %.2f -> %.2f",
            Amount,
            OldBalance,
            NewBalance
        )
    )

    return true
end)


-- rmcoin <valore>
RegisterConsoleCommandHandler("rmcoin", function(FullCommand, Parameters, OutputDevice)

    local Amount = GetAmount(Parameters)

    if not Amount then
        OutputDevice:Log("Usage: rmcoin <amount>")
        return true
    end

    if Amount < 0 then
        OutputDevice:Log("Amount must be positive.")
        return true
    end

    local PlayerData = GetPlayerData()

    if not PlayerData then
        OutputDevice:Log("PlayerData not found.")
        return true
    end

    local OldBalance = PlayerData.DOSCoinBalance
    local NewBalance = OldBalance - Amount

    -- Impedisce che il saldo diventi negativo
    if NewBalance < 0 then
        NewBalance = 0
    end

    PlayerData.DOSCoinBalance = NewBalance

    OutputDevice:Log(
        string.format(
            "Removed %.2f DoS Coins. Balance: %.2f -> %.2f",
            Amount,
            OldBalance,
            NewBalance
        )
    )

    return true
end)


print("[DoSCoinManager] Loaded successfully.")
print("[DoSCoinManager] Commands: addcoin <amount> | rmcoin <amount>")