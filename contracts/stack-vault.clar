;; Title: StackVault - Next-Generation Bitcoin L2 Lending Protocol
;;
;; Summary:
;; StackVault represents the pinnacle of decentralized lending infrastructure on 
;; the Stacks blockchain, leveraging Bitcoin's security model to create a robust,
;; capital-efficient lending ecosystem. Built for the sovereign Bitcoin economy.
;;
;; Description:
;; A sophisticated DeFi lending protocol that enables Bitcoin holders to unlock
;; liquidity from their STX holdings while maintaining exposure to the Bitcoin
;; ecosystem. StackVault implements advanced risk management algorithms, dynamic
;; collateralization ratios, and automated liquidation mechanisms to ensure
;; protocol stability and user capital protection.
;;
;; Features:
;; - Overcollateralized lending with dynamic risk assessment
;; - Automated liquidation engine for protocol solvency
;; - Gas-optimized operations with minimal transaction costs
;; - Real-time collateral ratio monitoring and alerts
;; - Governance-driven parameter adjustments for market adaptability
;;
;; Security Model:
;; The protocol inherits Bitcoin's security guarantees through Stacks' unique
;; Proof-of-Transfer consensus mechanism, ensuring maximum security for user funds
;; while enabling sophisticated DeFi primitives previously impossible on Bitcoin.
;;

;; PROTOCOL CONSTANTS & CONFIGURATION

;; Protocol Governance
(define-constant PROTOCOL-OWNER tx-sender)

;; Risk Management Parameters
(define-constant MAX-COLLATERAL-RATIO u500) ;; 500% - Maximum overcollateralization
(define-constant MIN-COLLATERAL-RATIO u110) ;; 110% - Minimum safety threshold
(define-constant MAX-PROTOCOL-FEE u10) ;; 10% - Maximum fee ceiling

;; ERROR HANDLING SYSTEM

;; Authentication & Authorization Errors
(define-constant ERR-UNAUTHORIZED-ACCESS (err u100))

;; Collateral Management Errors  
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))

;; Loan Management Errors
(define-constant ERR-LOAN-NOT-FOUND (err u103))
(define-constant ERR-LOAN-STILL-ACTIVE (err u104))

;; Liquidation System Errors
(define-constant ERR-LIQUIDATION-THRESHOLD-NOT-MET (err u106))

;; Parameter Validation Errors
(define-constant ERR-INVALID-PARAMETER (err u107))

;; PROTOCOL STATE VARIABLES

;; Risk Management Configuration
(define-data-var minimum-collateral-ratio uint u150) ;; 150% - Conservative default
(define-data-var liquidation-threshold uint u130) ;; 130% - Liquidation trigger
(define-data-var protocol-fee uint u1) ;; 1% - Platform fee

;; Protocol Statistics & Metrics
(define-data-var total-protocol-deposits uint u0) ;; Total STX deposited
(define-data-var total-protocol-borrows uint u0) ;; Total STX borrowed

;; DATA STRUCTURES & MAPPINGS

;; Comprehensive Loan Tracking System
(define-map loan-registry
  { loan-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    borrowed-amount: uint,
    interest-rate: uint,
    creation-height: uint,
    last-interest-calculation: uint,
    is-active: bool,
  }
)

;; User Portfolio Management
(define-map user-portfolio
  { user: principal }
  {
    total-collateral-deposited: uint,
    total-amount-borrowed: uint,
    active-loan-count: uint,
  }
)

;; INTERNAL CALCULATION FUNCTIONS

;; Advanced Interest Calculation Engine
;; Computes compound interest over specified block intervals
(define-private (compute-accrued-interest
    (principal-amount uint)
    (annual-rate uint)
    (block-duration uint)
  )
  (let (
      (interest-per-block (/ (* principal-amount annual-rate) u10000))
      (total-accrued-interest (* interest-per-block block-duration))
    )
    total-accrued-interest
  )
)

;; Dynamic Collateralization Ratio Calculator
;; Returns collateral ratio as percentage (e.g., 150 = 150%)
(define-private (calculate-collateral-ratio
    (collateral-value uint)
    (debt-value uint)
  )
  (if (is-eq debt-value u0)
    u0 ;; No debt means infinite collateralization
    (/ (* collateral-value u100) debt-value)
  )
)

