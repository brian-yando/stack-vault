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
