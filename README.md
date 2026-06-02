# SHA-256 Hardware Accelerator in Verilog HDL

## 📌 Overview

This repository contains a university group project implementing the SHA-256 cryptographic hash algorithm in Verilog HDL.

The design focuses on a hardware-oriented architecture consisting of dedicated message scheduling, compression, and control modules. To improve processing efficiency, the implementation adopts a Two-Stage Unrolling architecture that processes two SHA-256 rounds per clock cycle.

---

## 🛠 Development Environment

- Language: Verilog HDL
- Simulation Tool: ModelSim
- Design Methodology: RTL Design
- Verification:
  - Functional Simulation
  - Gate-Level Simulation

---

## 📋 Project Scope

The project includes:

- SHA-256 Message Scheduler
- Compression Engine
- Constant Generator
- Finite State Machine (FSM) Control
- Top-Level Integration Module
- Two-Stage Unrolling Architecture
- Testbench Development
- Functional Verification
- Post-Simulation Verification

---

## 🏗 Architecture

The accelerator is organized into several major modules:

- K Constant Generator
- Message Expansion Unit
- Compression Unit
- SHA Top Module
- Verification Testbench

The architecture employs a Two-Stage Unrolling approach to reduce the number of clock cycles required for SHA-256 round processing.

---

## 🧪 Verification

The design was verified using ModelSim through multiple test scenarios, including:

- Empty strings
- Single-character inputs
- Single-block messages
- Multi-block messages
- UTF-8 encoded Vietnamese text

Simulation results were compared against reference SHA-256 outputs to ensure correctness.

---

## 📄 Project Report

The complete design methodology, architecture description, simulation results, and implementation details are provided in the accompanying project report.

---

## 👥 Team Project

This repository contains coursework developed collaboratively as part of a university group project.

---

## 📌 Key Learnings

- RTL design using Verilog HDL
- Cryptographic hardware implementation
- SHA-256 architecture
- FSM-based control systems
- Hardware optimization techniques
- Functional and gate-level verification
- Digital system integration