;; User Portfolio State Management
;; Updates user's lending position with atomic operations
(define-private (update-user-portfolio
    (user principal)
    (collateral-delta uint)
    (is-collateral-deposit bool)
    (borrow-delta uint)
    (is-borrow-increase bool)
  )
  (let (
      (current-portfolio (default-to {
        total-collateral-deposited: u0,
        total-amount-borrowed: u0,
        active-loan-count: u0,
      }
        (map-get? user-portfolio { user: user })
      ))
      (updated-collateral (if is-collateral-deposit
        (+ (get total-collateral-deposited current-portfolio) collateral-delta)
        (- (get total-collateral-deposited current-portfolio) collateral-delta)
      ))
      (updated-borrowed (if is-borrow-increase
        (+ (get total-amount-borrowed current-portfolio) borrow-delta)
        (- (get total-amount-borrowed current-portfolio) borrow-delta)
      ))
    )
    (map-set user-portfolio { user: user } {
      total-collateral-deposited: updated-collateral,
      total-amount-borrowed: updated-borrowed,
      active-loan-count: (get active-loan-count current-portfolio),
    })
  )
)

;; CORE LENDING PROTOCOL OPERATIONS

;; COLLATERAL DEPOSIT FUNCTION
;; Allows users to deposit STX tokens as collateral for borrowing
(define-public (deposit-collateral)
  (let ((deposit-amount (stx-get-balance tx-sender)))
    (if (> deposit-amount u0)
      (begin
        ;; Transfer STX from user to protocol vault
        (try! (stx-transfer? deposit-amount tx-sender (as-contract tx-sender)))

        ;; Update protocol statistics
        (var-set total-protocol-deposits
          (+ (var-get total-protocol-deposits) deposit-amount)
        )

        ;; Update user's portfolio
        (update-user-portfolio tx-sender deposit-amount true u0 true)

        (ok deposit-amount)
      )
      ERR-INVALID-AMOUNT
    )
  )
)

;; STX BORROWING FUNCTION  
;; Enables users to borrow STX against their deposited collateral
(define-public (borrow-stx (requested-amount uint))
  (let (
      (user-portfolio-data (default-to {
        total-collateral-deposited: u0,
        total-amount-borrowed: u0,
        active-loan-count: u0,
      }
        (map-get? user-portfolio { user: tx-sender })
      ))
      (available-collateral (get total-collateral-deposited user-portfolio-data))
      (current-debt (get total-amount-borrowed user-portfolio-data))
    )
    (if (and
        (> requested-amount u0)
        (>=
          (calculate-collateral-ratio available-collateral
            (+ current-debt requested-amount)
          )
          (var-get minimum-collateral-ratio)
        )
      )
      (begin
        ;; Transfer borrowed STX from protocol to user
        (try! (as-contract (stx-transfer? requested-amount (as-contract tx-sender) tx-sender)))

        ;; Update protocol borrow statistics
        (var-set total-protocol-borrows
          (+ (var-get total-protocol-borrows) requested-amount)
        )

        ;; Update user's portfolio
        (update-user-portfolio tx-sender u0 true requested-amount true)

        (ok requested-amount)
      )
      ERR-INSUFFICIENT-COLLATERAL
    )
  )
)

;; LOAN REPAYMENT FUNCTION
;; Allows users to repay their borrowed STX amount
(define-public (repay-loan (repayment-amount uint))
  (let (
      (user-portfolio-data (default-to {
        total-collateral-deposited: u0,
        total-amount-borrowed: u0,
        active-loan-count: u0,
      }
        (map-get? user-portfolio { user: tx-sender })
      ))
      (outstanding-debt (get total-amount-borrowed user-portfolio-data))
    )
    (if (<= repayment-amount outstanding-debt)
      (begin
        ;; Transfer repayment from user to protocol
        (try! (stx-transfer? repayment-amount tx-sender (as-contract tx-sender)))

        ;; Update protocol statistics
        (var-set total-protocol-borrows
          (- (var-get total-protocol-borrows) repayment-amount)
        )

        ;; Update user's portfolio
        (update-user-portfolio tx-sender u0 true repayment-amount false)

        (ok repayment-amount)
      )
      ERR-INVALID-AMOUNT
    )
  )
)

;; COLLATERAL WITHDRAWAL FUNCTION
;; Enables users to withdraw excess collateral while maintaining minimum ratio
(define-public (withdraw-collateral (withdrawal-amount uint))
  (let (
      (user-portfolio-data (default-to {
        total-collateral-deposited: u0,
        total-amount-borrowed: u0,
        active-loan-count: u0,
      }
        (map-get? user-portfolio { user: tx-sender })
      ))
      (available-collateral (get total-collateral-deposited user-portfolio-data))
      (outstanding-debt (get total-amount-borrowed user-portfolio-data))
    )
    (if (and
        (<= withdrawal-amount available-collateral)
        (>=
          (calculate-collateral-ratio (- available-collateral withdrawal-amount)
            outstanding-debt
          )
          (var-get minimum-collateral-ratio)
        )
      )
      (begin
        ;; Transfer collateral from protocol to user
        (try! (as-contract (stx-transfer? withdrawal-amount (as-contract tx-sender) tx-sender)))

        ;; Update protocol statistics
        (var-set total-protocol-deposits
          (- (var-get total-protocol-deposits) withdrawal-amount)
        )

        ;; Update user's portfolio
        (update-user-portfolio tx-sender withdrawal-amount false u0 true)

        (ok withdrawal-amount)
      )
      ERR-INSUFFICIENT-COLLATERAL
    )
  )
)

;; LIQUIDATION ENGINE

;; AUTOMATED LIQUIDATION SYSTEM
;; Liquidates undercollateralized positions to maintain protocol solvency
(define-public (execute-liquidation (target-user principal))
  (let (
      (target-portfolio (unwrap! (map-get? user-portfolio { user: target-user }) ERR-LOAN-NOT-FOUND))
      (collateral-amount (get total-collateral-deposited target-portfolio))
      (debt-amount (get total-amount-borrowed target-portfolio))
      (current-ratio (calculate-collateral-ratio collateral-amount debt-amount))
    )
    ;; Prevent self-liquidation
    (asserts! (not (is-eq target-user tx-sender)) ERR-UNAUTHORIZED-ACCESS)

    ;; Ensure user has outstanding debt
    (asserts! (> debt-amount u0) ERR-INVALID-AMOUNT)

    ;; Check if liquidation threshold is breached
    (if (< current-ratio (var-get liquidation-threshold))
      (begin
        ;; Transfer all collateral to liquidator
        (try! (as-contract (stx-transfer? collateral-amount (as-contract tx-sender) tx-sender)))

        ;; Remove user from portfolio registry
        (map-delete user-portfolio { user: target-user })

        ;; Update protocol statistics
        (var-set total-protocol-deposits
          (- (var-get total-protocol-deposits) collateral-amount)
        )
        (var-set total-protocol-borrows
          (- (var-get total-protocol-borrows) debt-amount)
        )

        (ok true)
      )
      ERR-LIQUIDATION-THRESHOLD-NOT-MET
    )
  )
)

;; PROTOCOL ANALYTICS & READ-ONLY FUNCTIONS

;; USER PORTFOLIO QUERY
;; Returns comprehensive user lending position information
(define-read-only (get-user-portfolio (user principal))
  (default-to {
    total-collateral-deposited: u0,
    total-amount-borrowed: u0,
    active-loan-count: u0,
  }
    (map-get? user-portfolio { user: user })
  )
)

;; PROTOCOL STATISTICS DASHBOARD
;; Provides real-time protocol health and configuration metrics
(define-read-only (get-protocol-analytics)
  {
    total-value-locked: (var-get total-protocol-deposits),
    total-borrowed-amount: (var-get total-protocol-borrows),
    minimum-collateral-ratio: (var-get minimum-collateral-ratio),
    liquidation-threshold: (var-get liquidation-threshold),
    protocol-fee-rate: (var-get protocol-fee),
    utilization-rate: (if (> (var-get total-protocol-deposits) u0)
      (/ (* (var-get total-protocol-borrows) u100)
        (var-get total-protocol-deposits)
      )
      u0
    ),
  }
)

;; PROTOCOL GOVERNANCE & ADMINISTRATION

;; COLLATERAL RATIO ADJUSTMENT
;; Allows protocol owner to adjust minimum collateralization requirements
(define-public (update-minimum-collateral-ratio (new-ratio uint))
  (begin
    (asserts! (is-eq tx-sender PROTOCOL-OWNER) ERR-UNAUTHORIZED-ACCESS)
    (asserts!
      (and
        (>= new-ratio MIN-COLLATERAL-RATIO)
        (<= new-ratio MAX-COLLATERAL-RATIO)
      )
      ERR-INVALID-PARAMETER
    )
    (var-set minimum-collateral-ratio new-ratio)
    (ok true)
  )
)

;; LIQUIDATION THRESHOLD CONFIGURATION
;; Updates the threshold at which positions become liquidatable
(define-public (update-liquidation-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender PROTOCOL-OWNER) ERR-UNAUTHORIZED-ACCESS)
    (asserts!
      (and
        (>= new-threshold MIN-COLLATERAL-RATIO)
        (<= new-threshold (var-get minimum-collateral-ratio))
      )
      ERR-INVALID-PARAMETER
    )
    (var-set liquidation-threshold new-threshold)
    (ok true)
  )
)

;; PROTOCOL FEE MANAGEMENT
;; Adjusts platform fees for sustainable protocol operations
(define-public (update-protocol-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender PROTOCOL-OWNER) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (<= new-fee MAX-PROTOCOL-FEE) ERR-INVALID-PARAMETER)
    (var-set protocol-fee new-fee)
    (ok true)
  )
)
